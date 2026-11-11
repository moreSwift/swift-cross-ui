@_spi(Backends) import SwiftCrossUI

extension DummyBackend: BackendFeatures.SelectableListViews {
    public func createSelectableListView() -> Widget {
        SelectableListView()
    }

    public func updateSelectableListView(
        _ selectableListView: Widget,
        environment: EnvironmentValues
    ) {}

    public func baseItemPadding(ofSelectableListView listView: Widget) -> EdgeInsets {
        EdgeInsets(top: 0, bottom: 0, leading: 0, trailing: 0)
    }

    public func minimumRowSize(ofSelectableListView listView: Widget) -> SIMD2<Int> {
        .zero
    }

    public func setItems(
        ofSelectableListView listView: Widget,
        to items: [Widget],
        withRowHeights rowHeights: [Int]
    ) {
        let selectableListView = listView as! SelectableListView
        selectableListView.items = items
        selectableListView.rowHeights = rowHeights
    }

    public func setSelectionHandler(
        forSelectableListView listView: Widget,
        to action: @escaping (Int) -> Void
    ) {
        (listView as! SelectableListView).selectionHandler = action
    }

    public func setSelectedItem(ofSelectableListView listView: Widget, toItemAt index: Int?) {
        (listView as! SelectableListView).selectedIndex = index
    }
}
