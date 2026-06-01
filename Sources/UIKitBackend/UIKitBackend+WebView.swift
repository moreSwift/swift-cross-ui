import SwiftCrossUI
import WebKit

/*
@available(iOS 8, *)
extension UIKitBackend {
    public func createWebView() -> Widget {
        WebViewWidget()
    }

    public func updateWebView(
        _ webView: Widget,
        environment: EnvironmentValues,
        onNavigate: @escaping (URL) -> Void
    ) {
        let webView = webView as! WebViewWidget
        webView.onNavigate = onNavigate
    }

    public func navigateWebView(_ webView: Widget, to url: URL) {
        let webView = webView as! WebViewWidget
        let request = URLRequest(url: url)
        webView.child.load(request)
    }
}

/// A wrapper for WKWebView. Acts as the web view's delegate as well.
@available(iOS 8, *)
final class WebViewWidget: WrapperWidget<WKWebView>, WKNavigationDelegate {
    var onNavigate: ((URL) -> Void)?

    init() {
        super.init(child: WKWebView())

        child.navigationDelegate = self
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        guard let url = webView.url else {
            print("warning: Web view has no URL")
            return
        }

        onNavigate?(url)
    }
}*/
