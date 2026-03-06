import Testing

import CGtk3
@testable import Gtk3Backend
@testable import SwiftCrossUI

@Suite(
    "Testing for Gtk3 layout",
    .disabled {
        #if os(macOS)
            // TODO(stackotter): Figure out how to fix autoreleasepool crash that
            //   happens around 30% of the time some time after `reproduce464` returns
            true
        #else
            false
        #endif
    }
)
struct LayoutTests {
    @MainActor
    @Test("Initial widget layout is consistent with subsequent updates (#464)")
    func reproduce464() {
        let backend = Gtk3Backend()
        backend.runMainLoop {
            let window = backend.createWindow(withDefaultSize: nil)
            let environment = EnvironmentValues(backend: backend).with(\.window, window)

            @MainActor
            func createView(show: Bool) -> some View {
                HStack {
                    Text("Left")
                    if show {
                        Button("-") {}
                        Text("Count: 0")
                        Button("+") {}
                    }
                }
            }

            let viewGraph = ViewGraph(
                for: createView(show: false),
                backend: backend,
                environment: environment
            )
            backend.setChild(ofWindow: window, to: viewGraph.rootNode.widget.into())

            let proposal = ProposedViewSize(400, 400)
            let hiddenResult = viewGraph.computeLayout(
                proposedSize: proposal,
                environment: environment
            )
            viewGraph.commit()

            let shownResult = viewGraph.computeLayout(
                with: createView(show: true),
                proposedSize: proposal,
                environment: environment
            )
            viewGraph.commit()

            let finalResult = viewGraph.computeLayout(
                proposedSize: proposal,
                environment: environment
            )
            viewGraph.commit()

            #expect(
                hiddenResult.size != shownResult.size
            )

            #expect(
                shownResult.size == finalResult.size,
                "Expected initial layout to have same size as final layout"
            )

            backend.gtkApp.quit()
        }
    }
}
