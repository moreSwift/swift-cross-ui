import AppKit
import SwiftCrossUI
import WebKit

extension AppKitBackend {
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

final class CustomWKWebView: WKWebView {
    var strongNavigationDelegate = CustomWKNavigationDelegate()
}

final class CustomWKNavigationDelegate: NSObject, WKNavigationDelegate {
    var onNavigate: ((URL) -> Void)?

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        guard let url = webView.url else {
            logger.warning("web view has no URL")
            return
        }

        onNavigate?(url)
    }
}
