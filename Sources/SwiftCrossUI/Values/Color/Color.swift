/// A color, which can be a simple RGBA color or a color that adapts
/// to light/dark and high contrast modes.
public struct Color: Sendable, Equatable, Hashable {
    /// The ideal size of a color view.
    private static let idealSize = ViewSize(10, 10)

    var representation: Representation
    var opacityMultiplier: Double

    init(representation: Representation, opacityMultiplier: Double = 1) {
        self.representation = representation
        self.opacityMultiplier = opacityMultiplier
    }

    /// Creates a color from its components with values between 0 and 1.
    public init(
        red: Double,
        green: Double,
        blue: Double,
        opacity: Double = 1
    ) {
        self.representation = .rgb(red: red, green: green, blue: blue)
        self.opacityMultiplier = opacity
    }

    /// Creates a color from a brightness value between 0 and 1.
    public init(
        white: Double,
        opacity: Double = 1
    ) {
        self.representation = .rgb(red: white, green: white, blue: white)
        self.opacityMultiplier = opacity
    }

    /// Creates an adaptive color tailored to each platform's design guidelines.
    ///
    /// - Parameter color: The color.
    /// - Returns: An adaptive color tailored for each platform.
    public static func system(_ color: SystemAdaptive) -> Color {
        Color(representation: .system(color))
    }

    /// Creates an adaptive color that changes based on the current color scheme.
    ///
    /// - Parameters:
    ///   - light: The color to use in light mode.
    ///   - dark: The color to use in dark mode.
    /// - Returns: An adaptive color that changes based on the current color scheme.
    public static func adaptive(light: Color, dark: Color) -> Color {
        Color(representation: .adaptive(light: light, dark: dark))
    }

    /// Multiplies the opacity of the color by the given amount.
    public consuming func opacity(_ opacityMultiplier: Double) -> Color {
        self.opacityMultiplier *= opacityMultiplier
        return self
    }

    public init(_ resolved: Color.Resolved) {
        self.representation = .rgb(
            red: Double(resolved.red),
            green: Double(resolved.green),
            blue: Double(resolved.blue)
        )
        self.opacityMultiplier = Double(resolved.opacity)
    }
}

extension Color: ElementaryView {
    func asWidget<Backend: AppBackend>(backend: Backend) -> Backend.Widget {
        backend.createColorableRectangle()
    }

    func computeLayout<Backend: AppBackend>(
        _ widget: Backend.Widget,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        ViewLayoutResult.leafView(
            size: proposedSize.replacingUnspecifiedDimensions(by: Self.idealSize)
        )
    }

    func commit<Backend: AppBackend>(
        _ widget: Backend.Widget,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        backend.setSize(of: widget, to: layout.size.vector)
        backend.setColor(ofColorableRectangle: widget, to: self.resolve(in: environment))
    }
}
