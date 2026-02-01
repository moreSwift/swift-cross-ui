/// A divider that expands along the minor axis of the containing stack layout
/// (or horizontally otherwise). In dark mode it's white with 10% opacity, and
/// in light mode it's black with 10% opacity.
public struct Divider: View, Sendable {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.layoutOrientation) var layoutOrientation

    public init() {}

    public var body: some View {
        Color.adaptive(light: .black, dark: .white)
            .opacity(0.1)
            .frame(
                width: layoutOrientation == .horizontal ? 1 : nil,
                height: layoutOrientation == .vertical ? 1 : nil
            )
    }
}
