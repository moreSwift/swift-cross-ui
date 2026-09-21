import Testing

import DummyBackend
@testable @_spi(Backends) import SwiftCrossUI

@Suite("Testing for ForEach")
struct ForEachTests {
    @MainActor
    @Test("Duplicate ids", .bug("https://github.com/moreSwift/swift-cross-ui/issues/456"))
    func duplicateIds() {
        let view = ForEach([1, 1], id: \.self) { x in
            Text("\(x)")
        }

        // Commit will crash if the duplicate identifiers bug happens.
        let node = ViewGraphHelpers.committedNode(for: view)

        // Re-layout the view, because the nature of the duplicate handling bug changed
        // depending on the existing set of nodes before the update
        _ = ViewGraphHelpers.computeAndCommitExisting(
            node: node,
            with: view
        )
    }

    @MainActor
    @Test("Reordered children")
    func reorderedChildren() {
        func makeView(_ ids: [Int]) -> ForEach<[Int], Int, TupleView1<Text>> {
            ForEach(ids, id: \.self) { x in
                Text("\(x)")
            }
        }

        let values = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        var forEach = makeView(values)

        let node = ViewGraphHelpers.committedNode(for: forEach)

        // Initialize the state of each view to match its index
        let originalErasedNodes = node.children.erasedNodes
        let originalNodes = originalErasedNodes.map(\.node)
        let originalWidgets = node.widget.getChildren()

        #expect(originalNodes.count == values.count)
        #expect(originalWidgets.count == values.count)

        // let values =    [11, 1, 5, 3, 4, 2, 6, 7, 8, 9, 10]
        let newValues = [11, 1, 5, 6, 2, 4, 3]

        forEach = makeView(newValues)
        _ = ViewGraphHelpers.computeAndCommitExisting(
            node: node,
            with: forEach
        )

        let newErasedNodes = node.children.erasedNodes
        let newNodes = newErasedNodes.map(\.node)
        let newWidgets = node.widget.getChildren()

        // Sanity check
        #expect(newNodes.count == newValues.count)
        #expect(newWidgets.count == newValues.count)

        // Have we successfully re-used all nodes whose identifiers are present
        // in both values and newValues?
        for (originalNode, originalId) in zip(originalNodes, values) {
            for (newNode, newId) in zip(newNodes, newValues) {
                #expect(
                    (originalNode === newNode)
                        <=>
                        (originalId == newId)
                )
            }
        }

        // Have we successfully re-arranged the widgets to match the nodes?
        #expect(
            zip(originalWidgets, originalErasedNodes)
                .allSatisfy { $0.0 === $0.1.getWidget().into() }
        )
        #expect(zip(newWidgets, newErasedNodes).allSatisfy { $0.0 === $0.1.getWidget().into() })
    }
}

infix operator <=>

func <=> (_ lhs: Bool, _ rhs: Bool) -> Bool {
    lhs == rhs
}
