extension BackendFeatures {
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

        /// The height of a table's column header.
        ///
        /// Used when computing a table's ideal height, which is the combined
        /// height of its rows plus its header. The default implementation
        /// assumes no column header; backends that render one should implement
        /// this and measure it.
        ///
        /// - Parameter table: The table to measure the column header of.
        /// - Returns: The height of the table's column header.
        func tableHeaderHeight(of table: Widget) -> Int

        /// The vertical space a table reserves around its rows, beyond the rows
        /// themselves and the column header.
        ///
        /// Some backends inset their rows within the table's body, so a table
        /// tall enough to hold only the sum of its row heights clips its last
        /// row. Backends that inset their rows should implement this and report
        /// the total of the space above the first row and below the last one.
        /// The default implementation assumes rows meet the edges of the body.
        ///
        /// - Parameter table: The table to measure the reserved space of.
        /// - Returns: The total vertical space reserved around the table's rows.
        func tableVerticalPadding(of table: Widget) -> Int

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

/// The assumed column-header height when a backend doesn't measure one.
fileprivate let defaultTableHeaderHeight = 0

/// The assumed space around a table's rows when a backend doesn't measure it.
fileprivate let defaultTableVerticalPadding = 0

extension BackendFeatures.Tables {
    public func tableHeaderHeight(of table: Widget) -> Int {
        defaultTableHeaderHeight
    }

    public func tableVerticalPadding(of table: Widget) -> Int {
        defaultTableVerticalPadding
    }
}
