import Foundation

extension BackendFeatures {
    /// Extra backend methods for window handling.
    @MainActor
    public protocol Windowing<Window>: Core {
        /// Sets the title of a window.
        ///
        /// - Parameters:
        ///   - window: The window to set the title of.
        ///   - title: The new title.
        func setTitle(ofWindow window: Window, to title: String)

        /// Sets the behaviors of a window.
        ///
        /// - Parameters:
        ///   - window: The window to set the behaviors on.
        ///   - closable: Whether the window can be closed by the user.
        ///   - minimizable: Whether the window can be minimized by the user.
        ///   - resizable: Whether the window can be resized by the user. Even if
        ///     resizable, the window shouldn't be allowed to become smaller than its
        ///     minimum size, or larger than its maximum size.
        func setBehaviors(
            ofWindow window: Window,
            closable: Bool,
            minimizable: Bool,
            resizable: Bool
        )

        /// Closes a window.
        ///
        /// At some point during or after execution of this function, the handler
        /// set by ``setCloseHandler(ofWindow:to:)`` should be called.
        /// Oftentimes this will be done automatically by the backend's underlying
        /// UI framework.
        ///
        /// This is primarily used by ``DismissWindowAction``.
        func close(window: Window)

        /// Sets the handler for the window's close events (for example, when the
        /// user clicks the close button in the title bar).
        ///
        /// The close handler should also be called whenever ``close(window:)-9xucx``
        /// is called (some UI frameworks do this automatically).
        ///
        /// This is used by SwiftCrossUI to release scene nodes' references to
        /// `window` when the window is closed.
        ///
        /// This is only called once per window; as such, it doesn't matter if
        /// setting the close handler again overrides the previous handler or adds a
        /// new one.
        func setCloseHandler(
            ofWindow window: Window,
            to action: @escaping () -> Void
        )
    }
}
