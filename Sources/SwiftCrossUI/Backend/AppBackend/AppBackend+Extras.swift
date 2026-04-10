import Foundation

extension AppBackend {
    /// Backend methods for handling incoming URLs.
    ///
    /// These are used by ``View/onOpenURL(perform:)``.
    @MainActor
    public protocol IncomingURLs: Core {
        /// Sets the handler for URLs directed to the application (e.g. URLs
        /// associated with a custom URL scheme).
        ///
        /// - Parameter action: The incoming URL handler.
        func setIncomingURLHandler(to action: @escaping (URL) -> Void)
    }

    /// Backend methods for opening URLs in external apps.
    ///
    /// These are used by ``EnvironmentValues/openURL``.
    @MainActor
    public protocol ExternalURLs: Core {
        /// Opens an external URL in the system browser or app registered for the
        /// URL's protocol.
        ///
        /// - Parameter url: The URL to open.
        func openExternalURL(_ url: URL) throws
    }

    /// Backend methods for revealing files in the system's file manager.
    ///
    /// These are used by ``EnvironmentValues/revealFile``.
    @MainActor
    public protocol RevealFile: Core {
        /// Reveals a file in the system's file manager.
        ///
        /// This typically opens the file's enclosing directory and highlights the
        /// file.
        ///
        /// - Parameter url: The URL of the file to reveal.
        func revealFile(_ url: URL) throws
    }

    /// Backend methods for setting an app's global menu.
    ///
    /// These are used by ``Scene/commands(_:)`` and related types.
    @MainActor
    public protocol ApplicationMenus: Core {
        /// Sets the application's global menu.
        ///
        /// Some backends may make use of the host platform's global menu bar
        /// (such as macOS's menu bar), and others may render their own menu bar
        /// within the application.
        ///
        /// - Parameters:
        ///   - submenus: The submenus of the global menu.
        ///   - environment: The menu's environment.
        func setApplicationMenu(
            _ submenus: [ResolvedMenu.Submenu],
            environment: EnvironmentValues
        )
    }

    /// Backend methods for setting widgets' corner radii.
    ///
    /// These are used by ``View/cornerRadius(_:)``.
    @MainActor
    public protocol CornerRadius: Core {
        /// Sets the corner radius of a widget (any widget). Should affect the view's border radius
        /// as well.
        ///
        /// - Parameters:
        ///   - widget: The widget to set the corner radius of.
        ///   - radius: The corner radius.
        func setCornerRadius(of widget: Widget, to radius: Int)
    }

    /// Backend methods for tooltips.
    ///
    /// These are used by ``View/help(_:)``.
    @MainActor
    public protocol Tooltips: Core {
        /// Create a container capable of showing a textual tooltip.
        ///
        /// If no container is necessary, this method is allowed to return `child`
        /// unmodified.
        ///
        /// - Parameters:
        ///   - child: The widget being wrapped to show a tooltip over.
        func createTooltipContainer(wrapping child: Widget) -> Widget

        /// Update the tooltip shown by a widget.
        ///
        /// - Parameters:
        ///   - widget: The widget to update the tooltip for. Will always have been
        ///     created by ``createTooltipContainer(wrapping:)``.
        ///   - tooltip: The text to be shown on hover.
        func updateTooltipContainer(_ widget: Widget, tooltip: String)
    }

    /// Backend methods for tables.
    ///
    /// These are used by ``Table``.
    @MainActor
    public protocol Tables: Core {
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
}
