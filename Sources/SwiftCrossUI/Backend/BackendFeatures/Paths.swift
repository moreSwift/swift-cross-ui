extension BackendFeatures {
    /// Backend methods for path rendering.
    ///
    /// These are used by ``Shape`` and related types and modifiers.
    @MainActor
    public protocol Paths<Path>: Core {
        /// The underlying path type. Can be a wrapper or subclass.
        associatedtype Path

        /// Create a widget that can contain a path.
        ///
        /// - Returns: A path widget.
        func createPathWidget() -> Widget

        /// Create a path.
        ///
        /// The path will not be shown until
        /// ``renderPath(_:container:strokeColor:fillColor:overrideStrokeStyle:)``
        /// is called.
        ///
        /// - Returns: A path.
        func createPath() -> Path

        /// Update a path.
        ///
        /// The updates do not need to be visible before
        /// ``renderPath(_:container:strokeColor:fillColor:overrideStrokeStyle:)``
        /// is called.
        ///
        /// - Parameters:
        ///   - path: The path to be updated.
        ///   - source: The source to copy the path from.
        ///   - bounds: The bounds that the path is getting rendered in. This gets
        ///     passed to backends because AppKit uses a different coordinate system
        ///     (with a flipped y axis) and therefore needs to perform coordinate
        ///     conversions.
        ///   - pointsChanged: If `false`, the ``Path/actions`` of the source have not changed.
        ///   - environment: The environment of the path.
        func updatePath(
            _ path: Path,
            _ source: SwiftCrossUI.Path,
            bounds: SwiftCrossUI.Path.Rect,
            pointsChanged: Bool,
            environment: EnvironmentValues
        )

        /// Draw a path to the screen.
        ///
        /// - Parameters:
        ///   - path: The path to be rendered.
        ///   - container: The container widget that the path will render in.
        ///     Created with ``createPathWidget()``.
        ///   - strokeColor: The color to draw the path's stroke.
        ///   - fillColor: The color to shade the path's fill.
        ///   - overrideStrokeStyle: A value to override the path's stroke style.
        func renderPath(
            _ path: Path,
            container: Widget,
            strokeColor: Color.Resolved,
            fillColor: Color.Resolved,
            overrideStrokeStyle: StrokeStyle?
        )
    }
}
