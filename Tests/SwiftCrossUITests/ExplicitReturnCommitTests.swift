import Testing

import DummyBackend
@testable @_spi(Backends) import SwiftCrossUI

/// A body the `@ViewBuilder` transform rewrites.
struct BuilderBodyButton: View {
    var body: some View {
        Button("tap") {}
    }
}

/// An explicit `return` opts the body out of the `@ViewBuilder` transform, so
/// `body` is the bare view rather than a builder wrapper.
struct ExplicitReturnBodyButton: View {
    var body: some View {
        return Button("tap") {}
    }
}

@Suite("View bodies that opt out of the ViewBuilder transform")
struct ExplicitReturnCommitTests {
    let backend: DummyBackend
    let window: DummyBackend.Window
    let environment: EnvironmentValues

    @MainActor
    init() {
        backend = DummyBackend()
        window = backend.createWindow(withDefaultSize: nil, id: "window")
        environment = EnvironmentValues(backend: backend).with(\.window, window)
    }

    @MainActor
    func button<V: View>(of view: V) -> DummyBackend.Button? {
        let node = ViewGraphNode(for: view, backend: backend, environment: environment)
        _ = node.computeLayout(
            proposedSize: ProposedViewSize(200, 200),
            environment: environment
        )
        _ = node.commit()

        func firstButton(in widget: DummyBackend.Widget) -> DummyBackend.Button? {
            if let button = widget as? DummyBackend.Button {
                return button
            }
            return widget.getChildren().lazy.compactMap(firstButton(in:)).first
        }

        return firstButton(in: node.widget)
    }

    @MainActor
    @Test("A builder-shaped body renders a working button")
    func builderBodyRendersButton() throws {
        let button = try #require(button(of: BuilderBodyButton()))

        #expect(button.action != nil)
        #expect(button.size == SIMD2<Int>(24, 16))
    }

    @MainActor
    @Test("An explicit-return body renders a working button")
    func explicitReturnBodyRendersButton() throws {
        let button = try #require(button(of: ExplicitReturnBodyButton()))

        #expect(button.action != nil)
        #expect(button.size == SIMD2<Int>(24, 16))
    }
}
