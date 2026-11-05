import Testing

import DummyBackend
@testable @_spi(Backends) import SwiftCrossUI

@Suite("Testing for stack layouts")
struct StackLayoutTests {
    @MainActor
    @Test("Empty ScrollView should still be greedy in stack (#328)")
    func emptyScrollViewInStack() {
        let view = VStack {
            Text("Dummy")
            ScrollView {}
        }

        let height = 200.0
        let result = ViewGraphHelpers.computeLayout(
            of: view,
            proposedSize: ProposedViewSize(100, height)
        )

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

        let node = ViewGraphHelpers.committedNode(
            for: view,
            proposedSize: ProposedViewSize(200, 200)
        )

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

        let lineHeight = ViewGraphHelpers.environment.resolvedFont.lineHeight

        let textResults = strings.map(Text.init(_:)).map {
            ViewGraphHelpers.computeLayout(of: $0)
        }
        let minimumWidthWithoutWrapping = textResults.map(\.size.vector.x).reduce(0, +)
        let proposedSize = ProposedViewSize(
            Double(minimumWidthWithoutWrapping),
            lineHeight * 2
        )
        let result = ViewGraphHelpers.computeLayout(of: view, proposedSize: proposedSize)

        // No wrapping, and perfect fit
        #expect(result.size.height == ViewGraphHelpers.environment.resolvedFont.lineHeight)
        #expect(result.size.vector.x == minimumWidthWithoutWrapping)
    }
}
