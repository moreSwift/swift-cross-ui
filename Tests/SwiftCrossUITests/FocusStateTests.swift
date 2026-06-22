import Testing

import DummyBackend
@testable import SwiftCrossUI

@Suite("Testing @FocusState")
@MainActor
struct FocusStateTests {
    @Test("Focus State reacts to and sets focus")
    func focusStateReactsAndChangesFocus() async throws {
        let backend = DummyBackend()
        let window = backend.createWindow(withDefaultSize: nil)
        let environment = EnvironmentValues(backend: backend).with(\.window, window)

        struct FocusTestView: View {
            @FocusState.Binding var focusState: String?

            var body: some View {
                Button("Button 1")
                    .focused($focusState, equals: "Button 1")
                Button("Button 2")
                    .focused($focusState, equals: "Button 2")
            }
        }

        @FocusState
        var focusState: String?

        let view = FocusTestView(focusState: $focusState)

        let viewGraph = ViewGraph(
            for: view,
            backend: backend,
            environment: environment
        )

        let _ = viewGraph.computeLayout(
            proposedSize: .unspecified,
            environment: environment
        )
        viewGraph.commit()

        let rootWidget: DummyBackend.Widget = viewGraph.rootNode.widget.into()
        let root = try #require(rootWidget.firstWidget(ofType: DummyBackend.Container.self))
        let buttons = root.getChildren().compactMap {
            $0.firstWidget(ofType: DummyBackend.Button.self)
        }

        #expect(focusState == nil)

        backend.focus(buttons[0])
        #expect(focusState == "Button 1")

        backend.focus(buttons[1])
        #expect(focusState == "Button 2")

        focusState = "Button 1"

        // Doesn't update automatically as FocusState is not mounted in the ViewGraph
        let _ = viewGraph.computeLayout(
            proposedSize: .unspecified,
            environment: environment
        )
        viewGraph.commit()

        if let focused = backend.focusedWidget {
            #expect(
                (focused as! DummyBackend.Button).label == "Button 1",
                "DummyBackend.focusedWidget is expected to be the first Button"
            )
        } else {
            Issue
                .record(
                    "Unexpectedly found nil on DummyBackend.focusedWidget after setting FocusState"
                )
        }

        focusState = nil
        let _ = viewGraph.computeLayout(
            proposedSize: .unspecified,
            environment: environment
        )
        viewGraph.commit()

        #expect(backend.focusedWidget == nil)
    }
}
