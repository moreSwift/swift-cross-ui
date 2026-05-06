package dev.swiftcrossui.androidbackend

import android.app.Activity
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient

class CustomWebView(activity: Activity): WebView(activity) {
    var onNavigate: SwiftAction? = null

    var loadingUrl: String? = null
        private set
    
    init {
        webViewClient = object : WebViewClient() {
            override fun shouldOverrideUrlLoading(
                webView: WebView,
                request: WebResourceRequest
            ): Boolean {
                loadingUrl = request.url?.toString()
                onNavigate?.call()
                return false
            }
        }

        settings.javaScriptEnabled = true
    }
    
    override fun loadUrl(url: String) {
        loadingUrl = url
        super.loadUrl(url)
    }
}
