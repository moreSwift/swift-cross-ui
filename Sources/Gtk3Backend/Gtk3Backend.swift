import CGtk3
import Gtk3CHelpers
import Foundation
import Gtk3
@_spi(Backends) import SwiftCrossUI

extension App {
    public typealias Backend = Gtk3Backend

    public var backend: Gtk3Backend {
        Gtk3Backend(appIdentifier: Self.metadata?.identifier)
    }
}

@MainActor
public final class Gtk3Backend {
    var gtkApp: Application

    /// A window to be returned on the next call to ``Gtk3Backend/createWindow``.
    /// This is necessary because Gtk creates a root window no matter what, and
    /// this needs to be returned on the first call to `createWindow`.
    var precreatedWindow: Window?

    /// All current windows associated with the application. Doesn't include the
    /// precreated window until it gets 'created' via `createWindow`.
    var windows: [Window] = []

    var rootEnvironmentChangeHandler: (() -> Void)?

    var borderedButtonPadding: SIMD2<Int>?

    /// Creates a backend instance. If `appIdentifier` is `nil`, the default
    /// identifier `com.example.SwiftCrossUIApp` is used.
    public init(appIdentifier: String?) {
        gtkApp = Application(
            applicationId: appIdentifier ?? "com.example.SwiftCrossUIApp",
            flags: SHIM_G_APPLICATION_HANDLES_OPEN
        )
        gtkApp.registerSession = true
    }

    private struct LogLocation: Hashable, Equatable {
        let file: String
        let line: Int
        let column: Int
    }

    private var logsPerformed: Set<LogLocation> = []

    func debugLogOnce(
        _ message: String,
        file: String = #file,
        line: Int = #line,
        column: Int = #column
    ) {
        #if DEBUG
            let location = LogLocation(file: file, line: line, column: column)
            if logsPerformed.insert(location).inserted {
                logger.notice("\(message)")
            }
        #endif
    }

    static func cssProperties(
        for environment: EnvironmentValues,
        isControl: Bool = false
    ) -> [CSSProperty] {
        var properties: [CSSProperty] = []
        properties.append(
            .foregroundColor(
                environment.suggestedForegroundColor.resolve(in: environment).gtkColor
            )
        )
        let font = environment.resolvedFont
        switch font.identifier.kind {
            case .system:
                properties.append(.fontSize(font.pointSize))
                let weightNumber =
                    switch font.weight {
                        case .ultraLight:
                            100
                        case .thin:
                            200
                        case .light:
                            300
                        case .regular:
                            400
                        case .medium:
                            500
                        case .semibold:
                            600
                        case .bold:
                            700
                        case .heavy:
                            800
                        case .black:
                            900
                    }
                properties.append(.fontWeight(weightNumber))
                switch font.design {
                    case .monospaced:
                        properties.append(.fontFamily("monospace"))
                    case .default:
                        break
                }
        }

        if font.isItalic {
            properties.append(.fontStyle("italic"))
        }

        if isControl {
            properties.append(contentsOf: controlCSS(for: environment))
        }

        return properties
    }

    static func controlCSS(for environment: EnvironmentValues) -> [CSSProperty]{
        let themeDependentCSS: [CSSProperty] = switch environment.colorScheme {
            case .light:
                [
                    .border(color: Color.eightBit(209, 209, 209), width: 1),
                    .backgroundColor(Color(1, 1, 1, 1)),
                    .caretColor(Color.eightBit(139, 142, 143))
                ]
            case .dark:
                [
                    .border(color: Color.eightBit(32, 32, 32), width: 1),
                    .backgroundColor(Color(1, 1, 1, 0.1)),
                    .caretColor(Color(1, 1, 1))
                ]
        }
        return themeDependentCSS + [.init(key: "box-shadow", value: "none")]
    }
}
