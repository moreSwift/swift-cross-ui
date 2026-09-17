import DummyBackend
import Testing
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
        let node = ViewGraphNode(for: view, backend: backend, environment: environment)
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
        let node = ViewGraphNode(for: view, backend: backend, environment: environment)
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
        let node = ViewGraphNode(for: view, backend: backend, environment: environment)
        _ = node.computeLayout(proposedSize: proposedSize, environment: environment)
        _ = node.commit()
        return node
    }

    @MainActor
    static func computeAndCommitExisting<V: View>(
        node: ViewGraphNode<V, DummyBackend>,
        with view: V,
        proposedSize: ProposedViewSize = .unspecified
    ) -> ViewGraphNode<V, DummyBackend> {
        _ = node.computeLayout(with: view, proposedSize: proposedSize, environment: environment)
        _ = node.commit()
        return node
    }
}

extension DummyBackend.Widget {
    /// Returns the first widget in the hierarchy matching a filter depth first or nil if no widget was found.
    func first<T: DummyBackend.Widget>(where filter: (T) -> Bool) -> T? {
        if let self = self as? T, filter(self) {
            return self
        }

        for child in getChildren() {
            let match: T? = child.first(where: filter)
            if let match {
                return match
            }
        }

        return nil
    }

    /// Returns the first widget in the hierarchy matching a filter depth first.
    ///
    /// Throws if no widget was found.
    func locateDescendant<T: DummyBackend.Widget>(where filter: (T) -> Bool) throws -> T {
        let first: T? = first(where: filter)
        guard let first else {
            throw ViewGraphHelpers.Error.failedToFindDescendant
        }
        return first
    }

    /// Returns all widgets in the hierarchy matching a filter recursively.
    func filter<T: DummyBackend.Widget>( _ isIncluded: (T) -> Bool) -> [T] {
        var matches = [T]()

        if let self = self as? T, isIncluded(self) {
            matches.append(self)
        }

        for child in getChildren() {
            matches.append(contentsOf: child.filter(isIncluded))
        }

        return matches
    }
}
