import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.Core {
    public var deviceClass: DeviceClass { DeviceClass.desktop }

    public func runMainLoop(_ callback: @escaping @MainActor () -> Void) {
        // Immediately set up the default menus so that the Window menu can populate
        // correctly.
        MenuBar.setUpMenuBar(extraMenus: [])

        callback()
        NSApplication.shared.activate(ignoringOtherApps: true)
        NSApplication.shared.run()
    }

    public func runInMainThread(action: @escaping @MainActor () -> Void) {
        DispatchQueue.main.async {
            action()
        }
    }

    public func computeRootEnvironment(defaultEnvironment: EnvironmentValues) -> EnvironmentValues {
        let isDark = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
        return
            defaultEnvironment
                .with(\.colorScheme, isDark ? .dark : .light)
                .with(\.appPhase, NSApplication.shared.isActive ? .active : .inactive)
    }

    public func setRootEnvironmentChangeHandler(
        to action: @escaping @Sendable @MainActor () -> Void
    ) {
        DistributedNotificationCenter.default.addObserver(
            forName: .AppleInterfaceThemeChangedNotification,
            object: nil,
            queue: OperationQueue.main
        ) { _ in
            Task { @MainActor in
                action()
            }
        }

        // This doesn't strictly affect the root environment, but it does require us
        // to re-compute the app's layout, and this is how backends should trigger top
        // level updates.
        DistributedNotificationCenter.default.addObserver(
            forName: NSScroller.preferredScrollerStyleDidChangeNotification,
            object: nil,
            queue: OperationQueue.main
        ) { _ in
            // Self.scrollBarWidth has changed
            Task { @MainActor in
                action()
            }
        }

        NotificationCenter.default.addObserver(
            forName: .NSSystemTimeZoneDidChange,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                action()
            }
        }

        // For updating views that rely on `appPhase`
        NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                action()
            }
        }
        NotificationCenter.default.addObserver(
            forName: NSApplication.didResignActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                action()
            }
        }
    }
}

extension Notification.Name {
    static let AppleInterfaceThemeChangedNotification = Notification.Name(
        "AppleInterfaceThemeChangedNotification"
    )
}
