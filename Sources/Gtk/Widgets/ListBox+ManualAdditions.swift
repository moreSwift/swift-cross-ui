import CGtk

extension ListBox {
    /// Appends a widget to the end of the list box.
    public func append(_ child: Widget) {
        gtk_list_box_append(opaquePointer, child.widgetPointer)
    }

    /// Removes all rows in the list box.
    public func removeAll() {
        // gtk_list_box_remove_all was introduced in 4.12 (too late for us)
        while removeRow(at: 0) {}
    }

    /// Removes the row at the given index.
    /// - Returns: `false` if the index is out of bounds, and `true` otherwise
    ///   (indicating that a row was removed).
    @discardableResult
    public func removeRow(at index: Int) -> Bool {
        guard let row = gtk_list_box_get_row_at_index(opaquePointer, gint(index)) else {
            return false
        }

        gtk_list_box_row_set_child(row, nil)
        gtk_list_box_remove(opaquePointer, row.cast())
        return true
    }

    /// Returns `true` on success.
    @discardableResult
    public func selectRow(at index: Int) -> Bool {
        guard let row = gtk_list_box_get_row_at_index(opaquePointer, gint(index)) else {
            return false
        }
        gtk_list_box_select_row(opaquePointer, row)
        return true
    }

    public func unselectAll() {
        gtk_list_box_unselect_all(opaquePointer)
    }
}
