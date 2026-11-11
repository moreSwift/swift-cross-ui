import CGtk3

/// A GtkListBox is a vertical container that contains GtkListBoxRow
/// children. These rows can be dynamically sorted and filtered, and
/// headers can be added dynamically depending on the row content.
/// It also allows keyboard and mouse navigation and selection like
/// a typical list.
///
/// Using GtkListBox is often an alternative to #GtkTreeView, especially
/// when the list contents has a more complicated layout than what is allowed
/// by a #GtkCellRenderer, or when the contents is interactive (i.e. has a
/// button in it).
///
/// Although a #GtkListBox must have only #GtkListBoxRow children you can
/// add any kind of widget to it via gtk_container_add(), and a #GtkListBoxRow
/// widget will automatically be inserted between the list and the widget.
///
/// #GtkListBoxRows can be marked as activatable or selectable. If a row
/// is activatable, #GtkListBox::row-activated will be emitted for it when
/// the user tries to activate it. If it is selectable, the row will be marked
/// as selected when the user tries to select it.
///
/// The GtkListBox widget was added in GTK+ 3.10.
///
/// # GtkListBox as GtkBuildable
///
/// The GtkListBox implementation of the #GtkBuildable interface supports
/// setting a child as the placeholder by specifying “placeholder” as the “type”
/// attribute of a `<child>` element. See gtk_list_box_set_placeholder() for info.
///
/// # CSS nodes
///
/// |[<!-- language="plain" -->
/// list
/// ╰── row[.activatable]
/// ]|
///
/// GtkListBox uses a single CSS node named list. Each GtkListBoxRow uses
/// a single CSS node named row. The row nodes get the .activatable
/// style class added when appropriate.
open class ListBox: Container {
    /// Creates a new #GtkListBox container.
    public convenience init() {
        self.init(
            gtk_list_box_new()
        )
    }

    open override func didMoveToParent() {
        super.didMoveToParent()

        addSignal(name: "activate-cursor-row") { [weak self] () in
            guard let self else { return }
            self.activateCursorRow?(self)
        }

        let handler1:
            @convention(c) (UnsafeMutableRawPointer, GtkMovementStep, Int, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, value2, data in
                SignalBox2<GtkMovementStep, Int>.run(data, value1, value2)
            }

        addSignal(name: "move-cursor", handler: gCallback(handler1)) {
            [weak self] (param0: GtkMovementStep, param1: Int) in
            guard let self else { return }
            self.moveCursor?(self, param0, param1)
        }

        let handler2:
            @convention(c) (
                UnsafeMutableRawPointer,
                UnsafeMutablePointer<GtkListBoxRow>,
                UnsafeMutableRawPointer
            ) -> Void =
            { _, value1, data in
                SignalBox1<UnsafeMutablePointer<GtkListBoxRow>>.run(data, value1)
            }

        addSignal(name: "row-activated", handler: gCallback(handler2)) {
            [weak self] (param0: UnsafeMutablePointer<GtkListBoxRow>) in
            guard let self else { return }
            self.rowActivated?(self, param0)
        }

        let handler3:
            @convention(c) (
                UnsafeMutableRawPointer,
                UnsafeMutablePointer<GtkListBoxRow>?,
                UnsafeMutableRawPointer
            ) -> Void =
            { _, value1, data in
                SignalBox1<UnsafeMutablePointer<GtkListBoxRow>?>.run(data, value1)
            }

        addSignal(name: "row-selected", handler: gCallback(handler3)) {
            [weak self] (param0: UnsafeMutablePointer<GtkListBoxRow>?) in
            guard let self else { return }
            self.rowSelected?(self, param0)
        }

        addSignal(name: "selected-rows-changed") { [weak self] () in
            guard let self else { return }
            self.selectedRowsChanged?(self)
        }

        addSignal(name: "toggle-cursor-row") { [weak self] () in
            guard let self else { return }
            self.toggleCursorRow?(self)
        }

        let handler6:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::activate-on-single-click", handler: gCallback(handler6)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyActivateOnSingleClick?(self, param0)
        }

        let handler7:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::selection-mode", handler: gCallback(handler7)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifySelectionMode?(self, param0)
        }
    }

    @GObjectProperty(named: "activate-on-single-click") public var activateOnSingleClick: Bool

    @GObjectProperty(named: "selection-mode") public var selectionMode: SelectionMode

    public var activateCursorRow: ((ListBox) -> Void)?

    public var moveCursor: ((ListBox, GtkMovementStep, Int) -> Void)?

    /// The ::row-activated signal is emitted when a row has been activated by the user.
    public var rowActivated: ((ListBox, UnsafeMutablePointer<GtkListBoxRow>) -> Void)?

    /// The ::row-selected signal is emitted when a new row is selected, or
    /// (with a %NULL @row) when the selection is cleared.
    ///
    /// When the @box is using #GTK_SELECTION_MULTIPLE, this signal will not
    /// give you the full picture of selection changes, and you should use
    /// the #GtkListBox::selected-rows-changed signal instead.
    public var rowSelected: ((ListBox, UnsafeMutablePointer<GtkListBoxRow>?) -> Void)?

    /// The ::selected-rows-changed signal is emitted when the
    /// set of selected rows changes.
    public var selectedRowsChanged: ((ListBox) -> Void)?

    public var toggleCursorRow: ((ListBox) -> Void)?

    public var notifyActivateOnSingleClick: ((ListBox, OpaquePointer) -> Void)?

    public var notifySelectionMode: ((ListBox, OpaquePointer) -> Void)?

    // MARK: Manual additions (couldn't be in extension cause of the removeAll override)

    @discardableResult
    public func selectRow(at index: Int) -> Bool {
        guard let row = gtk_list_box_get_row_at_index(castedPointer(), gint(index)) else {
            return false
        }
        gtk_list_box_select_row(castedPointer(), row)
        return true
    }

    public func unselectAll() {
        gtk_list_box_unselect_all(castedPointer())
    }

    public override func removeAll() {
        var list = gtk_container_get_children(castedPointer())
        var index = 0
        while let node = list {
            let row = node.pointee.data.assumingMemoryBound(to: GtkContainer.self)
            let rowAsWidget = node.pointee.data.assumingMemoryBound(to: GtkWidget.self)
            if index < widgets.count {
                gtk_container_remove(row, widgets[index].widgetPointer)
                widgets[index].parentWidget = nil
            }
            gtk_container_remove(castedPointer(), rowAsWidget)
            list = node.pointee.next
            index += 1
        }
        widgets = []
    }
}
