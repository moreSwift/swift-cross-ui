import Testing

import DummyBackend
@testable import SwiftCrossUI

@Suite("Testing for stack layouts")
struct StackLayoutTests {
    @MainActor
    @Test("Empty ScrollView should still be greedy in stack (#328)")
    func emptyScrollViewInStack() {
        let backend = DummyBackend()
        let window = backend.createWindow(withDefaultSize: nil)
        let environment = EnvironmentValues(backend: backend).with(\.window, window)

        let view = VStack {
            Text("Dummy")
            ScrollView {}
        }

        let height = 200.0
        let node = ViewGraphNode(for: view, backend: backend, environment: environment)
        let result = node.computeLayout(
            proposedSize: ProposedViewSize(100, height),
            environment: environment
        )

        #expect(result.size.height == height)
    }

    @MainActor
    @Test("Fixed size stack redistributes space (#453)")
    func fixedSizeStackSpaceRedistribution() {
        let backend = DummyBackend()
        let window = backend.createWindow(withDefaultSize: nil)
        let environment = EnvironmentValues(backend: backend).with(\.window, window)

        let view = VStack(spacing: 0) {
            Text("Dummy")
            Color.blue
            Text("Dummy")
        }.fixedSize()

        let node = ViewGraphNode(for: view, backend: backend, environment: environment)
        _ = node.computeLayout(
            proposedSize: ProposedViewSize(200, 200),
            environment: environment
        )

        _ = node.commit()

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
}
