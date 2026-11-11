import CGtk3
import Gtk3
@_spi(Backends) import SwiftCrossUI

// This is the old tables implementation. It doesn't work anymore and was pretty
// janky, but it has been left here commented out as a reference for future poor
// souls attempting to implement tables for Gtk3Backend

// extension Gtk3Backend: BackendFeatures.Tables {
//     public var defaultTableRowContentHeight: Int { 20 }
//     public var defaultTableCellVerticalPadding: Int { 4 }

//     private class Tables {
//         var tableSizes: [ObjectIdentifier: (rows: Int, columns: Int)] = [:]
//     }

//     private let tables = Tables()

//     public func createTable(rows: Int, columns: Int) -> Widget {
//         let widget = Grid()

//         for i in 0..<rows {
//             widget.insertRow(position: i)
//         }

//         for i in 0..<columns {
//             widget.insertRow(position: i)
//         }

//         tables.tableSizes[ObjectIdentifier(widget)] = (rows: rows, columns: columns)

//         widget.columnSpacing = 10
//         widget.rowSpacing = 10

//         return widget
//     }

//     public func setRowCount(ofTable table: Widget, to rows: Int) {
//         let table = table as! Grid

//         let rowDifference = rows - tables.tableSizes[ObjectIdentifier(table)]!.rows
//         tables.tableSizes[ObjectIdentifier(table)]!.rows = rows
//         if rowDifference < 0 {
//             for _ in 0..<(-rowDifference) {
//                 table.removeRow(position: 0)
//             }
//         } else if rowDifference > 0 {
//             for _ in 0..<rowDifference {
//                 table.insertRow(position: 0)
//             }
//         }

//     }

//     public func setColumnCount(ofTable table: Widget, to columns: Int) {
//         let table = table as! Grid

//         let columnDifference = columns - tables.tableSizes[ObjectIdentifier(table)]!.columns
//         tables.tableSizes[ObjectIdentifier(table)]!.columns = columns
//         if columnDifference < 0 {
//             for _ in 0..<(-columnDifference) {
//                 table.removeColumn(position: 0)
//             }
//         } else if columnDifference > 0 {
//             for _ in 0..<columnDifference {
//                 table.insertColumn(position: 0)
//             }
//         }

//     }

//     public func setCell(at position: CellPosition, inTable table: Widget, to widget: Widget) {
//         let table = table as! Grid
//         table.attach(
//             child: widget,
//             left: position.column,
//             top: position.row,
//             width: 1,
//             height: 1
//         )
//     }
// }
