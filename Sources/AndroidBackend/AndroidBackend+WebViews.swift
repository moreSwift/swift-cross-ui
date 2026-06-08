import AndroidKit
import Foundation
import SwiftCrossUI

extension AndroidBackend: BackendFeatures.WebViews {
    public func createWebView() -> Widget {
        CustomWebView(Self.activity, environment: Self.env).as(AndroidKit.View.self)!
    }

    public func updateWebView(
        _ webView: Widget,
        environment: EnvironmentValues,
        onNavigate: @escaping (URL) -> Void
    ) {
        let webView = webView.as(CustomWebView.self)!
        webView.setOnNavigate(SwiftAction(environment: Self.env) {
            if let javaString = webView.getLoadingUrl() {
                guard let url = URL(string: javaString.toString()) else {
                    log("Failed to convert Uri to Foundation.URL: \(javaString)")
                    return
                }
                onNavigate(url)
            }
        })
    }

    public func navigateWebView(_ webView: Widget, to url: URL) {
        let webView = webView.as(CustomWebView.self)!
        webView.loadUrl(url.absoluteString)
    }
}
