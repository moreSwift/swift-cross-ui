import SwiftCrossUI
import AndroidKit
import SwiftJava

extension AndroidKit.ListView {
    @JavaMethod
    public func setSelector(_ sel: AndroidKit.Drawable?)
}

@JavaClass(
    "dev.swiftcrossui.androidbackend.lists.CustomListAdapter",
    extends: AndroidKit.BaseAdapter.self
)
class CustomListAdapter: AndroidKit.BaseAdapter {
    @JavaMethod
    @_nonoverride convenience init(
        environment: JNIEnvironment? = nil
    )

    @JavaMethod
    func setViews(_ newViews: [AndroidKit.View?], _ newHeights: [Int32])

    @JavaMethod
    func setEnabled(_ isEnabled: Bool)
}

@JavaClass(
    "dev.swiftcrossui.androidbackend.lists.ListItemSelectedListener",
    implements: AndroidKit.AdapterView.OnItemSelectedListener.self
)
class ListItemSelectedListener: JavaObject {
    @JavaMethod
    @_nonoverride convenience init(environment: JNIEnvironment? = nil)

    @JavaMethod
    func getSelectedPosition() -> Int32

    @JavaMethod
    func setAction(_ action: SwiftAction?)
}

// swiftlint:disable force_try

// implements BackendFeatures.SelectableListViews
extension AndroidBackend {
    public func createSelectableListView() -> Widget {
        let absListViewClass = try! JavaClass<AndroidKit.AbsListView>()

        let listView = AndroidKit.ListView(
            Self.activity,
            environment: Self.env
        )

        listView.setChoiceMode(absListViewClass.CHOICE_MODE_SINGLE)

        listView
            .setAdapter(CustomListAdapter(environment: Self.env).as(AndroidKit.ListAdapter.self))

        listView
            .setOnItemSelectedListener(ListItemSelectedListener(environment: Self.env)
                .as(AndroidKit.AdapterView.OnItemSelectedListener.self))

        // Color was derived experimentally on an Android 16 emulator to match
        // the default pressed color.
        listView.setSelector(AndroidKit.ColorDrawable(0x32a1a1a1))

        return listView
    }

    public func updateSelectableListView(
        _ selectableListView: Widget,
        environment: EnvironmentValues
    ) {
        selectableListView.as(AndroidKit.AdapterView.self)!
            .getAdapter()!
            .as(CustomListAdapter.self)!
            .setEnabled(environment.isEnabled)
    }

    public func baseItemPadding(ofSelectableListView listView: Widget) -> EdgeInsets {
        let density = listView.getResources().getDisplayMetrics().density

        let dividerHeightPx = listView.as(AndroidKit.ListView.self)!.getDividerHeight()

        return EdgeInsets(bottom: Int(Float(dividerHeightPx) / density))
    }

    public func minimumRowSize(ofSelectableListView listView: Widget) -> SIMD2<Int> {
        .zero
    }

    public func setItems(
        ofSelectableListView listView: Widget,
        to items: [Widget],
        withRowHeights rowHeights: [Int]
    ) {
        let density = listView.getResources().getDisplayMetrics().density

        listView.as(AndroidKit.AdapterView.self)!
            .getAdapter()!
            .as(CustomListAdapter.self)!
            .setViews(items.map(Optional.some(_:)), rowHeights.map {
                Int32(Float($0) * density)
            })
    }

    public func setSelectionHandler(
        forSelectableListView listView: Widget,
        to action: @escaping (_ selectedIndex: Int) -> Void
    ) {
        let listener = listView.as(AndroidKit.ListView.self)!
            .getOnItemSelectedListener()!
            .as(ListItemSelectedListener.self)!

        listener.setAction(
            SwiftAction(environment: Self.env) {
                action(Int(listener.getSelectedPosition()))
            }
        )
    }

    public func setSelectedItem(
        ofSelectableListView listView: Widget,
        toItemAt index: Int?
    ) {
        let listView = listView.as(AndroidKit.ListView.self)!
        if let index {
            listView.setSelection(Int32(index))
        } else {
            listView.clearChoices()
        }
    }
}
