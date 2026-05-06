import Foundation
import Mutex

/// A simple app storage provider that uses `UserDefaults` to persist
/// data.
///
/// This works on all supported platforms.
public final class UserDefaultsAppStorageProvider: AppStorageProvider {
    private let observer = Mutex(UserDefaultsObserver())
    private final class UserDefaultsObserver: NSObject {
        var knownKeys: Set<String> = []
        var onChange: (@MainActor @Sendable (String) -> Void)? = nil

        func addObserver(forKey key: String) {
            if knownKeys.insert(key).inserted {
                UserDefaults.standard.addObserver(self, forKeyPath: key, context: nil)
            }
        }

        override func observeValue(
            forKeyPath keyPath: String?,
            of object: Any?,
            change: [NSKeyValueChangeKey : Any]?,
            context: UnsafeMutableRawPointer?
        ) {
            guard let key = keyPath, let onChange else { return }
            Task { @MainActor in onChange(key) }
        }

        deinit {
            for key in knownKeys {
               UserDefaults.standard.removeObserver(self, forKeyPath: key, context: nil)
            }
        }
    }

    public func persistValue<Value: Codable>(_ value: Value, forKey key: String) throws {
        observer.withLock { $0.addObserver(forKey: key) }

        let jsonData = try JSONEncoder().encode(value)
        let jsonString = String.init(data: jsonData, encoding: .utf8)
        UserDefaults.standard.set(jsonString, forKey: key)

        // NB: The UserDefaults store isn't automatically synced to disk on
        // Linux and Windows.
        // https://github.com/swiftlang/swift-corelibs-foundation/issues/4837
        #if os(Linux) || os(Windows)
            UserDefaults.standard.synchronize()
        #endif
    }

    public func retrieveValue<Value: Codable>(ofType: Value.Type, forKey key: String) -> Value? {
        observer.withLock { $0.addObserver(forKey: key) }

        guard let string = UserDefaults.standard.string(forKey: key),
            let data = string.data(using: .utf8),
            let value = try? JSONDecoder().decode(Value.self, from: data)
        else {
            return nil
        }
        return value
    }

    public func listenToChanges(_ action: @MainActor @Sendable @escaping (String) -> Void) {
        observer.withLock { $0.onChange = action }
    }
}
