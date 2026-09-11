import CGtk
import Gtk
@_spi(Backends) import SwiftCrossUI

extension GtkBackend: BackendFeatures.SelectableListViews {
    public func createSelectableListView() -> Widget {
        let listView = CustomListBox()
        listView.selectionMode = .single
        gtk_widget_add_css_class(listView.widgetPointer, "navigation-sidebar")
        return listView
    }

    public func updateSelectableListView(
        _ selectableListView: Widget,
        environment: EnvironmentValues
    ) {
        let selectableListView = selectableListView as! CustomListBox
        selectableListView.sensitive = environment.isEnabled
    }

    public func baseItemPadding(
        ofSelectableListView listView: Widget
    ) -> SwiftCrossUI.EdgeInsets {
        SwiftCrossUI.EdgeInsets()
    }

    public func minimumRowSize(ofSelectableListView listView: Widget) -> SIMD2<Int> {
        .zero
    }

    public func setItems(
        ofSelectableListView listView: Widget,
        to items: [Widget],
        withRowHeights rowHeights: [Int]
    ) {
        // NOTE: This implementation works under the same assumptions as
        //   AppKitBackend's implementation. Read the comment in
        //   AppKitBackend.setItems for more details. In short, we assume
        //   that modifications made to `items` between `setItems` calls
        //   are either all pops, or all appends (not a mix).

        let listView = listView as! CustomListBox

        let previousRowCount = listView.cachedRowCount
        listView.cachedRowCount = items.count

        if items.count > previousRowCount {
            for item in items[previousRowCount...] {
                listView.append(item)
            }
        } else if items.count < previousRowCount {
            for _ in 0..<(previousRowCount - items.count) {
                listView.removeRow(at: items.count)
            }
        }
    }

    public func setSelectionHandler(
        forSelectableListView listView: Widget,
        to action: @escaping (_ selectedIndex: Int) -> Void
    ) {
        let listView = listView as! CustomListBox
        listView.rowSelected = { _, selectedRow in
            guard let selectedRow else {
                return
            }
            let selection = Int(gtk_list_box_row_get_index(selectedRow))
            guard selection != listView.cachedSelection else {
                return
            }
            listView.cachedSelection = selection
            action(selection)
        }
    }

    public func setSelectedItem(ofSelectableListView listView: Widget, toItemAt index: Int?) {
        let listView = listView as! CustomListBox
        listView.cachedSelection = index
        if let index {
            listView.selectRow(at: index)
        } else {
            listView.unselectAll()
        }
    }
}
