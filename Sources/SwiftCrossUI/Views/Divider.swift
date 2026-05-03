/// A divider that expands along the minor axis of the containing stack layout.
///
/// If not contained within a stack, this view expands horizontally.
///
/// In dark mode it's white with 10% opacity, and in light mode it's black with
/// 10% opacity.
public struct Divider: View, Sendable {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.layoutOrientation) var layoutOrientation

    let requestedColor: Color?

    /// Creates a divider. Uses the provided color, or adapts to the current
    /// color scheme if nil.
    public init(_ color: Color? = nil) {
        self.requestedColor = color
    }

    var color: Color {
        requestedColor ?? Color.adaptive(light: .black, dark: .white)
    }

    public var body: some View {
        color
            .opacity(0.1)
            .frame(
                width: layoutOrientation == .horizontal ? 1 : nil,
                height: layoutOrientation == .vertical ? 1 : nil
            )
    }
}
