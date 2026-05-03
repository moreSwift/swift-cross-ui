extension BackendFeatures {
    /// Backend methods for image rendering.
    ///
    /// These are used by ``Image``.
    @MainActor
    public protocol Images: Core {
        /// If `true`, all images in a window will get updated when the window's
        /// scale factor changes (``EnvironmentValues/windowScaleFactor``).
        ///
        /// Backends based on modern UI frameworks can usually get away with setting
        /// this to `false`, but backends such as `Gtk3Backend` have to set this to
        /// `true` to properly support HiDPI (aka Retina) displays because they
        /// manually rescale the image meaning that it must get rescaled when the
        /// scale factor changes.
        var requiresImageUpdateOnScaleFactorChange: Bool { get }

        /// Creates an image view.
        ///
        /// Predominantly used by ``Image``.
        ///
        /// - Returns: An image view.
        func createImageView() -> Widget

        /// Sets the image data to be displayed.
        ///
        /// - Parameters:
        ///   - imageView: The image view to update.
        ///   - rgbaData: The pixel data, as rows of pixels concatenated into a
        ///     flat array.
        ///   - width: The width of the image in pixels. Should only be used to
        ///     interpret `rgbaData`, _not_ to set the size of the image on-screen.
        ///   - height: The height of the image in pixels. Should only be used to
        ///     interpret `rgbaData`, _not_ to set the size of the image on-screen.
        ///   - targetWidth: The width that the image must have on-screen.
        ///     Guaranteed to match the width the widget will be given, so backends
        ///     that don't have to manually scale the underlying pixel data can
        ///     safely ignore this parameter.
        ///   - targetHeight: The height that the image must have on-screen.
        ///     Guaranteed to match the height the widget will be given, so backends
        ///     that don't have to manually scale the underlying pixel data can
        ///     safely ignore this parameter.
        ///   - dataHasChanged: If `false`, then `rgbaData` hasn't changed since the
        ///     last call, so backends that don't have to manually resize the image
        ///     data don't have to do anything.
        ///   - environment: The current environment.
        func updateImageView(
            _ imageView: Widget,
            rgbaData: [UInt8],
            width: Int,
            height: Int,
            targetWidth: Int,
            targetHeight: Int,
            dataHasChanged: Bool,
            environment: EnvironmentValues
        )
    }
}
