import Gtk

class CustomListBox: ListBox {
    var cachedSelection: Int? = nil
    var cachedRowCount = 0
}
