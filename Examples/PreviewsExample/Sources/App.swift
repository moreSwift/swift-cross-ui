import SwiftUI

// Minimal SwiftUI-lifecycle app. It exists only to give this project an
// application product type to build, which is what Xcode requires before it
// will host previews of the SwiftCrossUI package's views in its canvas. See
// PreviewedCounter.swift for the actual demonstration.
@main
struct PreviewsExampleApp: SwiftUI.App {
    var body: some SwiftUI.Scene {
        WindowGroup {
            SwiftUI.Text("See PreviewedCounter.swift and open its canvas.")
                .padding()
        }
    }
}
