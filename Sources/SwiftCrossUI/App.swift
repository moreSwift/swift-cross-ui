import Foundation
import Logging

/// Backing storage for `logger`.
///
/// ## Safety
/// This is only ever mutated once, almost immediately after the app is launched and
/// well before we do any concurrency shenanigans. Subsequent reads are always safe
/// since `Logger` is `Sendable`.
nonisolated(unsafe) private var _logger: Logger?

/// The global logger.
package var logger: Logger {
    guard let _logger else {
        let logger = Logger(label: "TestLogger")
        logger.trace("logger used before initialization")
        _logger = logger
        return logger
    }
    return _logger
}

/// An application.
@MainActor
public protocol App {
    /// The backend used to render the app.
    associatedtype Backend: AppBackend
    /// The app storage provider used to persist state annotated with ``AppStorage``.
    associatedtype StorageProvider: AppStorageProvider
    /// The type of scene representing the content of the app.
    associatedtype Body: Scene

    /// Metadata loaded at app start up.
    ///
    /// By default SwiftCrossUI attempts to load metadata inserted by Swift
    /// Bundler if present. Used by backends' default ``App/backend``
    /// implementations if not `nil`.
    static var metadata: AppMetadata? { get }

    /// The application's backend.
    var backend: Backend { get }

    /// The application's app storage provider, used for persisting ``AppStorage``
    /// data to disk.
    var appStorageProvider: StorageProvider { get }

    /// The content of the app.
    @SceneBuilder var body: Body { get }

    /// Creates an instance of the app.
    ///
    /// This initializer is run before anything else, so you can perform early
    /// setup tasks in here, such as opening a database or preparing a
    /// dependency injection library.
    init()

    /// Returns the log handler to use for log messages emitted by SwiftCrossUI
    /// and its backends.
    ///
    /// By default, SwiftCrossUI outputs log messages to standard error, but you
    /// can use any log handler you want by implementing this requirement.
    ///
    /// # See Also
    /// - <doc:Logging>
    static func logHandler(
        label: String,
        metadataProvider: Logger.MetadataProvider?
    ) -> any LogHandler
}

/// Force refresh the entire scene graph. Used by hot reloading. If you need to do
/// this in your own code then something has gone very wrong...
@MainActor
public var _forceRefresh: () -> Void = {}

/// Metadata embedded by Swift Bundler, if present. Loaded at app start up.
///
/// This will contain the app's metadata, if present, by the time ``App/init()``
/// gets called.
@MainActor
private var swiftBundlerAppMetadata: AppMetadata?

/// An error encountered when parsing Swift Bundler metadata.
private enum SwiftBundlerMetadataError: LocalizedError {
    case noExecutableURL
    case failedToReadExecutable
    case emptyMetadata
    case jsonNotDictionary(String)
    case missingAppIdentifier
    case missingAppVersion
    case badMetadataPointer

    var errorDescription: String? {
        switch self {
            case .noExecutableURL:
                "no executable URL"
            case .failedToReadExecutable:
                "executable failed to read itself (to extract metadata)"
            case .emptyMetadata:
                "metadata found but was empty"
            case .jsonNotDictionary:
                "root metadata JSON value wasn't an object"
            case .missingAppIdentifier:
                "missing 'appIdentifier' (of type String)"
            case .missingAppVersion:
                "missing 'appVersion' (of type String)"
            case .badMetadataPointer:
                """
                bad metadata pointer returned by injected metadata function; \
                this causes segfaults on some systems so metadata parsing has \
                been skipped. update to a version of Swift Bundler newer than \
                commit 7b9c6a45fa5d0266985d45a3d12bc8d9fd729b84 to restore \
                metadata parsing
                """
        }
    }
}

extension App {
    /// Metadata loaded at app start up.
    ///
    /// This will contain the app's metadata, if present, by the time
    /// ``App/init()`` gets called.
    public static var metadata: AppMetadata? {
        swiftBundlerAppMetadata
    }

    /// The default log handler for apps which don't specify a custom one.
    ///
    /// This simply outputs logs to standard error.
    ///
    /// # See Also
    /// - <doc:Logging>
    public static func logHandler(
        label: String,
        metadataProvider: Logger.MetadataProvider?
    ) -> any LogHandler {
        var logHandler = StreamLogHandler.standardError(label: label)
        #if DEBUG
            logHandler.logLevel = .debug
        #else
            logHandler.logLevel = .info
        #endif
        return logHandler
    }

    /// The default app storage provider for apps which don't specify a
    /// custom one.
    ///
    /// This uses `UserDefaults` on all platforms.
    public var appStorageProvider: some AppStorageProvider {
        DefaultAppStorageProvider()
    }

    /// Runs the application.
    public static func main() {
        extractMetadataAndInitializeLogging()
        let app = Self()
        let _app = _App(app)
        _forceRefresh = {
            app.backend.runInMainThread {
                _app.refreshSceneGraph()
            }
        }
        _app.run()
    }

    private static func extractMetadataAndInitializeLogging() {
        // Extract metadata _before_ initializing the logger, so users can use
        // said metadata when declaring a custom logger.
        let result = Result {
            swiftBundlerAppMetadata = try extractSwiftBundlerMetadata()
        }

        _logger = Logger(label: "SwiftCrossUI", factory: logHandler(label:metadataProvider:))
        #if DEBUG
            _logger!.logLevel = .debug
        #endif

        // Check for an error once the logger is ready.
        if case .failure(let error) = result {
            logger.error(
                "failed to extract swift-bundler metadata: \(error.localizedDescription)"
            )
        }
    }
}

// MARK: - Metadata extraction

#if SWIFT_BUNDLER_METADATA
    import SwiftCrossUIMetadataSupport
#endif

extension App {
    private static func extractSwiftBundlerMetadata() throws -> AppMetadata? {
        // If we know for a fact we've been compiled using swift-bundler's new metadata
        // insertion method, try that; otherwise, fall back to the old method, which
        // is safe to try even if we weren't compiled with swift-bundler at all.
        #if SWIFT_BUNDLER_METADATA
            guard let pointer = _getSwiftBundlerMetadata() else { return nil }

            // Make a best-effort attempt to detect whether `pointer` points to
            // something on the stack. If it does then the metadata was injected
            // by a version of Swift Bundler from before PR #129, which resolved
            // a segfault caused by accidentally returning a temporary stack
            // pointer rather than a pointer to the global metadata variable
            // itself. We exit early to avoid the segfault.
            let dummy = 0
            try withUnsafePointer(to: dummy) { stackPointer in
                // The 0x1000 threshold is kind of arbitrary. It just has to be
                // big enough that it includes this stack frame and the next
                // while not including anything that isn't the stack. In theory
                // the value could probably be much higher, but it doesn't have
                // to be so it's safer not to imo.
                let diff = UnsafeRawPointer(stackPointer) - pointer
                if abs(diff) < 0x1000 {
                    throw SwiftBundlerMetadataError.badMetadataPointer
                }
            }

            let datas = pointer.assumingMemoryBound(to: [[UInt8]].self).pointee
            guard let jsonBytes = datas.first else {
                throw SwiftBundlerMetadataError.emptyMetadata
            }
            let jsonData = Data(jsonBytes)
        #else
            func parseBigEndianUInt64(
                startingAt startIndex: Int,
                in data: Data
            ) -> UInt64 {
                data[startIndex..<(startIndex + 8)].withUnsafeBytes { pointer in
                    let bigEndianValue = pointer.assumingMemoryBound(to: UInt64.self)
                        .baseAddress!.pointee
                    return UInt64(bigEndian: bigEndianValue)
                }
            }

            guard let executable = Bundle.main.executableURL else {
                throw SwiftBundlerMetadataError.noExecutableURL
            }

            guard let data = try? Data(contentsOf: executable) else {
                throw SwiftBundlerMetadataError.failedToReadExecutable
            }

            // Check if executable has Swift Bundler metadata magic bytes.
            guard data.suffix(8) == Array("SBUNMETA".utf8) else { return nil }

            let lengthStart = data.count - 16
            let jsonLength = parseBigEndianUInt64(startingAt: lengthStart, in: data)
            let jsonStart = lengthStart - Int(jsonLength)
            let jsonData = data[jsonStart..<lengthStart]
        #endif

        // Manually parsed due to the `additionalMetadata` field (which would
        // require a lot of boilerplate code to parse with Codable).
        let jsonValue = try JSONSerialization.jsonObject(with: jsonData)
        guard let json = jsonValue as? [String: Any] else {
            throw SwiftBundlerMetadataError.jsonNotDictionary(String(describing: jsonValue))
        }
        guard let identifier = json["appIdentifier"] as? String else {
            throw SwiftBundlerMetadataError.missingAppIdentifier
        }
        guard let version = json["appVersion"] as? String else {
            throw SwiftBundlerMetadataError.missingAppVersion
        }
        let additionalMetadata = json["additionalMetadata"] as? [String: Any] ?? [:]

        return AppMetadata(
            identifier: identifier,
            version: version,
            additionalMetadata: additionalMetadata
        )
    }
}
