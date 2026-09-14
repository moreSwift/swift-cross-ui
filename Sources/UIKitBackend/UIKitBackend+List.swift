@_spi(Backends) import SwiftCrossUI
import UIKit

extension UIKitBackend {
    public func createSelectableListView() -> Widget {
        let listView = UICustomTableView(frame: CGRect(), style: .insetGrouped)
        listView.delegate = listView.customDelegate
        listView.dataSource = listView.customDelegate

        listView.customDelegate.allowSelections = true
        listView.backgroundColor = .clear

        // These appear to be required in addition to the tableView(_:heightForHeaderInSection:)
        // and tableView(_:heightForFooterInSection:) implementations in UICustomTableViewDelegate.
        // Neither gets rid of the additional padding around grouped and insetGrouped list
        // section on their own.
        listView.sectionHeaderHeight = 0
        listView.sectionFooterHeight = 0

        listView.showsVerticalScrollIndicator = false

        return WrapperWidget(child: listView)
    }

    public func updateSelectableListView(
        _ selectableListView: Widget,
        environment: EnvironmentValues
    ) {
        let listView = (selectableListView as! WrapperWidget<UICustomTableView>).child
        listView.customDelegate.allowSelections = environment.isEnabled
    }

    public func baseItemPadding(
        ofSelectableListView listView: Widget
    ) -> SwiftCrossUI.EdgeInsets {
        // TODO: Figure out if there's a way to compute this more directly. At
        //   the moment these are just figures from empirical observations.
        SwiftCrossUI.EdgeInsets(top: 0, bottom: 0, leading: 0, trailing: 0)
    }

    public func minimumRowSize(ofSelectableListView listView: Widget) -> SIMD2<Int> {
        .zero
    }

    public func setItems(
        ofSelectableListView listView: Widget,
        to items: [Widget],
        withRowHeights rowHeights: [Int]
    ) {
        let listView = (listView as! WrapperWidget<UICustomTableView>).child
        listView.customDelegate.rowCount = items.count
        listView.customDelegate.widgets = items
        listView.customDelegate.rowHeights = rowHeights
        listView.reloadData()
    }

    public func setSelectionHandler(
        forSelectableListView listView: Widget,
        to action: @escaping (_ selectedIndex: Int) -> Void
    ) {
        let listView = (listView as! WrapperWidget<UICustomTableView>).child
        listView.customDelegate.selectionHandler = action
    }

    public func setSelectedItem(ofSelectableListView listView: Widget, toItemAt index: Int?) {
        let listView = (listView as! WrapperWidget<UICustomTableView>).child
        if let index {
            listView.selectRow(
                at: IndexPath(indexes: [0, index]),
                animated: false,
                scrollPosition: .none
            )
        } else {
            listView.selectRow(at: nil, animated: false, scrollPosition: .none)
        }
    }
}

class UICustomTableViewDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    var widgets: [UIKitBackend.Widget] = []
    var rowHeights: [Int] = []
    var rowCount = 0
    var allowSelections = false
    var selectionHandler: ((Int) -> Void)?

    // MARK: UITableViewDataSource

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return rowCount
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt path: IndexPath
    ) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.contentView.addSubview(widgets[path.row].view)
        return cell
    }

    func numberOfSections(in table: UITableView) -> Int {
        return 1
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, heightForRowAt path: IndexPath) -> CGFloat {
        return CGFloat(rowHeights[path.row])
    }

    func tableView(
        _ tableView: UITableView,
        willSelectRowAt path: IndexPath
    ) -> IndexPath? {
        if allowSelections {
            selectionHandler?(path.row)
            return path
        } else {
            return nil
        }
    }

    // Source: https://stackoverflow.com/a/37996322/8268001
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Removes extra padding in Grouped style
        return CGFloat.leastNormalMagnitude
    }

    // Source: https://stackoverflow.com/a/37996322/8268001
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // Removes extra padding in Grouped style
        return CGFloat.leastNormalMagnitude
    }
}

extension UICustomTableViewDelegate: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = 0
    }
}

class UICustomTableView: UITableView {
    var customDelegate = UICustomTableViewDelegate()
}
