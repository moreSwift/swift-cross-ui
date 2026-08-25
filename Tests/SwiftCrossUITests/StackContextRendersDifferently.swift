import Testing
import DummyBackend
@testable @_spi(Backends) import SwiftCrossUI

@MainActor
@Suite("View renders differently depending on the surrounding stack context")
struct StackContextRendersDifferently {
    struct TestView: View {
        // The view body contains the same text two times, cause that is a simple
        // way to check the expected behaviour. The bounds are expected to be 1:1
        // so for HStack the y position needs to be the same, x for VStack
        // and both for ZStack.
        var body: some View {
            Text("Test")
            Text("Test")
        }
    }

    @Test func testVStack() {
        let backend = DummyBackend()
        let window = backend.createWindow(withDefaultSize: nil, id: "window")
        let environment = EnvironmentValues(backend: backend).with(\.window, window)

        let view = VStack {
            TestView()
        }

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

        #expect(container.children.count == 2)

        guard
            container.children.count == 2,
            let (_, firstPosition) = container.children.first,
            let (_, secondPosition) = container.children.last
        else {
            Issue.record("Unexpectedly failed to extract child positions.")
            return
        }

        #expect(firstPosition.x == secondPosition.x)
    }

    @Test func testHStack() {
        let backend = DummyBackend()
        let window = backend.createWindow(withDefaultSize: nil, id: "window")
        let environment = EnvironmentValues(backend: backend).with(\.window, window)

        let view = HStack {
            TestView()
        }

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

        #expect(container.children.count == 2)

        guard
            container.children.count == 2,
            let (_, firstPosition) = container.children.first,
            let (_, secondPosition) = container.children.last
        else {
            Issue.record("Unexpectedly failed to extract child positions.")
            return
        }

        #expect(firstPosition.y == secondPosition.y)
    }

    @Test func testZStack() {
        let backend = DummyBackend()
        let window = backend.createWindow(withDefaultSize: nil, id: "window")
        let environment = EnvironmentValues(backend: backend).with(\.window, window)

        let view = ZStack {
            TestView()
        }

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

        #expect(container.children.count == 2)

        guard
            container.children.count == 2,
            let (_, firstPosition) = container.children.first,
            let (_, secondPosition) = container.children.last
        else {
            Issue.record("Unexpectedly failed to extract child positions.")
            return
        }

        #expect(firstPosition == secondPosition)
    }
}
