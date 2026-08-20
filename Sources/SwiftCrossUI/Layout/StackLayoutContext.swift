/// The orientation, alignment and spacing that a stack imposes on its children.
///
/// These three values travel together through the environment; grouping them
/// keeps their defaults in one place and lets a view establish a complete stack
/// context in a single step.
public struct StackLayoutContext: Sendable {
    /// The orientation children are laid out along.
    public var orientation: Orientation
    /// The alignment of children perpendicular to ``orientation``.
    public var alignment: StackAlignment
    /// The amount of spacing to apply between children.
    public var spacing: Int

    /// The context a view lays out in when no stack has established one.
    ///
    /// Also the context that implicit stacks adopt: ``VStack`` and ``HStack``
    /// fall back to its spacing and alignment, and a view body composed of
    /// several views is stacked with it rather than inheriting the surrounding
    /// stack's context.
    public static let `default` = StackLayoutContext(
        orientation: .vertical,
        alignment: .center,
        spacing: 10
    )

    /// Creates a stack layout context.
    ///
    /// - Parameters:
    ///   - orientation: The orientation children are laid out along.
    ///   - alignment: The alignment of children perpendicular to `orientation`.
    ///   - spacing: The amount of spacing to apply between children.
    public init(orientation: Orientation, alignment: StackAlignment, spacing: Int) {
        self.orientation = orientation
        self.alignment = alignment
        self.spacing = spacing
    }
}

extension EnvironmentValues {
    /// Returns a copy of the environment with the given stack layout context
    /// applied.
    ///
    /// - Parameter context: The context to impose on children.
    /// - Returns: A copy of the environment laying children out with `context`.
    public func with(_ context: StackLayoutContext) -> Self {
        with(\.layoutOrientation, context.orientation)
            .with(\.layoutAlignment, context.alignment)
            .with(\.layoutSpacing, context.spacing)
    }
}
