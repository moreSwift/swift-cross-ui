import CGtk3
import Foundation
import Gtk3
@_spi(Backends) import SwiftCrossUI

extension Gtk3Backend: BackendFeatures.Core {
    public var deviceClass: DeviceClass { .desktop }

    public convenience init() {
        self.init(appIdentifier: nil)
    }

    public func runMainLoop(_ callback: @escaping @MainActor () -> Void) {
        gtkApp.run { window in
            self.precreatedWindow = window

            let provider = CSSProvider()
            provider.loadCss(
                from: """
                    .dialog-vbox .horizontal .vertical {
                        padding-top: 11px;
                        margin-bottom: -10px;
                    }

                    @binding-set DisableEscape {
                        unbind "Escape";
                    }

                    messagedialog {
                        -gtk-key-bindings: DisableEscape;
                    }

                    list {
                        background: none;
                    }

                    list > row {
                        padding: 0;
                        min-height: 0;
                    }

                    .navigation-sidebar {
                        margin: 0;
                        padding: 0;
                    }

                    .navigation-sidebar > row {
                        margin: 0;
                        padding: 0;
                    }

                    textview text {
                        background: none;
                    }
                    """
            )
            gtk_style_context_add_provider_for_screen(
                gdk_screen_get_default(),
                OpaquePointer(provider.pointer),
                guint(GTK_STYLE_PROVIDER_PRIORITY_APPLICATION)
            )

            #if !os(macOS)
                Self.mainRunLoopTicklingLoop()
            #endif

            callback()
        }
    }

    private static func mainRunLoopTicklingLoop(nextDelayMilliseconds: Int? = nil) {
        Self.runInMainThread(afterMilliseconds: nextDelayMilliseconds ?? 50) {
            let nextDate = RunLoop.main.limitDate(forMode: .default)
            // This isn't expected to be nil, but if it is we can just loop
            // again quickly with the default delay.
            let nextDelay = nextDate.map {
                return max(min(Int($0.timeIntervalSinceNow * 1000), 50), 0)
            }
            mainRunLoopTicklingLoop(nextDelayMilliseconds: nextDelay)
        }
    }

    public func runInMainThread(action: @escaping @MainActor () -> Void) {
        let action = ThreadActionContext(action: action)
        g_idle_add_full(
            0,
            { context in
                guard let context else {
                    fatalError("Gtk action callback called without context")
                }

                MainActor.assumeIsolated {
                    let action = Unmanaged<ThreadActionContext>.fromOpaque(context)
                        .takeUnretainedValue()
                    action.action()
                }

                return 0
            },
            Unmanaged<ThreadActionContext>.passRetained(action).toOpaque(),
            { _ in }
        )
    }

    private static func runInMainThread(
        afterMilliseconds delay: Int,
        action: @escaping @MainActor () -> Void
    ) {
        let action = ThreadActionContext(action: action)
        g_timeout_add_full(
            0,
            guint(max(0, delay)),
            { context in
                guard let context else {
                    fatalError("Gtk action callback called without context")
                }

                MainActor.assumeIsolated {
                    let action = Unmanaged<ThreadActionContext>.fromOpaque(context)
                        .takeUnretainedValue()
                    action.action()
                }

                // Cancel the recurring timeout after one iteration
                return 0
            },
            Unmanaged<ThreadActionContext>.passRetained(action).toOpaque(),
            { _ in }
        )
    }

    public func computeRootEnvironment(defaultEnvironment: EnvironmentValues) -> EnvironmentValues {
        defaultEnvironment
            .with(\.appPhase, windows.contains(where: \.isActive) ? .active : .inactive)
    }

    public func setRootEnvironmentChangeHandler(
        to action: @escaping @Sendable @MainActor () -> Void
    ) {
        // TODO: React to theme changes
        self.rootEnvironmentChangeHandler = action
    }
}
