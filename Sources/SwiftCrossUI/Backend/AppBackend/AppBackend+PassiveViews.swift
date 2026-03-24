import Foundation

@MainActor
public protocol AppBackend_PassiveViews:
    AppBackend_Text,
    AppBackend_Image,
    AppBackend_Table
{}

@MainActor
public protocol AppBackend_Text: AppBackend_Widgets {
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

@MainActor
public protocol AppBackend_Image: AppBackend_Widgets {
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

@MainActor
public protocol AppBackend_Table: AppBackend_Widgets {
    /// The default height of a table row excluding cell padding. This is a
    /// recommendation by the backend that SwiftCrossUI won't necessarily
    /// follow in all cases.
    var defaultTableRowContentHeight: Int { get }

    /// The default vertical padding to apply to table cells.
    ///
    /// This is the amount of padding added above and below each cell, not the
    /// total amount added along the vertical axis. It's a recommendation by the
    /// backend that SwiftCrossUI won't necessarily follow in all cases.
    var defaultTableCellVerticalPadding: Int { get }

    /// Creates an empty table.
    ///
    /// - Returns: A table.
    func createTable() -> Widget

    /// Sets the number of rows of a table.
    ///
    /// Existing rows outside of the new bounds should be deleted.
    ///
    /// - Parameters:
    ///   - table: The table to set the row count of.
    ///   - rows: The number of rows.
    func setRowCount(ofTable table: Widget, to rows: Int)

    /// Sets the labels of a table's columns. Also sets the number of columns of
    /// the table to the number of labels provided.
    ///
    /// - Parameters:
    ///   - table: The table to set the column labels of.
    ///   - labels: The column labels to set.
    ///   - environment: The current environment.
    func setColumnLabels(
        ofTable table: Widget,
        to labels: [String],
        environment: EnvironmentValues
    )

    /// Sets the contents of the table as a flat array of cells in order of and
    /// grouped by row. Also sets the height of each row's content.
    ///
    /// A nested array would have significantly more overhead, especially for
    /// large arrays.
    ///
    /// - Parameters:
    ///   - table: The table.
    ///   - cells: The widgets to fill the table with.
    ///   - rowHeights: The heights of the table's rows.
    func setCells(
        ofTable table: Widget,
        to cells: [Widget],
        withRowHeights rowHeights: [Int]
    )
}

// MARK: Default Implementations

extension AppBackend_Text {
    public func resolveTextStyle(
        _ textStyle: Font.TextStyle
    ) -> Font.TextStyle.Resolved {
        textStyle.resolve(for: deviceClass)
    }
}
