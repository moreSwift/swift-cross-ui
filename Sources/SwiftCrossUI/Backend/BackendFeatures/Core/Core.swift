extension BackendFeatures {
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
