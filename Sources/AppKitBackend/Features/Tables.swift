import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.Tables {
    public var defaultTableRowContentHeight: Int { 20 }
    public var defaultTableCellVerticalPadding: Int { 4 }

    public func createTable() -> Widget {
        let scrollView = NSScrollView()
        let table = NSCustomTableView()
        table.delegate = table.customDelegate
        table.dataSource = table.customDelegate
        table.usesAlternatingRowBackgroundColors = true
        table.rowHeight = CGFloat(
            defaultTableRowContentHeight + 2 * defaultTableCellVerticalPadding
        )
        table.columnAutoresizingStyle = .lastColumnOnlyAutoresizingStyle
        table.allowsColumnSelection = false
        scrollView.documentView = table
        return scrollView
    }

    public func setRowCount(ofTable table: Widget, to rowCount: Int) {
        let table = (table as! NSScrollView).documentView as! NSCustomTableView
        table.customDelegate.rowCount = rowCount
    }

    public func setColumnLabels(
        ofTable table: Widget,
        to labels: [String],
        environment: EnvironmentValues
    ) {
        let table = (table as! NSScrollView).documentView as! NSCustomTableView
        var columnIndices: [ObjectIdentifier: Int] = [:]
        let columns = labels.enumerated().map { (i, label) in
            let column = NSTableColumn(
                identifier: NSUserInterfaceItemIdentifier("Column \(i)")
            )
            column.headerCell = NSTableHeaderCell()
            column.headerCell.attributedStringValue = Self.attributedString(
                for: label,
                in: environment
            )
            columnIndices[ObjectIdentifier(column)] = i
            return column
        }
        table.customDelegate.columnIndices = columnIndices
        for column in table.tableColumns {
            table.removeTableColumn(column)
        }
        table.customDelegate.columnCount = labels.count
        for column in columns {
            table.addTableColumn(column)
        }
    }

    public func setCells(
        ofTable table: Widget,
        to cells: [Widget],
        withRowHeights rowHeights: [Int]
    ) {
        let table = (table as! NSScrollView).documentView as! NSCustomTableView
        table.customDelegate.widgets = cells
        table.customDelegate.rowHeights = rowHeights
        table.reloadData()
    }
}
