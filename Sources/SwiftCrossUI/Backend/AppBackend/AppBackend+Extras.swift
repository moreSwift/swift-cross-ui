import Foundation

extension AppBackend {
    /// Backend methods for handling incoming URLs.
    ///
    /// These are used by ``View/onOpenURL(perform:)``.
    @MainActor
    public protocol IncomingURLs: Core {
        /// Sets the handler for URLs directed to the application (e.g. URLs
        /// associated with a custom URL scheme).
        ///
        /// - Parameter action: The incoming URL handler.
        func setIncomingURLHandler(to action: @escaping (URL) -> Void)
    }

    /// Backend methods for opening URLs in external apps.
    ///
    /// These are used by ``EnvironmentValues/openURL``.
    @MainActor
    public protocol ExternalURLs: Core {
        /// Opens an external URL in the system browser or app registered for the
        /// URL's protocol.
        ///
        /// - Parameter url: The URL to open.
        func openExternalURL(_ url: URL) throws
    }

    /// Backend methods for revealing files in the system's file manager.
    ///
    /// These are used by ``EnvironmentValues/revealFile``.
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
        /// - Parameter submenus: The submenus of the global menu.
        func setApplicationMenu(_ submenus: [ResolvedMenu.Submenu])
    }

    /// Backend methods for setting widgets' corner radii.
    ///
    /// These are used by ``View/cornerRadius(_:)``.
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

    /// Backend methods for tooltips.
    ///
    /// These are used by ``View/help(_:)``.
    @MainActor
    public protocol Tooltips: Core {
        /// Create a container capable of showing a textual tooltip.
        ///
        /// If no container is necessary, this method is allowed to return `child`
        /// unmodified.
        ///
        /// - Parameters:
        ///   - child: The widget being wrapped to show a tooltip over.
        func createTooltipContainer(wrapping child: Widget) -> Widget

        /// Update the tooltip shown by a widget.
        ///
        /// - Parameters:
        ///   - widget: The widget to update the tooltip for. Will always have been
        ///     created by ``createTooltipContainer(wrapping:)``.
        ///   - tooltip: The text to be shown on hover.
        func updateTooltipContainer(_ widget: Widget, tooltip: String)
    }
}
