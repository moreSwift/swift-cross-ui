extension BackendFeatures {
    /// Core backend methods for widget handling. These are required for a
    /// functional backend.
    @MainActor
    public protocol Widgets<Widget>: Sendable {
        /// The underlying widget type.
        associatedtype Widget

        /// The default amount of padding used when a user uses the
        /// ``View/padding(_:_:)`` modifier.
        var defaultPaddingAmount: Int { get }

        /// Shows a widget after it has been created or updated.
        ///
        /// May be unnecessary for some backends. Predominantly used by
        /// ``ViewGraphNode`` after propagating updates.
        ///
        /// Only called once the widget has been added to the widget hierarchy.
        ///
        /// - Parameter widget: The widget to show.
        func show(widget: Widget)

        /// Show a widget after it has been updated. This is unnecessary for most
        /// backends which automatically update the visual appearance of widgets
        /// when their properties get changed.
        ///
        /// The default implementation does nothing.
        ///
        /// It's a guarantee that ``ViewGraphNode/show(widget:)`` will get called
        /// before this method for any given widget.
        ///
        /// - Parameter widget: The widget to process.
        func showUpdate(of widget: Widget)

        /// Adds a short tag to a widget to assist during debugging, if the backend
        /// supports such a feature.
        ///
        /// The default implementation does nothing.
        ///
        /// Some backends may only apply tags under particular conditions such as
        /// when being built in debug mode.
        ///
        /// - Parameters:
        ///   - widget: The widget to tag.
        ///   - tag: The tag.
        func tag(widget: Widget, as tag: String)

        /// Gets the natural size of a given widget.
        ///
        /// E.g. the natural size of a button may be the size of the label (without
        /// line wrapping) plus a bit of padding and a border.
        ///
        /// - Parameter widget: The widget to get the natural size of.
        /// - Returns: The natural size of `widget`.
        func naturalSize(of widget: Widget) -> SIMD2<Int>

        /// Sets the size of a widget.
        ///
        /// - Parameters:
        ///   - widget: The widget to set the size of.
        ///   - size: The new size.
        func setSize(of widget: Widget, to size: SIMD2<Int>)
    }
}

// MARK: Default Implementations

extension BackendFeatures.Widgets {
    public func showUpdate(of widget: Widget) {
        // This only exists for backends such as CursesBackend that need to
        // explicitly be notified that a widget should display queued changes.
        // Most can get away with this empty default implementation.
    }

    public func tag(widget: Widget, as tag: String) {
        // This is only really to assist contributors when debugging backends,
        // so it's safe enough to have a no-op default implementation.
    }
}
