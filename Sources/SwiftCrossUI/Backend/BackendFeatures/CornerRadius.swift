extension BackendFeatures {
    /// Backend methods for setting widgets' corner radii.
    ///
    /// These are used by ``View/cornerRadius(_:)``.
    @MainActor
    public protocol CornerRadius: Core {
        /// Create a container capable of clipping its child at the corners.
        ///
        /// If no container is necessary, this method is allowed to return `child`
        /// unmodified.
        ///
        /// - Parameters:
        ///   - child: The widget being wrapped to set a corner radius for.
        func createCornerRadiusContainer(wrapping child: Widget) -> Widget

        /// Sets the corner radius of a widget (any widget). Should affect the view's border radius
        /// as well.
        ///
        /// - Parameters:
        ///   - widget: The widget to set the corner radius of.
        ///   - radius: The corner radius.
        func setCornerRadius(of widget: Widget, to radius: Int)
    }
}
