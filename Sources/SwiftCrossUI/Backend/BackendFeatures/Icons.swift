import Foundation

extension BackendFeatures {
    /// Backend methods for showing system icons.
    ///
    /// These are used by ``Icon``.
    @MainActor
    public protocol Icons: Core {
        /// Creates an icon view.
        ///
        /// Predominantly used by ``Icon``.
        ///
        /// - Returns: An icon view.
        func createIconView() -> Widget

        /// Sets the icon to be displayed.
        ///
        /// - Parameters:
        ///   - iconView: The icon view to update.
        ///   - icon: The icon to use.
        ///   - environment: The current environment.
        func updateIconView(
            _ iconView: Widget,
            icon: Icon.SystemIcon,
            environment: EnvironmentValues
        )
    }
}
