import SwiftCrossUI
import SwiftCrossUIPreviews

// The shipping consumer shape: write `#Preview` exactly as you would for a
// SwiftUI view. No `#if`, no `@available`, no SwiftUI import needed here --
// the closure's return type alone picks the SwiftCrossUI overload.
//
// This lives in an application target (rather than a package target like
// CounterExample) because Xcode only hosts a package view's preview from a
// target with an app product type in its scheme. See ``Preview(_:body:)``
// in SwiftCrossUIPreviews for the "Where previews appear" rule this
// demonstrates.

#Preview("Counter") {
    Counter()
}

struct Counter: View {
    @State private var count = 0

    var body: some View {
        VStack {
            Text("Count: \(count)")
                .font(.title)
            Button("Increment") {
                count += 1
            }
        }
        .padding()
    }
}
