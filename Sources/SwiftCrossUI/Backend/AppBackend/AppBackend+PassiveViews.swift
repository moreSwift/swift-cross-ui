import Foundation

extension AppBackend {
    /// Backend methods for non-interactive, "passive" views.
    ///
    /// ## Topics
    ///
    /// ### Constituent Protocols
    /// - ``TextViews``
    /// - ``Images``
    public typealias PassiveViews = TextViews & Images

    /// Backend methods for text rendering.
    ///
    /// These are used by ``Text``, and occasionally other features as well.
    @MainActor
    public protocol TextViews: Core {
        /// Resolves the given text style to concrete font properties.
        ///
        /// This method doesn't take ``EnvironmentValues`` because its result
        /// should be consistent when given the same text style twice. Font
        /// modifiers take effect later in the font resolution process.
        ///
        /// A default implementation is provided. It uses the backend's reported
        /// device class and looks up the text style in a lookup table derived
        /// from Apple's typography guidelines.
        ///
        /// - SeeAlso: ``Font/TextStyle/resolve(for:)``
        ///
        /// - Parameter textStyle: The text style to resolve.
        /// - Returns: The resolved text style.
        func resolveTextStyle(_ textStyle: Font.TextStyle) -> Font.TextStyle.Resolved

        /// Gets the size that the given text would have if it were laid out while
        /// attempting to stay within the proposed frame.
        ///
        /// The size returned by this function will be upheld by the layout system;
        /// child views always get the final say on their own size, parents just
        /// choose how the children get laid out. The given text should be
        /// truncated/ellipsized to fit within the proposal if possible.
        ///
        /// SwiftCrossUI will never supply zero as the proposed width or height,
        /// because some UI frameworks handle that in special ways.
        ///
        /// Most backends only use the proposed width and ignore the proposed height.
        ///
        /// Used by both ``Text`` and ``TextEditor``.
        ///
        /// - Parameters:
        ///   - text: The text to get the size of.
        ///   - widget: The target widget. Some backends (such as GTK) require a
        ///     reference to the target widget to get a text layout context.
        ///   - proposedWidth: The proposed width of the text. If `nil`, the text
        ///     should take up as much height as necessary to respect the proposed
        ///     width without getting ellipsized.
        ///   - proposedHeight: The proposed height of the text.
        ///   - environment: The current environment.
        /// - Returns: The size of `text` if it were laid out while attempting to
        ///   stay within `proposedFrame`.
        func size(
            of text: String,
            whenDisplayedIn widget: Widget,
            proposedWidth: Int?,
            proposedHeight: Int?,
            environment: EnvironmentValues
        ) -> SIMD2<Int>

        /// Creates a non-editable text view with optional text wrapping.
        ///
        /// Predominantly used by ``Text``.
        ///
        /// The returned widget should truncate and ellipsize its content when
        /// given a size which isn't big enough to fit the full content, as per
        /// ``size(of:whenDisplayedIn:proposedWidth:proposedHeight:environment:)``.
        ///
        /// - Returns: A text view.
        func createTextView() -> Widget

        /// Sets the content and wrapping mode of a non-editable text view.
        ///
        /// - Parameters:
        ///   - textView: The text view.
        ///   - content: The text view's content.
        ///   - environment: The current environment.
        func updateTextView(
            _ textView: Widget,
            content: String,
            environment: EnvironmentValues
        )
    }

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

// MARK: Default Implementations

extension AppBackend.TextViews {
    public func resolveTextStyle(
        _ textStyle: Font.TextStyle
    ) -> Font.TextStyle.Resolved {
        textStyle.resolve(for: deviceClass)
    }
}
