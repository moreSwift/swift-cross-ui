import Foundation

@MainActor
public protocol AppBackend_Color: AppBackend_Widgets {
    /// Creates a rectangular widget with configurable color.
    ///
    /// - Returns: A colorable rectangle.
    func createColorableRectangle() -> Widget
    
    /// Sets the color of a colorable rectangle.
    ///
    /// - Parameters:
    ///   - widget: The rectangle to set the color of.
    ///   - color: The new color.
    func setColor(ofColorableRectangle widget: Widget, to color: Color.Resolved)

    /// Resolves the given adaptive color to a concrete color given the current environment.
    ///
    /// The default implementation uses Apple's adaptive colors.
    ///
    /// - Parameters:
    ///   - adaptiveColor: The adaptive color to resolve.
    ///   - environment: The environment to resolve the color in.
    /// - Returns: The resolved color.
    func resolveAdaptiveColor(
        _ adaptiveColor: Color.SystemAdaptive,
        in environment: EnvironmentValues
    ) -> Color.Resolved
}

// MARK: Default Implementations

extension AppBackend_Color {
    public func resolveAdaptiveColor(
        _ adaptiveColor: Color.SystemAdaptive,
        in environment: EnvironmentValues
    ) -> Color.Resolved {
        let color: Color =
        switch adaptiveColor.kind {
            case .blue: .blue
            case .brown: .brown
            case .gray: .gray
            case .green: .green
            case .orange: .orange
            case .purple: .purple
            case .red: .red
            case .yellow: .yellow
        }

        return color.resolve(in: environment)
    }
}
