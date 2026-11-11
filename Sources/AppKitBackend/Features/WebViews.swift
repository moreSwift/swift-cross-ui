import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.WebViews {
    public func createWebView() -> Widget {
        let webView = CustomWKWebView()
        webView.navigationDelegate = webView.strongNavigationDelegate
        return webView
    }

    public func updateWebView(
        _ webView: Widget,
        environment: EnvironmentValues,
        onNavigate: @escaping (URL) -> Void
    ) {
        let webView = webView as! CustomWKWebView
        webView.strongNavigationDelegate.onNavigate = onNavigate
    }

    public func navigateWebView(_ webView: Widget, to url: URL) {
        let webView = webView as! CustomWKWebView
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
