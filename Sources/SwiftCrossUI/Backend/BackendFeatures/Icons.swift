import Foundation

extension BackendFeatures {
    /// Backend methods for showing system icons.
    ///
    /// These are used by ``Icon``.
    @MainActor
    public protocol Icons: Core {
//        /// If `true`, all icons in a window will get updated when the window's
//        /// scale factor changes (``EnvironmentValues/windowScaleFactor``).
//        ///
//        /// Backends based on modern UI frameworks can usually get away with setting
//        /// this to `false`, but backends such as `Gtk3Backend` have to set this to
//        /// `true` to properly support HiDPI (aka Retina) displays because they
//        /// manually rescale the icon meaning that it must get rescaled when the
//        /// scale factor changes.
//        var requiresIconUpdateOnScaleFactorChange: Bool { get }

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
            icon: Icon,
            environment: EnvironmentValues
        )
    }
}
