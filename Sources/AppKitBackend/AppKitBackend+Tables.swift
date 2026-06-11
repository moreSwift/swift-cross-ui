import AppKit
import SwiftCrossUI

extension AppKitBackend {
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

class NSCustomTableView: NSTableView {
    var customDelegate = NSCustomTableViewDelegate()
}

class NSCustomTableViewDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    var widgets: [AppKitBackend.Widget] = []
    var rowHeights: [Int] = []
    var columnIndices: [ObjectIdentifier: Int] = [:]
    var rowCount = 0
    var columnCount = 0
    var allowSelections = false
    var selectionHandler: ((Int) -> Void)?

    func numberOfRows(in tableView: NSTableView) -> Int {
        return rowCount
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return CGFloat(rowHeights[row])
    }

    func tableView(
        _ tableView: NSTableView,
        viewFor tableColumn: NSTableColumn?,
        row: Int
    ) -> NSView? {
        guard let tableColumn else {
            logger.warning("no column provided")
            return nil
        }
        guard let columnIndex = columnIndices[ObjectIdentifier(tableColumn)] else {
            logger.warning("NSTableView asked for value of non-existent column")
            return nil
        }
        return widgets[row * columnCount + columnIndex]
    }

    func tableView(
        _ tableView: NSTableView,
        selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet
    ) -> IndexSet {
        if allowSelections {
            selectionHandler?(proposedSelectionIndexes.first!)
            return proposedSelectionIndexes
        } else {
            return []
        }
    }

    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let view = NSTableRowView()
        view.wantsLayer = true
        view.layer?.cornerRadius = 5
        return view
    }
}
