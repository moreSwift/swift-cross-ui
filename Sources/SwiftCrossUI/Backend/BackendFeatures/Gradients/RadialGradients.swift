extension BackendFeatures {
    /// Backend methods for radial gradients.
    ///
    /// Used by ``RadialGradient``.
    public protocol RadialGradients: Core {
        /// Creates the widget for a ``RadialGradient``.
        func createRadialGradientWidget() -> Widget
        
        /// Updates the widget of a ``RadialGradient``.
        /// - Parameters:
        ///   - widget: The widget to update.
        ///   - gradient: The SwiftCrossUI struct housing the information for the gradient's rendering.
        ///   - size: The new size of the widget.
        ///   - environment: The widget's environment, used to resolve its colors.
        func updateRadialGradientWidget(
            _ widget: Widget,
            gradient: RadialGradient,
            withSize size: SIMD2<Int>,
            in environment: EnvironmentValues
        )
    }
}
