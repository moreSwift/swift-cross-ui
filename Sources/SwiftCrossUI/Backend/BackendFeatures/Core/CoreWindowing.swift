extension BackendFeatures {
    /// Core backend methods for window handling. These are required for a
    /// functional backend.
    @MainActor
    public protocol CoreWindowing<Window>: Widgets {
        /// The underlying window type. Can be a wrapper or subclass.
        associatedtype Window
        
        /// Whether the backend can have multiple windows open at once. Mobile
        /// backends generally can't.
        var supportsMultipleWindows: Bool { get }
        
        /// Whether the backend supports overriding window color schemes (as you may
        /// do with the ``View/preferredColorScheme(_:)`` modifier).
        ///
        /// If `false`, then SwiftCrossUI will ignore the `preferredColorScheme(_:)`
        /// modifier as a nicer failure mode.
        var canOverrideWindowColorScheme: Bool { get }
        
        /// Creates a new window.
        ///
        /// For some backends it may make sense for this method to return the
        /// application's root window the first time its called, and only create new
        /// windows on subsequent invocations.
        ///
        /// A window's content size has precendence over the default size. The
        /// window should always be at least the size of its content.
        ///
        /// - Parameter defaultSize: The default size of the window. This is only a
        ///   suggestion; for example some backends may choose to restore the user's
        ///   preferred window size from a previous session.
        /// - Returns: The created window.
        func createWindow(withDefaultSize defaultSize: SIMD2<Int>?) -> Window
        
        /// Updates a window, generally to react to the current color scheme from the
        /// environment.
        ///
        /// - Parameters:
        ///   - window: The window to update.
        ///   - environment: the current environment.
        func updateWindow(_ window: Window, environment: EnvironmentValues)
        
        /// Sets the title of a window.
        ///
        /// - Parameters:
        ///   - window: The window to set the title of.
        ///   - title: The new title.
        func setTitle(ofWindow window: Window, to title: String)
        
        /// Sets the root child of a window.
        ///
        /// This replaces the previous child if one exists.
        ///
        /// - Parameters:
        ///   - window: The window to set the root child of.
        ///   - child: The new root child.
        func setChild(ofWindow window: Window, to child: Widget)
        
        /// Gets the size of the given window in pixels.
        ///
        /// - Parameter window: The window to get the size of.
        /// - Returns: The window's size in pixels.
        func size(ofWindow window: Window) -> SIMD2<Int>
        
        /// Check whether a window is programmatically resizable.
        ///
        /// This value does not necessarily reflect whether the window is resizable
        /// by the user.
        ///
        /// - Parameter window: The window to check.
        /// - Returns: Whether the window is programmatically resizable.
        func isWindowProgrammaticallyResizable(_ window: Window) -> Bool
        
        /// Sets the size (in pixels) of the given window.
        ///
        /// - Parameters:
        ///   - window: The window to set the size of.
        ///   - newSize: The new size.
        func setSize(ofWindow window: Window, to newSize: SIMD2<Int>)
        
        /// Sets the minimum and maximum width and height of a window.
        ///
        /// Prevents the user from making the window any smaller or larger than the
        /// given minimum and maximum sizes, respectively.
        ///
        /// - Parameters:
        ///   - window: The window to set the size limits of.
        ///   - minimumSize: The minimum window size.
        ///   - maximumSize: The maximum window size. If `nil`, any existing maximum
        ///     size constraints should be removed.
        func setSizeLimits(
            ofWindow window: Window,
            minimum minimumSize: SIMD2<Int>,
            maximum maximumSize: SIMD2<Int>?
        )
        
        /// Sets the handler for the window's resizing events.
        ///
        /// Setting the resize handler overrides any previous handler.
        ///
        /// - Parameters:
        ///   - window: The window to set the resize handler of.
        ///   - action: The new resize handler. Takes the window's proposed size.
        func setResizeHandler(
            ofWindow window: Window,
            to action: @escaping (_ newSize: SIMD2<Int>) -> Void
        )
        
        /// Shows a window after it has been created or updated (may be unnecessary
        /// for some backends).
        ///
        /// Predominantly used by window-based ``Scene`` implementations after
        /// propagating updates.
        ///
        /// - Parameter window: The window to show.
        func show(window: Window)
        
        /// Brings a window to the front if possible.
        ///
        /// Called when the window receives an external URL or file to handle from
        /// the desktop environment. May be used in other circumstances eventually.
        ///
        /// - Parameter window: The window to activate.
        func activate(window: Window)
        
        /// Computes a window's environment based off the root environment.
        ///
        /// This may involve updating ``EnvironmentValues/windowScaleFactor``, etc.
        ///
        /// - Parameters:
        ///   - window: The window to compute the environment for.
        ///   - rootEnvironment: The root environment.
        /// - Returns: The computed window environment.
        func computeWindowEnvironment(
            window: Window,
            rootEnvironment: EnvironmentValues
        ) -> EnvironmentValues
        
        /// Sets the handler to be notified when the window's contribution to the
        /// environment may have to be recomputed.
        ///
        /// Use this for things such as updating a window's scale factor in the
        /// environment when the window changes displays. In the future this may be
        /// useful for color space handling.
        ///
        /// If the root environment change handler (set by
        /// ``setRootEnvironmentChangeHandler(to:)``) needs to be called for
        /// whatever reason, the backend can skip calling `action` since the
        /// window's environment will be recomputed anyway.
        ///
        /// - Parameters:
        ///   - window: The window to set the environment change handler of.
        ///   - action: The window environment change handler.
        func setWindowEnvironmentChangeHandler(
            of window: Window,
            to action: @escaping @Sendable @MainActor () -> Void
        )
    }
}
