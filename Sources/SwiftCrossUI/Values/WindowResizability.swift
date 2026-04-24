/// Controls how a window's resizing bounds relate to the resizability of the
/// window's content.
///
/// If you want to disable window resizing entirely, use ``View/windowResizeBehavior(_:)``
/// which controls whether the enclosing window is user resizable.
public enum WindowResizability: Sendable {
    /// SwiftCrossUI decides whether to use `contentSize` or `contentMinSize` depending
    /// on the type of scene. This currently means it'll just default to `contentMinSize`.
    case automatic
    /// The window cannot be resized smaller than its content's minimum size or larger
    /// than its content's maximum size.
    case contentSize
    /// The window cannot be resized smaller than its content's minimum size, but can
    /// be resized larger than its content's maximum size. If the window is bigger than
    /// its content, then its content remains centered within the window.
    case contentMinSize
}
