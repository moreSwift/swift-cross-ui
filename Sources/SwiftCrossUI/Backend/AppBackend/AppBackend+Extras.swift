import Foundation

extension AppBackend {
    @MainActor
    public protocol IncomingURLs: Core {
        /// Sets the handler for URLs directed to the application (e.g. URLs
        /// associated with a custom URL scheme).
        ///
        /// - Parameter action: The incoming URL handler.
        func setIncomingURLHandler(to action: @escaping (URL) -> Void)
    }

    @MainActor
    public protocol ExternalURLs: Core {
        /// Opens an external URL in the system browser or app registered for the
        /// URL's protocol.
        ///
        /// - Parameter url: The URL to open.
        func openExternalURL(_ url: URL) throws
    }

    @MainActor
    public protocol RevealFile: Core {
        /// Reveals a file in the system's file manager.
        ///
        /// This typically opens the file's enclosing directory and highlights the
        /// file.
        ///
        /// - Parameter url: The URL of the file to reveal.
        func revealFile(_ url: URL) throws
    }

    @MainActor
    public protocol ApplicationMenus: Core {
        /// Sets the application's global menu.
        ///
        /// Some backends may make use of the host platform's global menu bar
        /// (such as macOS's menu bar), and others may render their own menu bar
        /// within the application.
        ///
        /// - Parameter submenus: The submenus of the global menu.
        func setApplicationMenu(_ submenus: [ResolvedMenu.Submenu])
    }

    @MainActor
    public protocol CornerRadius: Core {
        /// Sets the corner radius of a widget (any widget). Should affect the view's border radius
        /// as well.
        ///
        /// - Parameters:
        ///   - widget: The widget to set the corner radius of.
        ///   - radius: The corner radius.
        func setCornerRadius(of widget: Widget, to radius: Int)
    }
}

// MARK: Default Implementations

extension AppBackend.CornerRadius {
    public func setCornerRadius(of widget: Widget, to radius: Int) {
        fatalError("\(Self.self): \(#function) not implemented")
    }
}
