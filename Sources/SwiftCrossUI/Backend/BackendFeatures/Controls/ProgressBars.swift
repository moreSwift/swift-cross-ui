extension BackendFeatures {
    /// Backend methods for progress bars.
    ///
    /// These are used by ``ProgressView`` when initialized with a `Progress`
    /// instance.
    @MainActor
    public protocol ProgressBars: Core {
        /// Creates a progress bar.
        ///
        /// - Returns: A progress bar.
        func createProgressBar() -> Widget

        /// Updates a progress bar to reflect the given progress (between 0 and 1),
        /// and the current view environment.
        ///
        /// - Parameters:
        ///   - widget: The progress bar to update.
        ///   - progressFraction: The current progress. If `nil`, then the bar
        ///     should show an indeterminate animation if possible.
        ///   - environment: The current environment.
        func updateProgressBar(
            _ widget: Widget,
            progressFraction: Double?,
            environment: EnvironmentValues
        )
    }
}
