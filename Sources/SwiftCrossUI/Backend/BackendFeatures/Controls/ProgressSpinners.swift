extension BackendFeatures {
    /// Backend methods for progress spinners.
    ///
    /// These are used by ``ProgressView`` when initialized without a `Progress`
    /// instance.
    @MainActor
    public protocol ProgressSpinners: Core {
        /// Creates an indeterminate progress spinner.
        ///
        /// - Returns: A progress spinner.
        func createProgressSpinner() -> Widget

        /// Sets the size of a progress spinner.
        ///
        /// This method exists because AppKitBackend requires special handling to resize progress spinners.
        ///
        /// The default implementation forwards to ``BackendFeatures/Widgets/setSize(of:to:)``.
        func setSize(
            ofProgressSpinner widget: Widget,
            to size: SIMD2<Int>
        )
    }
}

// MARK: Default Implementations

extension BackendFeatures.ProgressSpinners {
    public func setSize(
        ofProgressSpinner widget: Widget,
        to size: SIMD2<Int>
    ) {
        setSize(of: widget, to: size)
    }
}
