@_spi(Backends) import SwiftCrossUI
import WebKit

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
