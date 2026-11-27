import WinUI

class CustomListView: WinUI.ListView {
    var selectionHandler: ((_ selectedIndex: Int) -> Void)?
    var currentItems: [WinUI.ListViewItem] = []
    var cachedSelectedItem: Int? = nil
}
