import Foundation

extension Icon: ElementaryView {
    @CastBackend<BackendFeatures.Icons>(returnsWidget: true)
    public func asWidget<Backend: BaseAppBackend>(backend: Backend) -> Backend.Widget {
        return backend.createIconView()
    }

    @CastBackend<BackendFeatures.Icons>
    func computeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        return ViewLayoutResult.leafView(
            size: ViewSize(backend.naturalSize(of: widget))
        )
    }

    @CastBackend<BackendFeatures.Icons>
    func commit<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        backend.updateIconView(widget, icon: self, environment: environment)
    }
}
