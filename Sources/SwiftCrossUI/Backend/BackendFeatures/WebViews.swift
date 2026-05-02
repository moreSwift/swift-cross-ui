import Foundation

extension BackendFeatures {
    /// Backend methods for web views.
    ///
    /// These are used by ``WebView``.
    @MainActor
    public protocol WebViews: Core {
        /// Create a web view.
        ///
        /// - Returns: A web view.
        func createWebView() -> Widget

        /// Update a web view to reflect the given environment and use the given
        /// navigation handler.
        ///
        /// - Parameters:
        ///   - webView: The web view.
        ///   - environment: The current environment.
        ///   - onNavigate: The action to perform when a navigation occurs.
        func updateWebView(
            _ webView: Widget,
            environment: EnvironmentValues,
            onNavigate: @escaping (URL) -> Void
        )

        /// Navigates a web view to a given URL.
        ///
        /// - Parameters:
        ///   - webView: The web view.
        ///   - url: The URL to navigate `webView` to.
        func navigateWebView(_ webView: Widget, to url: URL)
    }
}
