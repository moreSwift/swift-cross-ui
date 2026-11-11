import AppKit
@_spi(Backends) import SwiftCrossUI

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
