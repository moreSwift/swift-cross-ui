import DummyBackend
@testable @_spi(Backends) import SwiftCrossUI

enum ViewGraphHelpers {
    @MainActor
    static let backend = DummyBackend()

    @MainActor
    static let window = backend.createWindow(withDefaultSize: nil, id: "window")

    @MainActor
    static let environment = EnvironmentValues(backend: backend).with(\.window, window)

    @MainActor
    static func computeLayout<V: View>(
        of view: V,
        proposedSize: ProposedViewSize = .unspecified
    ) -> ViewLayoutResult {
        let node = ViewGraphNode(for: view, backend: backend, environment: environment)
        return node.computeLayout(
            proposedSize: proposedSize,
            environment: environment
        )
    }

    @MainActor
    static func committedNode<V: View>(
        for view: V,
        proposedSize: ProposedViewSize = .unspecified
    ) -> ViewGraphNode<V, DummyBackend> {
        let node = ViewGraphNode(for: view, backend: backend, environment: environment)
        _ = node.computeLayout(proposedSize: proposedSize, environment: environment)
        _ = node.commit()
        return node
    }
}
