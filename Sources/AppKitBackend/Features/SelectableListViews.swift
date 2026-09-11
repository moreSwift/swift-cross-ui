import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.SelectableListViews {
    public func createSelectableListView() -> Widget {
        let scrollView = NSDisabledScrollView()
        scrollView.hasHorizontalScroller = false
        scrollView.hasVerticalScroller = false

        let listView = NSCustomTableView()
        listView.delegate = listView.customDelegate
        listView.dataSource = listView.customDelegate
        listView.allowsColumnSelection = false
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("list-column"))
        listView.customDelegate.columnCount = 1
        listView.customDelegate.columnIndices = [
            ObjectIdentifier(column): 0
        ]
        listView.customDelegate.allowSelections = true
        listView.backgroundColor = .clear
        listView.headerView = nil
        listView.addTableColumn(column)
        if #available(macOS 11.0, *) {
            listView.style = .plain
        }

        scrollView.documentView = listView
        listView.enclosingScrollView?.drawsBackground = false
        return scrollView
    }

    public func updateSelectableListView(
        _ selectableListView: Widget,
        environment: EnvironmentValues
    ) {
        let scrollView = selectableListView as! NSDisabledScrollView
        let listView = scrollView.documentView! as! NSCustomTableView
        listView.isEnabled = environment.isEnabled
    }

    public func baseItemPadding(
        ofSelectableListView listView: Widget
    ) -> SwiftCrossUI.EdgeInsets {
        // TODO: Figure out if there's a way to compute this more directly. At
        //   the moment these are just figures from empirical observations.
        SwiftCrossUI.EdgeInsets(top: 0, bottom: 0, leading: 8, trailing: 8)
    }

    public func minimumRowSize(ofSelectableListView listView: Widget) -> SIMD2<Int> {
        .zero
    }

    public func setItems(
        ofSelectableListView listView: Widget,
        to items: [Widget],
        withRowHeights rowHeights: [Int]
    ) {
        // NOTE: This implementation works under the assumption that items that
        //   share an index in the new `items` and the previous `items` also
        //   share a widget. This assumption lets us conclude that the only new
        //   widgets are those added to the end of the list when the row count
        //   increases, and the only widgets removed are those removed from the
        //   end of the list when the row count decreases. These assumptions
        //   allow us to avoid calling reloadData, which is too heavy handed for
        //   what we want to do. reloadData also clobbers the selected row index,
        //   and workarounds that I tried didn't appear to have any effect.
        //
        //   I believe that the assumption is technically possible to break if
        //   a list view's data source changes state multiple times within a
        //   single view layout cycle, but we can deal with that when we get to it.
        //
        //   Eventually once List supports identity, we'll want to update the
        //   SelectableListViews API to provide a list of row operations instead
        //   of an entirely new array of widgets every time, which should allow us
        //   to resolve any worries that arise from the assumptions that we
        //   currently have to make.

        let table = (listView as! NSScrollView).documentView! as! NSCustomTableView

        let previousRowCount = table.customDelegate.rowCount
        let previousRowHeights = table.customDelegate.rowHeights
        table.customDelegate.rowCount = items.count
        table.customDelegate.widgets = items
        table.customDelegate.rowHeights = rowHeights

        if rowHeights != previousRowHeights {
            // Use an animation group to disable the default animation for row
            // height changes
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0

                table.noteHeightOfRows(
                    withIndexesChanged: IndexSet(0..<min(previousRowCount, items.count))
                )
            }
        }

        if items.count != previousRowCount {
            table.noteNumberOfRowsChanged()
        }
    }

    public func setSelectionHandler(
        forSelectableListView listView: Widget,
        to action: @escaping (_ selectedIndex: Int) -> Void
    ) {
        let listView = (listView as! NSScrollView).documentView! as! NSCustomTableView
        listView.customDelegate.selectionHandler = action
    }

    public func setSelectedItem(ofSelectableListView listView: Widget, toItemAt index: Int?) {
        let listView = (listView as! NSScrollView).documentView! as! NSCustomTableView

        // We want to process row selections asynchronously, because previous calls to
        // data reloading related NSTableView methods generally don't take effect
        // immediately, and they often clear the selected row. Putting this in an async
        // block appears to resolve some unselection issues we were facing that were
        // caused by setItems(ofSelectableListView:to:withRowHeights:)
        DispatchQueue.main.async {
            listView.selectRowIndexes(
                IndexSet([index].compactMap { $0 }),
                byExtendingSelection: false
            )
        }
    }
}
