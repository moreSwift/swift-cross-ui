import Testing

import DummyBackend
@testable import SwiftCrossUI

@Suite("Testing for stack layouts")
struct StackLayoutTests {
    let backend: DummyBackend
    let window: DummyBackend.Window
    let environment: EnvironmentValues

    @MainActor
    init() {
        backend = DummyBackend()
        window = backend.createWindow(withDefaultSize: nil)
        environment = EnvironmentValues(backend: backend).with(\.window, window)
    }

    @MainActor
    @Test("Empty ScrollView should still be greedy in stack (#328)")
    func emptyScrollViewInStack() {
        let view = VStack {
            Text("Dummy")
            ScrollView {}
        }

        let height = 200.0
        let result = computeLayout(of: view, proposedSize: ProposedViewSize(100, height))

        #expect(result.size.height == height)
    }

    @MainActor
    @Test("Fixed size stack redistributes space (#453)")
    func fixedSizeStackSpaceRedistribution() {
        let view = VStack(spacing: 0) {
            Text("Dummy")
            Color.blue
            Text("Dummy")
        }.fixedSize()

        let node = committedNode(for: view, proposedSize: ProposedViewSize(200, 200))

        let fixedSizeWidget = node.widget.getChildren()[0]
        let children = fixedSizeWidget.getChildren()
        let text1 = children[0]
        let color = children[1]
        let text2 = children[2]

        // Ensure #453 resolved
        #expect(text1.size.x == color.size.x)

        // Sanity checks
        #expect(text1.size == text2.size)
    }

    @MainActor
    @Test("Spacer layout priority")
    func spacerLayoutPriority() {
        let strings = ["AA", "AAAA"]
        let view = HStack(spacing: 0) {
            Text(strings[0])
            Spacer(minLength: 0)
            Text(strings[1])
        }

        let lineHeight = environment.resolvedFont.lineHeight

        let textResults = strings.map(Text.init(_:)).map { computeLayout(of: $0) }
        let minimumWidthWithoutWrapping = textResults.map(\.size.vector.x).reduce(0, +)
        let proposedSize = ProposedViewSize(
            Double(minimumWidthWithoutWrapping),
            lineHeight * 2
        )
        let result = computeLayout(of: view, proposedSize: proposedSize)

        // No wrapping, and perfect fit
        #expect(result.size.height == environment.resolvedFont.lineHeight)
        #expect(result.size.vector.x == minimumWidthWithoutWrapping)
    }

    // MARK: Helpers

    @MainActor
    func computeLayout<V: View>(
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
    func committedNode<V: View>(
        for view: V,
        proposedSize: ProposedViewSize = .unspecified
    ) -> ViewGraphNode<V, DummyBackend> {
        let node = ViewGraphNode(for: view, backend: backend, environment: environment)
        _ = node.computeLayout(proposedSize: proposedSize, environment: environment)
        _ = node.commit()
        return node
    }
}
