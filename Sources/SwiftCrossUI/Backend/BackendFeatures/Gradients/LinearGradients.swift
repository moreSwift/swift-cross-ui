extension BackendFeatures {
    /// Backend methods for linear gradients.
    ///
    /// Used by ``LinearGradient``.
    public protocol LinearGradients: Core {
        /// Creates the widget for a ``LinearGradient``.
        func createLinearGradientWidget() -> Widget
        
        /// Updates the widget of a ``LinearGradient``.
        /// - Parameters:
        ///   - widget: The widget to update.
        ///   - gradient: The SwiftCrossUI struct housing the information for the gradient's rendering.
        ///   - size: The new size of the widget.
        ///   - environment: The widget's environment, used to resolve its colors.
        func updateLinearGradientWidget(
            _ widget: Widget,
            gradient: LinearGradient,
            withSize size: SIMD2<Int>,
            in environment: EnvironmentValues
        )
    }
}
