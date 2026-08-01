import SwiftCrossUI
import SwiftCrossUIPreviews

// Previews CounterExample's own view. Write `#Preview` exactly as you would for
// a SwiftUI view: the closure's return type picks the SwiftCrossUI overload, so
// this file needs no conditional compilation and still builds on Linux and
// Windows.
//
// CounterExample is a package target, so Xcode renders this preview only
// because `CounterView` is built by the same module. See ``Preview(_:body:)``
// for why previewing across a package's modules needs an Xcode project.

#Preview("Counter") {
    CounterPreviewWrapper()
}

/// Supplies a source of truth for ``CounterView``'s binding, since a preview has
/// nowhere else to hold state.
private struct CounterPreviewWrapper: View {
    @State private var count = 0

    var body: some View {
        CounterView(count: $count)
    }
}
