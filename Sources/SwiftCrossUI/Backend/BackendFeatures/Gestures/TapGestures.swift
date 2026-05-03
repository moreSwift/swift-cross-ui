extension BackendFeatures {
    /// Backend methods for tap gesture handling.
    ///
    /// These are used by ``View/onTapGesture(gesture:perform:)``.
    @MainActor
    public protocol TapGestures: Core {
        /// Wraps a view in a container that can receive tap gesture events.
        ///
        /// Some backends may not have to wrap the child, in which case they may
        /// just return the child as is.
        ///
        /// - Parameters:
        ///   - child: The child to wrap.
        ///   - gesture: The gesture to listen for.
        /// - Returns: A widget that can receive tap gesture events.
        func createTapGestureTarget(
            wrapping child: Widget,
            gesture: TapGesture
        ) -> Widget

        /// Update the tap gesture target with a new action.
        ///
        /// The new action replaces the old action.
        ///
        /// - Parameters:
        ///   - tapGestureTarget: The tap gesture target to update.
        ///   - gesture: The gesture to listen for.
        ///   - environment: The current environment.
        ///   - action: The action to perform when a tap gesture occurs.
        func updateTapGestureTarget(
            _ tapGestureTarget: Widget,
            gesture: TapGesture,
            environment: EnvironmentValues,
            action: @escaping () -> Void
        )
    }
}
