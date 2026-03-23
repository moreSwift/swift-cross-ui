import Testing

import DummyBackend
@testable import SwiftCrossUI

@Suite("Testing for ForEach")
struct ForEachTests {
    @MainActor
    @Test("Duplicate ids", .bug("https://github.com/moreSwift/swift-cross-ui/issues/456"))
    func duplicateIds() {
        let backend = DummyBackend()
        let window = backend.createWindow(withDefaultSize: nil)
        let environment = EnvironmentValues(backend: backend).with(\.window, window)

        let view = ForEach([1, 1], id: \.self) { x in
            Text("\(x)")
        }

        let node = ViewGraphNode(for: view, backend: backend, environment: environment)
        _ = node.computeLayout(
            proposedSize: .unspecified,
            environment: environment
        )
        // This will crash if the duplicate identifiers bug happens
        _ = node.commit()

        // Re-layout the view, because the nature of the duplicate handling bug changed
        // depending on the existing set of nodes before the update
        _ = node.computeLayout(
            with: view,
            proposedSize: .unspecified,
            environment: environment
        )
        _ = node.commit()
    }
    
    @MainActor
    @Test("Reordered children")
    func reorderedChildren() {
        let backend = DummyBackend()
        let window = backend.createWindow(withDefaultSize: nil)
        let environment = EnvironmentValues(backend: backend).with(\.window, window)

        func makeView(_ ids: [Int]) -> ForEach<[Int], Int, TupleView1<Text>> {
            ForEach(ids, id: \.self) { x in
                Text("\(x)")
            }
        }

        let values = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        var forEach = makeView(values)

        // Perform the initial update
        let node = ViewGraphNode(for: forEach, backend: backend, environment: environment)
        _ = node.computeLayout(
            proposedSize: .unspecified,
            environment: environment
        )
        _ = node.commit()

        // Initialize the state of each view to match its index
        let originalErasedNodes = node.children.erasedNodes
        let originalNodes = originalErasedNodes.map(\.node)
        let originalWidgets = node.widget.getChildren()

        #expect(originalNodes.count == values.count)
        #expect(originalWidgets.count == values.count)

        // let values =    [11, 1, 5, 3, 4, 2, 6, 7, 8, 9, 10]
        let newValues = [11, 1, 5, 6, 2, 4, 3]

        forEach = makeView(newValues)
        _ = node.computeLayout(
            with: forEach,
            proposedSize: .unspecified,
            environment: environment
        )
        _ = node.commit()

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
        #expect(zip(originalWidgets, originalErasedNodes).allSatisfy { $0.0 === $0.1.getWidget().into() })
        #expect(zip(newWidgets, newErasedNodes).allSatisfy { $0.0 === $0.1.getWidget().into() })
    }
}

infix operator <=>

func <=> (_ lhs: Bool, _ rhs: Bool) -> Bool {
    lhs == rhs
}
