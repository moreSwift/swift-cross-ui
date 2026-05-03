extension BackendFeatures {
    /// Backend methods for setting an app's global menu.
    ///
    /// These are used by ``Scene/commands(_:)`` and related types.
    @MainActor
    public protocol ApplicationMenus: Core {
        /// Sets the application's global menu.
        ///
        /// Some backends may make use of the host platform's global menu bar
        /// (such as macOS's menu bar), and others may render their own menu bar
        /// within the application.
        ///
        /// - Parameters:
        ///   - submenus: The submenus of the global menu.
        ///   - environment: The menu's environment.
        func setApplicationMenu(
            _ submenus: [ResolvedMenu.Submenu],
            environment: EnvironmentValues
        )
    }
}
