import Testing
import DummyBackend
@testable @_spi(Backends) import SwiftCrossUI

@MainActor
@Suite("View renders differently depending on the surrounding stack context")
struct StackContextRendersDifferently {
    struct TestView: View {
        // The view body contains the same text two times, cause that is a simple
        // way to check the expected behaviour.
        // The children are expected to be identical, so for HStack the y position
        // needs to be the same, x for VStack and both for ZStack.
        var body: some View {
            Text("Test")
            Text("Test")
        }
    }

    @Test func testVStack() throws {
        try stackTest(
            view: VStack { TestView() },
            check: { firstPosition, secondPosition in
                firstPosition.y != secondPosition.y &&
                    firstPosition.x == secondPosition.x
            }
        )
    }

    @Test func testHStack() throws {
        try stackTest(
            view: HStack { TestView() },
            check: { firstPosition, secondPosition in
                firstPosition.y == secondPosition.y &&
                    firstPosition.x != secondPosition.x
            }
        )
    }

    @Test func testZStack() throws {
        try stackTest(
            view: ZStack { TestView() },
            check: { firstPosition, secondPosition in
                firstPosition == secondPosition
            }
        )
    }

    func stackTest<V: View>(
        view: V,
        check: (SIMD2<Int>, SIMD2<Int>) -> Bool
    ) throws {
        let widget = ViewGraphHelpers.committedNode(for: view).widget

        let container: DummyBackend.Container = try widget.locateDescendant { container in
            let children = container.getChildren()

            return children.count == 2
                && children as? [DummyBackend.TextView] != nil
        }

        let (_, firstPosition) = container.children[0]
        let (_, secondPosition) = container.children[1]

        #expect(check(firstPosition, secondPosition))
    }
}
