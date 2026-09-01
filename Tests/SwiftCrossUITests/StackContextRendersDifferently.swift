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

    @Test func testVStack() {
        stackTest(
            view: VStack { TestView() },
            check: { firstPosition, secondPosition in
                firstPosition.y != secondPosition.y &&
                    firstPosition.x == secondPosition.x
            }
        )
    }

    @Test func testHStack() {
        stackTest(
            view: HStack { TestView() },
            check: { firstPosition, secondPosition in
                firstPosition.y == secondPosition.y &&
                    firstPosition.x != secondPosition.x
            }
        )
    }

    @Test func testZStack() {
        stackTest(
            view: ZStack { TestView() },
            check: { firstPosition, secondPosition in
                firstPosition == secondPosition
            }
        )
    }

    func stackTest<V: View>(
        view: V,
        check: (SIMD2<Int>, SIMD2<Int>) -> Bool
    ) {
        let backend = DummyBackend()
        let window = backend.createWindow(withDefaultSize: nil, id: "window")
        let environment = EnvironmentValues(backend: backend).with(\.window, window)

        let node = ViewGraphNode(for: view, backend: backend, environment: environment)

        _ = node.computeLayout(
            proposedSize: .unspecified,
            environment: environment
        )

        _ = node.commit()

        let widget = node.widget

        var lastParent: DummyBackend.Widget? = nil
        var children = widget.getChildren()

        while children.count != 2 {
            guard let first = children.first else {
                Issue.record("Unexpectedly didn't find children.")
                return
            }
            lastParent = first
            children = first.getChildren()
        }

        guard
            let _ = children.first as? DummyBackend.TextView,
            let _ = children.last as? DummyBackend.TextView
        else {
            Issue.record("Unexpectedly didn't find text views.")
            return
        }

        guard let container = lastParent as? DummyBackend.Container else {
            Issue.record("Parent of text views unexpectedly wasn't a container.")
            return
        }

        guard container.children.count == 2 else {
            Issue.record("Expected there to be two children in the container.")
            return
        }

        let (_, firstPosition) = container.children[0]
        let (_, secondPosition) = container.children[1]

        #expect(check(firstPosition, secondPosition))
    }
}
