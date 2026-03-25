import Foundation

/// A web view.
@available(tvOS, unavailable)
public struct WebView: ElementaryView {
    /// The ideal size of a WebView.
    private static let idealSize = ViewSize(10, 10)

    @State var currentURL: URL?
    @Binding var url: URL

    /// Creates a web view.
    ///
    /// - Parameter url: A binding to the web view's URL.
    public init(_ url: Binding<URL>) {
        _url = url
    }

    func asWidget<Backend: AppBackend_WebView>(backend: Backend) -> Backend.Widget {
        backend.createWebView()
    }

    func computeLayout<Backend: AppBackend_Core>(
        _ widget: Backend.Widget,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        let size = proposedSize.replacingUnspecifiedDimensions(by: Self.idealSize)
        return ViewLayoutResult.leafView(size: size)
    }

    func commit<Backend: AppBackend_WebView>(
        _ widget: Backend.Widget,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        if url != currentURL {
            backend.navigateWebView(widget, to: url)
            currentURL = url
        }
        backend.updateWebView(widget, environment: environment) { destination in
            currentURL = destination
            url = destination
        }
        backend.setSize(of: widget, to: layout.size.vector)
    }
}
