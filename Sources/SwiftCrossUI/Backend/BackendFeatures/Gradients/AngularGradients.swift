extension BackendFeatures {
    /// Backend methods for angular (conic) gradients.
    ///
    /// Used by ``AngularGradient``.
    public protocol AngularGradients: Core {
        /// Creates the widget for an ``AngularGradient``.
        func createAngularGradientWidget() -> Widget
        
        /// Updates the widget of an ``AngularGradient``.
        /// - Parameters:
        ///   - widget: The widget to update.
        ///   - gradient: The SwiftCrossUI struct housing the information for the gradient's rendering.
        ///   - size: The new size of the widget.
        ///   - environment: The widget's environment, used to resolve its colors.
        func updateAngularGradientWidget(
            _ widget: Widget,
            gradient: AngularGradient,
            withSize size: SIMD2<Int>,
            in environment: EnvironmentValues
        )
    }
}
