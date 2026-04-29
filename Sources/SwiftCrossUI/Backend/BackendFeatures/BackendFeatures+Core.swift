import Foundation

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

    /// Core backend methods for generic widget containers. These are required for a
    /// functional backend.
    @MainActor
    public protocol GenericContainers: Widgets {
        /// Creates a container in which children can be laid out by SwiftCrossUI
        /// using exact pixel positions.
        ///
        /// - Returns: A container widget.
        func createContainer() -> Widget

        /// Removes all children of the given container.
        ///
        /// - Parameter container: The container to remove the children of.
        func removeAllChildren(of container: Widget)

        /// Inserts a child into a given container at a given index.
        ///
        /// - Parameters:
        ///   - child: The child to insert.
        ///   - container: The container to insert the child into.
        ///   - index: The index to insert the child at.
        func insert(_ child: Widget, into container: Widget, at index: Int)

        /// Swaps the child at firstIndex with the child at secondIndex.
        ///
        /// May crash if either index is out of bounds.
        ///
        /// - Parameters:
        ///   - firstIndex: The index of the first child to swap.
        ///   - secondIndex: The index of the second child to swap.
        ///   - container: The container holding the children.
        func swap(childAt firstIndex: Int, withChildAt secondIndex: Int, in container: Widget)

        /// Sets the position of the specified child in a container.
        ///
        /// - Parameters:
        ///   - index: The index of the child to set the position of.
        ///   - container: The container holding the child.
        ///   - position: The new position.
        func setPosition(ofChildAt index: Int, in container: Widget, to position: SIMD2<Int>)

        /// Removes the child at the given index from the given container.
        ///
        /// - Parameters:
        ///   - index: The index of the child to remove.
        ///   - container: The container to remove the child from.
        func remove(childAt index: Int, from container: Widget)
    }

    /// Denotes a backend that implements the bare minimum required for a
    /// SwiftCrossUI application to launch and show something on the screen.
    ///
    /// This protocol includes methods for application lifecycle handling,
    /// window management, and widget manipulation. These are required for a
    /// functional backend.
    ///
    /// ## Topics
    ///
    /// ### Constituent Protocols
    /// - ``Widgets``
    /// - ``CoreWindowing``
    /// - ``GenericContainers``
    @MainActor
    public protocol Core: Widgets, CoreWindowing, GenericContainers {
        /// Creates an instance of the backend.
        init()

        /// The class of device that the backend is currently running on.
        ///
        /// This is used to determine text sizing and other adaptive properties.
        var deviceClass: DeviceClass { get }

        /// Runs the backend's main run loop.
        ///
        /// The app will exit when this method returns. This will always be the
        /// first method called by SwiftCrossUI.
        ///
        /// Often in UI frameworks (such as Gtk), code is run in a callback
        /// after starting the app, and hence this generic root window creation
        /// API must reflect that. This is always the first method to be called
        /// and is where boilerplate app setup should happen.
        ///
        /// The callback is where SwiftCrossUI will create windows, render
        /// initial views, start state handlers, etc. The setup action must be
        /// run exactly once. The backend must be fully functional before the
        /// callback is ready.
        ///
        /// It is up to the backend to decide whether the callback runs before or
        /// after the main loop starts. For example, some backends (such as
        /// `AppKitBackend`) can create windows and widgets before the run loop
        /// starts, so it makes the most sense to run the setup before the main run
        /// loop starts (it's also not possible to run the setup function once the
        /// main run loop starts anyway). On the other side is `GtkBackend` which
        /// must be on the main loop to create windows and widgets (because
        /// otherwise the root window has not yet been created, which is essential
        /// in Gtk), so the setup function is passed to `Gtk` as a callback to run
        /// once the main run loop starts.
        ///
        /// - Parameter callback: The callback to run.
        func runMainLoop(
            _ callback: @escaping @MainActor () -> Void
        )

        /// Runs an action in the app's main thread if required to perform UI updates
        /// by the backend.
        ///
        /// Predominantly used by ``Publisher`` to publish changes to a thread
        /// compatible with dispatching UI updates. Can be synchronous or
        /// asynchronous (for now).
        ///
        /// - Parameter action: The action to run in the main thread.
        nonisolated func runInMainThread(action: @escaping @MainActor () -> Void)

        /// Computes the root environment for an app (e.g. by checking the system's
        /// current theme).
        ///
        /// May fall back on the provided defaults where reasonable.
        ///
        /// - Parameter defaultEnvironment: The default environment.
        /// - Returns: The computed root environment.
        func computeRootEnvironment(defaultEnvironment: EnvironmentValues) -> EnvironmentValues

        /// Sets the handler to be notified when the root environment may need
        /// recomputation.
        ///
        /// This is intended to only be called once. Calling it more than once may
        /// or may not override the previous handler.
        ///
        /// - Parameter action: The root environment change handler.
        func setRootEnvironmentChangeHandler(to action: @escaping @Sendable @MainActor () -> Void)
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
