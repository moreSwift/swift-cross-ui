@_spi(Backends) import SwiftCrossUI

extension DummyBackend: BackendFeatures.Tables {
    public var defaultTableRowContentHeight: Int { 10 }
    public var defaultTableCellVerticalPadding: Int { 10 }

    public func createTable() -> Widget {
        Table()
    }

    public func setRowCount(ofTable table: Widget, to rows: Int) {
        (table as! Table).rowCount = rows
    }

    public func setColumnLabels(
        ofTable table: Widget,
        to labels: [String],
        environment: EnvironmentValues
    ) {
        (table as! Table).columnLabels = labels
    }

    public func setCells(
        ofTable table: Widget,
        to cells: [Widget],
        withRowHeights rowHeights: [Int]
    ) {
        let table = table as! Table
        table.cells = cells
        table.rowHeights = rowHeights
    }
}
