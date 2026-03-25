import Foundation

/// A backend that can be used to run an app. Usually built on top of an
/// existing UI framework.
///
/// Default placeholder implementations are available for all non-essential
/// app lifecycle methods. These implementations will fatally crash when called
/// and are simply intended to allow incremental implementation of backends,
/// not a production-ready fallback for views that cannot be represented by a
/// given backend. The methods you need to implemented up-front (which don't
/// have default implementations) are: ``AppBackend_Windowing/createWindow(withDefaultSize:)``,
/// ``AppBackend_Windowing/setTitle(ofWindow:to:)``,
/// ``AppBackend_Windowing/setBehaviors(ofWindow:closable:minimizable:resizable:)``,
/// ``AppBackend_Windowing/setChild(ofWindow:to:)``, ``AppBackend_Windowing/show(window:)``,
/// ``AppBackend_Base/runMainLoop(_:)``, ``AppBackend_Base/runInMainThread(action:)``,
/// ``AppBackend_Windowing/isWindowProgrammaticallyResizable(_:)``,
/// ``AppBackend_Widgets/show(widget:)``.
/// Many of these can simply be given dummy implementations until you're ready
/// to implement them properly.
///
/// If you need to modify the children of a widget after creation but there
/// aren't update methods available, this is an intentional limitation to
/// reduce the complexity of maintaining a multitude of backends -- nest
/// another container, such as a VStack, inside the container to allow you
/// to change its children on demand.
///
/// For interactive controls with values, the method for setting the
/// control's value is always separate from the method for updating the
/// control's properties (e.g. its minimum value, or placeholder label etc).
/// This is because it's very common for view implementations to either
/// update a control's properties without updating its value (in the case
/// of an unbound control), or update a control's value only if it doesn't
/// match its current value (to prevent infinite loops).
///
/// Many views have both a `create` and an `update` method. The `create`
/// method should only have parameters for properties which don't have
/// sensible defaults (e.g. under some backends, image widgets can't be
/// created without an underlying image being selected up-front, so the
/// `create` method requires a `filePath` and will overlap with the `update`
/// method). This design choice was made to reduce the amount of repeated
/// code between the `create` and `update` methods of the various widgets
/// (since the `update` method is always called between calling `create`
/// and actually displaying the widget anyway).
public typealias AppBackend =
    AppBackend_Core
    & AppBackend_Containers
    & AppBackend_PassiveViews
    & AppBackend_Controls
    & AppBackend_Alert
    & AppBackend_Sheet
    & AppBackend_Menus
    & AppBackend_Color
    & AppBackend_CornerRadius
    & AppBackend_FileDialogs
    & AppBackend_Path
    & AppBackend_WebView
    & AppBackend_Gestures
    & AppBackend_ApplicationMenu

// MARK: Default implementations

/// Used by placeholder implementations of backend methods.
private func todo<T>(in type: T.Type, _ function: String = #function) -> Never {
    logger.critical("\(type): \(function) not implemented")
    Foundation.exit(1)
}

extension AppBackend_Core {
    public func setApplicationMenu(_ submenus: [ResolvedMenu.Submenu]) {
        todo(in: Self.self)
    }
}

extension AppBackend_Color {
    public func createColorableRectangle() -> Widget {
        todo(in: Self.self)
    }

    public func setColor(ofColorableRectangle widget: Widget, to color: Color.Resolved) {
        todo(in: Self.self)
    }
}

extension AppBackend_CornerRadius {
    public func setCornerRadius(of widget: Widget, to radius: Int) {
        todo(in: Self.self)
    }
}

extension AppBackend_ScrollContainer {
    public func createScrollContainer(for child: Widget) -> Widget {
        todo(in: Self.self)
    }
    
    public func updateScrollContainer(
        _ scrollView: Widget,
        environment: EnvironmentValues,
        bounceHorizontally: Bool,
        bounceVertically: Bool,
        hasHorizontalScrollBar: Bool,
        hasVerticalScrollBar: Bool
    ) {
        todo(in: Self.self)
    }
}

extension AppBackend_SelectableListView {
    public func createSelectableListView() -> Widget {
        todo(in: Self.self)
    }

    public func updateSelectableListView(
        _ selectableListView: Widget,
        environment: EnvironmentValues
    ) {
        todo(in: Self.self)
    }

    public func baseItemPadding(ofSelectableListView listView: Widget) -> EdgeInsets {
        todo(in: Self.self)
    }

    public func minimumRowSize(ofSelectableListView listView: Widget) -> SIMD2<Int> {
        todo(in: Self.self)
    }

    public func setItems(
        ofSelectableListView listView: Widget,
        to items: [Widget],
        withRowHeights rowHeights: [Int]
    ) {
        todo(in: Self.self)
    }

    public func setSelectionHandler(
        forSelectableListView listView: Widget,
        to action: @escaping (_ selectedIndex: Int) -> Void
    ) {
        todo(in: Self.self)
    }

    public func setSelectedItem(ofSelectableListView listView: Widget, toItemAt index: Int?) {
        todo(in: Self.self)
    }
}

extension AppBackend_SplitView {
    public func createSplitView(leadingChild: Widget, trailingChild: Widget) -> Widget {
        todo(in: Self.self)
    }

    public func setResizeHandler(
        ofSplitView splitView: Widget,
        to action: @escaping () -> Void
    ) {
        todo(in: Self.self)
    }

    public func sidebarWidth(ofSplitView splitView: Widget) -> Int {
        todo(in: Self.self)
    }

    public func setSidebarWidthBounds(
        ofSplitView splitView: Widget,
        minimum minimumWidth: Int,
        maximum maximumWidth: Int
    ) {
        todo(in: Self.self)
    }
}

extension AppBackend_Tooltips {
    public func createTooltipContainer(wrapping child: Widget) -> Widget {
        todo(in: Self.self)
    }

    public func updateTooltipContainer(_ widget: Widget, tooltip: String) {
        todo(in: Self.self)
    }
}

extension AppBackend_Text {
    public func size(
        of text: String,
        whenDisplayedIn widget: Widget,
        proposedWidth: Int?,
        proposedHeight: Int?,
        environment: EnvironmentValues
    ) -> SIMD2<Int> {
        todo(in: Self.self)
    }

    public func createTextView() -> Widget {
        todo(in: Self.self)
    }

    public func updateTextView(
        _ textView: Widget,
        content: String,
        environment: EnvironmentValues
    ) {
        todo(in: Self.self)
    }
}

extension AppBackend_Image {
    public func createImageView() -> Widget {
        todo(in: Self.self)
    }

    public func updateImageView(
        _ imageView: Widget,
        rgbaData: [UInt8],
        width: Int,
        height: Int,
        targetWidth: Int,
        targetHeight: Int,
        dataHasChanged: Bool,
        environment: EnvironmentValues
    ) {
        todo(in: Self.self)
    }
}

extension AppBackend_Table {
    public func createTable() -> Widget {
        todo(in: Self.self)
    }

    public func setRowCount(ofTable table: Widget, to rows: Int) {
        todo(in: Self.self)
    }

    public func setColumnLabels(
        ofTable table: Widget,
        to labels: [String],
        environment: EnvironmentValues
    ) {
        todo(in: Self.self)
    }

    public func setCells(
        ofTable table: Widget,
        to cells: [Widget],
        withRowHeights rowHeights: [Int]
    ) {
        todo(in: Self.self)
    }
}


extension AppBackend_Button {
    public func createButton() -> Widget {
        todo(in: Self.self)
    }
    public func updateButton(
        _ button: Widget,
        label: String,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        todo(in: Self.self)
    }
}

extension AppBackend_ButtonMenu {
    public func updateButton(
        _ button: Widget,
        label: String,
        menu: Menu,
        environment: EnvironmentValues
    ) {
        todo(in: Self.self)
    }
}

extension AppBackend_Toggle {
    public func createToggle() -> Widget {
        todo(in: Self.self)
    }

    public func updateToggle(
        _ toggle: Widget,
        label: String,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        todo(in: Self.self)
    }

    public func setState(ofToggle toggle: Widget, to state: Bool) {
        todo(in: Self.self)
    }
}

extension AppBackend_Switch {
    public func createSwitch() -> Widget {
        todo(in: Self.self)
    }

    public func updateSwitch(
        _ switchWidget: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        todo(in: Self.self)
    }

    public func setState(ofSwitch switchWidget: Widget, to state: Bool) {
        todo(in: Self.self)
    }
}

extension AppBackend_Checkbox {
    public func createCheckbox() -> Widget {
        todo(in: Self.self)
    }

    public func updateCheckbox(
        _ checkboxWidget: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        todo(in: Self.self)
    }

    public func setState(ofCheckbox checkboxWidget: Widget, to state: Bool) {
        todo(in: Self.self)
    }
}

extension AppBackend_Slider {
    public func createSlider() -> Widget {
        todo(in: Self.self)
    }

    public func updateSlider(
        _ slider: Widget,
        minimum: Double,
        maximum: Double,
        decimalPlaces: Int,
        environment: EnvironmentValues,
        onChange: @escaping (Double) -> Void
    ) {
        todo(in: Self.self)
    }

    public func setValue(ofSlider slider: Widget, to value: Double) {
        todo(in: Self.self)
    }
}

extension AppBackend_TextField {
    public func createTextField() -> Widget {
        todo(in: Self.self)
    }

    public func updateTextField(
        _ textField: Widget,
        placeholder: String,
        environment: EnvironmentValues,
        onChange: @escaping (String) -> Void,
        onSubmit: @escaping () -> Void
    ) {
        todo(in: Self.self)
    }

    public func setContent(ofTextField textField: Widget, to content: String) {
        todo(in: Self.self)
    }

    public func getContent(ofTextField textField: Widget) -> String {
        todo(in: Self.self)
    }
}

extension AppBackend_TextEditor {
    public func createTextEditor() -> Widget {
        todo(in: Self.self)
    }

    public func updateTextEditor(
        _ textEditor: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (String) -> Void
    ) {
        todo(in: Self.self)
    }

    public func setContent(ofTextEditor textEditor: Widget, to content: String) {
        todo(in: Self.self)
    }

    public func getContent(ofTextEditor textEditor: Widget) -> String {
        todo(in: Self.self)
    }
}

extension AppBackend_Picker {
    public func createPicker(style: BackendPickerStyle) -> Widget {
        todo(in: Self.self)
    }

    public func updatePicker(
        _ picker: Widget,
        options: [String],
        environment: EnvironmentValues,
        onChange: @escaping (Int?) -> Void
    ) {
        todo(in: Self.self)
    }

    public func setSelectedOption(ofPicker picker: Widget, to selectedOption: Int?) {
        todo(in: Self.self)
    }
}

extension AppBackend_ProgressSpinner {
    public func createProgressSpinner() -> Widget {
        todo(in: Self.self)
    }
}

extension AppBackend_ProgressBar {
    public func createProgressBar() -> Widget {
        todo(in: Self.self)
    }

    public func updateProgressBar(
        _ widget: Widget,
        progressFraction: Double?,
        environment: EnvironmentValues
    ) {
        todo(in: Self.self)
    }
}

extension AppBackend_MenuBase {
    public func createPopoverMenu() -> Menu {
        todo(in: Self.self)
    }

    public func updatePopoverMenu(
        _ menu: Menu,
        content: ResolvedMenu,
        environment: EnvironmentValues
    ) {
        todo(in: Self.self)
    }
}

extension AppBackend_PopoverMenu {
    public func showPopoverMenu(
        _ menu: Menu,
        at position: SIMD2<Int>,
        relativeTo widget: Widget,
        closeHandler handleClose: @escaping () -> Void
    ) {
        todo(in: Self.self)
    }
}

extension AppBackend_Alert {
    public func createAlert() -> Alert {
        todo(in: Self.self)
    }

    public func updateAlert(
        _ alert: Alert,
        title: String,
        actionLabels: [String],
        environment: EnvironmentValues
    ) {
        todo(in: Self.self)
    }

    public func showAlert(
        _ alert: Alert,
        window: Window?,
        responseHandler handleResponse: @escaping (Int) -> Void
    ) {
        todo(in: Self.self)
    }

    public func dismissAlert(_ alert: Alert, window: Window?) {
        todo(in: Self.self)
    }
}

extension AppBackend_FileDialogs {
    public func showOpenDialog(
        fileDialogOptions: FileDialogOptions,
        openDialogOptions: OpenDialogOptions,
        window: Window?,
        resultHandler handleResult: @escaping (DialogResult<[URL]>) -> Void
    ) {
        todo(in: Self.self)
    }

    public func showSaveDialog(
        fileDialogOptions: FileDialogOptions,
        saveDialogOptions: SaveDialogOptions,
        window: Window?,
        resultHandler handleResult: @escaping (DialogResult<URL>) -> Void
    ) {
        todo(in: Self.self)
    }
}

extension AppBackend_TapGesture {
    public func createTapGestureTarget(wrapping child: Widget, gesture: TapGesture) -> Widget {
        todo(in: Self.self)
    }

    public func updateTapGestureTarget(
        _ clickTarget: Widget,
        gesture: TapGesture,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        todo(in: Self.self)
    }
}

extension AppBackend_HoverGesture {
    public func createHoverTarget(wrapping child: Widget) -> Widget {
        todo(in: Self.self)
    }

    public func updateHoverTarget(
        _ container: Widget,
        environment: EnvironmentValues,
        action: @escaping (Bool) -> Void
    ) {
        todo(in: Self.self)
    }
}

extension AppBackend_Path {
    public func createPathWidget() -> Widget {
        todo(in: Self.self)
    }

    public func createPath() -> Path {
        todo(in: Self.self)
    }

    public func updatePath(
        _ path: Path,
        _ source: SwiftCrossUI.Path,
        bounds: SwiftCrossUI.Path.Rect,
        pointsChanged: Bool,
        environment: EnvironmentValues
    ) {
        todo(in: Self.self)
    }

    public func renderPath(
        _ path: Path,
        container: Widget,
        strokeColor: Color.Resolved,
        fillColor: Color.Resolved,
        overrideStrokeStyle: StrokeStyle?
    ) {
        todo(in: Self.self)
    }
}

extension AppBackend_WebView {
    public func createWebView() -> Widget {
        todo(in: Self.self)
    }

    public func updateWebView(
        _ webView: Widget,
        environment: EnvironmentValues,
        onNavigate: @escaping (URL) -> Void
    ) {
        todo(in: Self.self)
    }

    public func navigateWebView(
        _ webView: Widget,
        to url: URL
    ) {
        todo(in: Self.self)
    }
}

extension AppBackend_Sheet {
    public func createSheet(content: Widget) -> Sheet {
        todo(in: Self.self)
    }

    public func updateSheet(
        _ sheet: Sheet,
        window: Window,
        environment: EnvironmentValues,
        size: SIMD2<Int>,
        onDismiss: @escaping () -> Void,
        cornerRadius: Double?,
        detents: [PresentationDetent],
        dragIndicatorVisibility: Visibility,
        backgroundColor: Color.Resolved?,
        interactiveDismissDisabled: Bool
    ) {
        todo(in: Self.self)
    }

    public func size(
        ofSheet sheet: Sheet
    ) -> SIMD2<Int> {
        todo(in: Self.self)
    }

    public func presentSheet(
        _ sheet: Sheet,
        window: Window,
        parentSheet: Sheet?
    ) {
        todo(in: Self.self)
    }

    public func dismissSheet(
        _ sheet: Sheet,
        window: Window,
        parentSheet: Sheet?
    ) {
        todo(in: Self.self)
    }
}

extension AppBackend_DatePicker {
    public func createDatePicker() -> Widget {
        todo(in: Self.self)
    }

    public func updateDatePicker(
        _ datePicker: Widget,
        environment: EnvironmentValues,
        date: Date,
        range: ClosedRange<Date>,
        components: DatePickerComponents,
        onChange: @escaping (Date) -> Void
    ) {
        todo(in: Self.self)
    }
}
