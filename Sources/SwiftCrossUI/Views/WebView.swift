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

    func asWidget<Backend: AppBackend.Base>(backend: Backend) -> Backend.Widget {
        guard let backend = backend as? any AppBackend.WebViews else {
            fatalError("\(Backend.self) doesn't support web views")
        }

        return backend.createWebView() as! Backend.Widget
    }

    func computeLayout<Backend: AppBackend.Base>(
        _ widget: Backend.Widget,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        let size = proposedSize.replacingUnspecifiedDimensions(by: Self.idealSize)
        return ViewLayoutResult.leafView(size: size)
    }

    func commit<Backend: AppBackend.Base>(
        _ widget: Backend.Widget,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        func commit<Backend2: AppBackend.WebViews>(backend: Backend2) {
            let widget = widget as! Backend2.Widget
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

        let backend = backend as! any AppBackend.WebViews
        commit(backend: backend)
    }
}
