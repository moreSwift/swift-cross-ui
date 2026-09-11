import CGtk3
import Gtk3
@_spi(Backends) import SwiftCrossUI

extension Gtk3Backend: BackendFeatures.SelectableListViews {
    public func createSelectableListView() -> Widget {
        let listView = ListBox()
        listView.selectionMode = .single
        return listView
    }

    public func updateSelectableListView(
        _ selectableListView: Widget,
        environment: EnvironmentValues
    ) {
        let listView = selectableListView as! ListBox
        listView.sensitive = environment.isEnabled
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
        let listView = listView as! ListBox
        listView.removeAll()
        for item in items {
            listView.add(item)
        }
    }

    public func setSelectionHandler(
        forSelectableListView listView: Widget,
        to action: @escaping (_ selectedIndex: Int) -> Void
    ) {
        let listView = listView as! ListBox
        listView.rowSelected = { _, selectedRow in
            guard let selectedRow else {
                return
            }
            action(Int(gtk_list_box_row_get_index(selectedRow)))
        }
    }

    public func setSelectedItem(ofSelectableListView listView: Widget, toItemAt index: Int?) {
        let listView = listView as! ListBox
        let handler = listView.rowSelected
        listView.rowSelected = nil
        if let index {
            listView.selectRow(at: index)
        } else {
            listView.unselectAll()
        }
        listView.rowSelected = handler
    }
}
