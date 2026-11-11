import DummyBackend
@testable @_spi(Backends) import SwiftCrossUI

enum ViewGraphHelpers {
    enum Error: Swift.Error {
        case failedToFindDescendant
    }

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
        let node = makeNode(for: view)
        return node.computeLayout(
            proposedSize: proposedSize,
            environment: environment
        )
    }

    @MainActor
    static func computeLayoutAndNode<V: View>(
        of view: V,
        proposedSize: ProposedViewSize = .unspecified
    ) -> (ViewLayoutResult, ViewGraphNode<V, DummyBackend>) {
        let node = makeNode(for: view)
        return (
            node.computeLayout(
                proposedSize: proposedSize,
                environment: environment
            ),
            node
        )
    }

    @MainActor
    static func committedNode<V: View>(
        for view: V,
        proposedSize: ProposedViewSize = .unspecified
    ) -> ViewGraphNode<V, DummyBackend> {
        let node = makeNode(for: view)
        _ = node.computeLayout(proposedSize: proposedSize, environment: environment)
        _ = node.commit()
        return node
    }

    @MainActor
    static func computeAndCommitExistingNode<V: View>(
        _ node: ViewGraphNode<V, DummyBackend>,
        with view: V,
        proposedSize: ProposedViewSize = .unspecified
    ) -> ViewLayoutResult {
        let result = node.computeLayout(
            with: view,
            proposedSize: proposedSize,
            environment: environment
        )
        _ = node.commit()
        return result
    }

    @MainActor
    static func makeNode<V: View>(for view: V) -> ViewGraphNode<V, DummyBackend> {
        ViewGraphNode(for: view, backend: backend, environment: environment)
    }
}
