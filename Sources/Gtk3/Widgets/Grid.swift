// swiftlint:disable:next blanket_disable_command
// swiftlint:disable line_length

// //
// //  Copyright © 2017 Tomas Linhart. All rights reserved.
// //

// import CGtk3

// /// Grid is a container which arranges its child widgets in rows and columns. It is a very similar
// /// to Table and Box, but it consistently uses Widget’s "margin" and "expand" properties instead of
// /// custom child properties, and it fully supports height-for-width geometry management. Children
// /// are added using `attach(child:left:top:width:height:)`. They can span multiple rows or columns.
// /// It is also possible to add a child next to an existing child, using
// /// `attach(nextTo:sibling:side:width:height:)`. The behaviour of Grid when several children occupy
// /// the same grid cell is undefined. Grid can be used like a Box by just using `add(_:)`, which will
// /// place children next to each other in the direction determined by the "orientation" property.
// public class Grid: Widget, Orientable {
//     var widgets: [Widget] = []

//     public override init() {
//         super.init()

//         widgetPointer = gtk_grid_new()
//     }

//     public func attach(child: Widget, left: Int, top: Int, width: Int, height: Int) {
//         widgets.append(child)
//         child.parentWidget = self

//         gtk_grid_attach(
//             castedPointer(),
//             child.widgetPointer,
//             gint(left),
//             gint(top),
//             gint(width),
//             gint(height)
//         )
//     }

//     public func attach(
//         nextTo child: Widget,
//         sibling: Widget,
//         side: PositionType,
//         width: Int,
//         height: Int
//     ) {
//         widgets.append(child)
//         child.parentWidget = self

//         gtk_grid_attach_next_to(
//             castedPointer(),
//             child.widgetPointer,
//             sibling.widgetPointer,
//             side.toGtk(),
//             gint(width),
//             gint(height)
//         )
//     }

//     func getChildAt(left: Int, top: Int) -> Widget? {
//         let widget = gtk_grid_get_child_at(castedPointer(), gint(left), gint(top))
//         return widgets.first(where: { $0.widgetPointer == widget })
//     }

//     public func insertRow(position: Int) {
//         gtk_grid_insert_row(castedPointer(), gint(position))
//     }

//     public func removeRow(position: Int) {
//         gtk_grid_remove_row(castedPointer(), gint(position))
//     }

//     public func insertColumn(position: Int) {
//         gtk_grid_insert_column(castedPointer(), gint(position))
//     }

//     public func removeColumn(position: Int) {
//         gtk_grid_remove_column(castedPointer(), gint(position))
//     }

//     /// Inserts a row or column at the specified position.
//     ///
//     /// The new row or column is placed next to `sibling`, on the side determined by `side`. If
//     /// `side` is `.top` or `.bottom`, a row is inserted. If side is `.left` or `.right`, a column
//     /// is inserted.
//     ///
//     /// - Parameters:
//     ///   - sibling: The child of `grid` that the new row or column will be placed next to.
//     ///   - side: The side of `sibling` that `child` is positioned next to.
//     public func insert(nextTo sibling: Widget, side: PositionType) {
//         gtk_grid_insert_next_to(castedPointer(), sibling.widgetPointer, side.toGtk())
//     }

//     /// Whether all rows of `grid` will have the same height.
//     @GObjectProperty(named: "row-homogeneous") public var rowHomogeneous: Bool

//     /// The amount of space between rows of `grid`.
//     @GObjectProperty(named: "row-spacing") public var rowSpacing: Int

//     /// If `true`, the columns are all the same width.
//     @GObjectProperty(named: "column-homogeneous") public var columnHomogeneous: Bool

//     /// The amount of space between two consecutive columns.
//     @GObjectProperty(named: "column-spacing") public var columnSpacing: Int

//     /// The row to align to the baseline when valign is using baseline alignment.
//     @GObjectProperty(named: "baseline-row") public var baselineRow: Int

//     public func getRowBaselinePosition(forRow row: Int) -> BaselinePosition {
//         return BaselinePosition(
//             from: gtk_grid_get_row_baseline_position(castedPointer(), gint(row))
//         )
//     }

//     public func setRowBaselinePosition(forRow row: Int, position: BaselinePosition) {
//         gtk_grid_set_row_baseline_position(
//             castedPointer(),
//             gint(row),
//             position.toGtk()
//         )
//     }
// }
