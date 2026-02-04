import Foundation
import SwiftCrossUI

public final class DummyBackend: AppBackend {
    public class Window {
        static let defaultSize = SIMD2<Int>(400, 200)

        public var size: SIMD2<Int>
        public var minimumSize: SIMD2<Int> = .zero
        public var maximumSize: SIMD2<Int>?
        public var title = "Window"
        public var resizable = true
        public var closable = true
        public var minimizable = true
        public var content: Widget?
        public var resizeHandler: ((SIMD2<Int>) -> Void)?
        public var closeHandler: (() -> Void)?

        public init(defaultSize: SIMD2<Int>?) {
            size = defaultSize ?? Self.defaultSize
        }
    }

    public class BreadthFirstWidgetIterator: IteratorProtocol {
        var queue: [Widget]

        init(for widget: Widget) {
            queue = [widget]
        }

        public func next() -> Widget? {
            guard let next = queue.first else {
                return nil
            }
            queue.removeFirst()
            queue.append(contentsOf: next.getChildren())
            return next
        }
    }

    public class Widget {
        public var tag: String?
        public var cornerRadius = 0
        public var size = SIMD2<Int>.zero
        public var naturalSize: SIMD2<Int> {
            SIMD2<Int>.zero
        }

        public func getChildren() -> [Widget] {
            []
        }

        /// Finds the first widget of type `T` in the hierarchy defined by this
        /// widget (including the widget itself).
        public func firstWidget<T: Widget>(ofType type: T.Type) -> T? {
            let iterator = BreadthFirstWidgetIterator(for: self)
            while let child = iterator.next() {
                if let child = child as? T {
                    return child
                }
            }
            return nil
        }
    }

    public class Button: Widget {
        public var label = ""
        public var font: Font.Resolved?
        public var action: (() -> Void)?
        public var menu: Menu?
    }

    public class ToggleButton: Widget {
        public var label = ""
        public var font: Font.Resolved?
        public var toggleHandler: ((Bool) -> Void)?
        public var state = false
    }

    public class ToggleSwitch: Widget {
        public var toggleHandler: ((Bool) -> Void)?
        public var state = false

        override public var naturalSize: SIMD2<Int> {
            SIMD2(20, 10)
        }
    }

    public class Checkbox: Widget {
        public var toggleHandler: ((Bool) -> Void)?
        public var state = false

        override public var naturalSize: SIMD2<Int> {
            SIMD2(10, 10)
        }
    }

    public class Slider: Widget {
        public var value: Double = 0
        public var minimumValue: Double = 0
        public var maximumValue: Double = 100
        public var decimalPlaces = 1
        public var changeHandler: ((Double) -> Void)?

        override public var naturalSize: SIMD2<Int> {
            SIMD2(20, 10)
        }
    }

    public class TextField: Widget {
        public var value = ""
        public var placeholder = ""
        public var font: Font.Resolved?
        public var changeHandler: ((String) -> Void)?
        public var submitHandler: (() -> Void)?
    }

    public class TextView: Widget {
        public var content: String = ""
        public var font: Font.Resolved?
        public var color = Color.Resolved(red: 0.0, green: 0.0, blue: 0.0)
    }

    public class ImageView: Widget {
        public var rgbaData: [UInt8] = []
        public var pixelWidth = 0
        public var pixelHeight = 0
    }

    public class Table: Widget {
        public var rowCount = 0
        public var columnLabels: [String] = []
        public var cells: [Widget] = []
        public var rowHeights: [Int] = []

        public override func getChildren() -> [Widget] {
            cells
        }
    }

    public class Container: Widget {
        public var children: [(widget: Widget, position: SIMD2<Int>)] = []

        public override func getChildren() -> [Widget] {
            children.map(\.widget)
        }
    }

    public class ScrollContainer: Widget {
        public var child: Widget
        public var hasVerticalScrollBar = false
        public var hasHorizontalScrollBar = false

        public init(child: Widget) {
            self.child = child
        }

        public override func getChildren() -> [Widget] {
            [child]
        }
    }

    public class SelectableListView: Widget {
        public var items: [Widget] = []
        public var rowHeights: [Int] = []
        public var selectionHandler: ((Int) -> Void)?
        public var selectedIndex: Int?

        public override func getChildren() -> [Widget] {
            items
        }
    }

    public class Rectangle: Widget {
        public var color = Color.Resolved(red: 0.0, green: 0.0, blue: 0.0, opacity: 0.0)
    }

    public class SplitView: Widget {
        public var leadingChild: Widget
        public var trailingChild: Widget

        public var sidebarResizeHandler: (() -> Void)?

        private var _sidebarWidth = 100

        public var sidebarWidth: Int {
            get {
                _sidebarWidth
            }
            set {
                var width = newValue
                if let minimumSidebarWidth {
                    width = max(minimumSidebarWidth, width)
                }
                if let maximumSidebarWidth {
                    width = min(maximumSidebarWidth, width)
                }
                width = max(0, min(size.x, width))
                _sidebarWidth = width
            }
        }

        public var minimumSidebarWidth: Int? {
            didSet {
                if let minimumSidebarWidth {
                    sidebarWidth = max(minimumSidebarWidth, sidebarWidth)
                }
            }
        }

        public var maximumSidebarWidth: Int? {
            didSet {
                if let maximumSidebarWidth {
                    sidebarWidth = min(maximumSidebarWidth, sidebarWidth)
                }
            }
        }

        override public var size: SIMD2<Int> {
            didSet {
                if sidebarWidth > size.x {
                    sidebarWidth = size.x
                }
            }
        }

        public init(leadingChild: Widget, trailingChild: Widget) {
            self.leadingChild = leadingChild
            self.trailingChild = trailingChild
        }

        public override func getChildren() -> [Widget] {
            [leadingChild, trailingChild]
        }
    }

    public class Menu {}

    public class Alert {}

    public class Path {}

    public class Sheet {}

    public var defaultTableRowContentHeight = 10
    public var defaultTableCellVerticalPadding = 10
    public var defaultPaddingAmount = 10
    public var scrollBarWidth = 8
    public var requiresToggleSwitchSpacer = false
    public var requiresImageUpdateOnScaleFactorChange = false
    public var menuImplementationStyle = MenuImplementationStyle.dynamicPopover
    public var deviceClass = DeviceClass.desktop
    public var canRevealFiles = false
    public var supportsMultipleWindows = true
    public var supportedDatePickerStyles: [DatePickerStyle] = []

    public var incomingURLHandler: ((URL) -> Void)?

    public init() {}

    public func runMainLoop(_ callback: @escaping @MainActor () -> Void) {
        callback()
    }

    public func createWindow(withDefaultSize defaultSize: SIMD2<Int>?) -> Window {
        Window(defaultSize: defaultSize)
    }

    public func setTitle(ofWindow window: Window, to title: String) {
        window.title = title
    }

    public func setBehaviors(
        ofWindow window: Window,
        closable: Bool,
        minimizable: Bool,
        resizable: Bool
    ) {
        window.closable = closable
        window.minimizable = minimizable
        window.resizable = resizable
    }

    public func setChild(ofWindow window: Window, to child: Widget) {
        window.content = child
    }

    public func size(ofWindow window: Window) -> SIMD2<Int> {
        window.size
    }

    public func isWindowProgrammaticallyResizable(_ window: Window) -> Bool {
        true
    }

    public func setSize(ofWindow window: Window, to newSize: SIMD2<Int>) {
        window.size = newSize
    }

    public func setSizeLimits(
        ofWindow window: Window,
        minimum minimumSize: SIMD2<Int>,
        maximum maximumSize: SIMD2<Int>?
    ) {
        window.minimumSize = minimumSize
        window.maximumSize = maximumSize
    }

    public func setResizeHandler(ofWindow window: Window, to action: @escaping (SIMD2<Int>) -> Void)
    {
        window.resizeHandler = action
    }

    public func show(window: Window) {}

    public func activate(window: Window) {}

    public func close(window: Window) {
        window.closeHandler?()
    }

    public func setCloseHandler(ofWindow window: Window, to action: @escaping () -> Void) {
        window.closeHandler = action
    }

    public func runInMainThread(action: @escaping @MainActor () -> Void) {
        DispatchQueue.main.async {
            action()
        }
    }

    public func computeRootEnvironment(defaultEnvironment: EnvironmentValues) -> EnvironmentValues {
        defaultEnvironment
    }

    public func setRootEnvironmentChangeHandler(to action: @escaping () -> Void) {}

    public func computeWindowEnvironment(window: Window, rootEnvironment: EnvironmentValues)
        -> EnvironmentValues
    {
        rootEnvironment
    }

    public func setWindowEnvironmentChangeHandler(
        of window: Window, to action: @escaping () -> Void
    ) {}

    public func setIncomingURLHandler(to action: @escaping (URL) -> Void) {
        incomingURLHandler = action
    }

    public func show(widget: Widget) {}

    public func tag(widget: Widget, as tag: String) {
        widget.tag = tag
    }

    public func createContainer() -> Widget {
        Container()
    }

    public func removeAllChildren(of container: Widget) {
        (container as! Container).children = []
    }

    public func insert(_ child: Widget, into container: Widget, at index: Int) {
        (container as! Container).children.insert((child, .zero), at: index)
    }

    public func swap(childAt firstIndex: Int, withChildAt secondIndex: Int, in container: Widget) {
        (container as! Container).children.swapAt(firstIndex, secondIndex)
    }

    public func setPosition(ofChildAt index: Int, in container: Widget, to position: SIMD2<Int>) {
        (container as! Container).children[index].position = position
    }

    public func remove(childAt index: Int, from container: Widget) {
        let container = container as! Container
        container.children.remove(at: index)
    }

    public func createColorableRectangle() -> Widget {
        Rectangle()
    }

    public func setColor(ofColorableRectangle widget: Widget, to color: Color.Resolved) {
        (widget as! Rectangle).color = color
    }

    public func setCornerRadius(of widget: Widget, to radius: Int) {
        widget.cornerRadius = radius
    }

    public func naturalSize(of widget: Widget) -> SIMD2<Int> {
        widget.naturalSize
    }

    public func setSize(of widget: Widget, to size: SIMD2<Int>) {
        widget.size = size
    }

    public func createScrollContainer(for child: Widget) -> Widget {
        ScrollContainer(child: child)
    }

    public func updateScrollContainer(_ scrollView: Widget, environment: EnvironmentValues) {}

    public func setScrollBarPresence(
        ofScrollContainer scrollView: Widget, hasVerticalScrollBar: Bool,
        hasHorizontalScrollBar: Bool
    ) {
        let scrollContainer = scrollView as! ScrollContainer
        scrollContainer.hasVerticalScrollBar = hasVerticalScrollBar
        scrollContainer.hasHorizontalScrollBar = hasHorizontalScrollBar
    }

    public func createSelectableListView() -> Widget {
        SelectableListView()
    }

    public func baseItemPadding(ofSelectableListView listView: Widget) -> EdgeInsets {
        EdgeInsets(top: 0, bottom: 0, leading: 0, trailing: 0)
    }

    public func minimumRowSize(ofSelectableListView listView: Widget) -> SIMD2<Int> {
        .zero
    }

    public func setItems(
        ofSelectableListView listView: Widget, to items: [Widget], withRowHeights rowHeights: [Int]
    ) {
        let selectableListView = listView as! SelectableListView
        selectableListView.items = items
        selectableListView.rowHeights = rowHeights
    }

    public func setSelectionHandler(
        forSelectableListView listView: Widget, to action: @escaping (Int) -> Void
    ) {
        (listView as! SelectableListView).selectionHandler = action
    }

    public func setSelectedItem(ofSelectableListView listView: Widget, toItemAt index: Int?) {
        (listView as! SelectableListView).selectedIndex = index
    }

    public func createSplitView(leadingChild: Widget, trailingChild: Widget) -> Widget {
        SplitView(
            leadingChild: leadingChild,
            trailingChild: trailingChild
        )
    }

    public func setResizeHandler(ofSplitView splitView: Widget, to action: @escaping () -> Void) {
        (splitView as! SplitView).sidebarResizeHandler = action
    }

    public func sidebarWidth(ofSplitView splitView: Widget) -> Int {
        (splitView as! SplitView).sidebarWidth
    }

    public func setSidebarWidthBounds(
        ofSplitView splitView: Widget, minimum minimumWidth: Int, maximum maximumWidth: Int
    ) {
        let splitView = splitView as! SplitView
        splitView.minimumSidebarWidth = minimumWidth
        splitView.maximumSidebarWidth = maximumWidth
    }

    public func size(
        of text: String,
        whenDisplayedIn widget: Widget,
        proposedWidth: Int?,
        proposedHeight: Int?,
        environment: EnvironmentValues
    ) -> SIMD2<Int> {
        let resolvedFont = environment.resolvedFont
        let lineHeight = Int(resolvedFont.lineHeight)
        let characterHeight = Int(resolvedFont.pointSize)
        let characterWidth = characterHeight * 2 / 3

        guard let proposedWidth else {
            return SIMD2(
                characterWidth * text.count,
                lineHeight
            )
        }

        let charactersPerLine = max(1, proposedWidth / characterWidth)
        var lineCount = (text.count + charactersPerLine - 1) / charactersPerLine
        if let proposedHeight {
            lineCount = min(max(1, proposedHeight / lineHeight), lineCount)
        }

        return SIMD2(
            characterWidth * min(charactersPerLine, text.count),
            lineHeight * lineCount
        )
    }

    public func createTextView() -> Widget {
        TextView()
    }

    public func updateTextView(_ textView: Widget, content: String, environment: EnvironmentValues)
    {
        let textView = textView as! TextView
        textView.content = content
        textView.color = environment.suggestedForegroundColor.resolve(in: environment)
        textView.font = environment.resolvedFont
    }

    public func createImageView() -> Widget {
        ImageView()
    }

    public func updateImageView(
        _ imageView: Widget, rgbaData: [UInt8], width: Int, height: Int, targetWidth: Int,
        targetHeight: Int, dataHasChanged: Bool, environment: EnvironmentValues
    ) {
        let imageView = imageView as! ImageView
        imageView.rgbaData = rgbaData
        imageView.pixelWidth = width
        imageView.pixelHeight = height
    }

    public func createTable() -> Widget {
        Table()
    }

    public func setRowCount(ofTable table: Widget, to rows: Int) {
        (table as! Table).rowCount = rows
    }

    public func setColumnLabels(
        ofTable table: Widget, to labels: [String], environment: EnvironmentValues
    ) {
        (table as! Table).columnLabels = labels
    }

    public func setCells(
        ofTable table: Widget, to cells: [Widget], withRowHeights rowHeights: [Int]
    ) {
        let table = table as! Table
        table.cells = cells
        table.rowHeights = rowHeights
    }

    public func createButton() -> Widget {
        Button()
    }

    public func updateButton(
        _ button: Widget, label: String, environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        let button = button as! Button
        button.label = label
        button.action = action
    }

    public func updateButton(
        _ button: Widget, label: String, menu: Menu, environment: EnvironmentValues
    ) {
        let button = button as! Button
        button.label = label
        button.menu = menu
        button.font = environment.resolvedFont
    }

    public func createToggle() -> Widget {
        ToggleButton()
    }

    public func updateToggle(
        _ toggle: Widget, label: String, environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        let toggle = toggle as! ToggleButton
        toggle.label = label
        toggle.toggleHandler = onChange
        toggle.font = environment.resolvedFont
    }

    public func setState(ofToggle toggle: Widget, to state: Bool) {
        (toggle as! ToggleButton).state = state
    }

    public func createSwitch() -> Widget {
        ToggleSwitch()
    }

    public func updateSwitch(
        _ switchWidget: Widget, environment: SwiftCrossUI.EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        (switchWidget as! ToggleSwitch).toggleHandler = onChange
    }

    public func setState(ofSwitch switchWidget: Widget, to state: Bool) {
        (switchWidget as! ToggleSwitch).state = state
    }

    public func createCheckbox() -> Widget {
        Checkbox()
    }

    public func updateCheckbox(
        _ checkboxWidget: Widget, environment: SwiftCrossUI.EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        (checkboxWidget as! Checkbox).toggleHandler = onChange
    }

    public func setState(ofCheckbox checkboxWidget: Widget, to state: Bool) {
        (checkboxWidget as! Checkbox).state = state
    }

    public func createSlider() -> Widget {
        Slider()
    }

    public func updateSlider(
        _ slider: Widget, minimum: Double, maximum: Double, decimalPlaces: Int,
        environment: SwiftCrossUI.EnvironmentValues, onChange: @escaping (Double) -> Void
    ) {
        let slider = slider as! Slider
        slider.minimumValue = minimum
        slider.maximumValue = maximum
        slider.decimalPlaces = decimalPlaces
        slider.changeHandler = onChange
    }

    public func setValue(ofSlider slider: Widget, to value: Double) {
        (slider as! Slider).value = value
    }

    public func createTextField() -> Widget {
        TextField()
    }

    public func updateTextField(
        _ textField: Widget, placeholder: String, environment: SwiftCrossUI.EnvironmentValues,
        onChange: @escaping (String) -> Void, onSubmit: @escaping () -> Void
    ) {
        let textField = textField as! TextField
        textField.placeholder = placeholder
        textField.font = environment.resolvedFont
        textField.changeHandler = onChange
        textField.submitHandler = onSubmit
    }

    public func setContent(ofTextField textField: Widget, to content: String) {
        (textField as! TextField).value = content
    }

    public func getContent(ofTextField textField: Widget) -> String {
        (textField as! TextField).value
    }

    // public func createTextEditor() -> Widget {

    // }

    // public func updateTextEditor(_ textEditor: Widget, environment: SwiftCrossUI.EnvironmentValues, onChange: @escaping (String) -> Void) {

    // }

    // public func setContent(ofTextEditor textEditor: Widget, to content: String) {

    // }

    // public func getContent(ofTextEditor textEditor: Widget) -> String {

    // }

    // public func createPicker() -> Widget {

    // }

    // public func updatePicker(_ picker: Widget, options: [String], environment: SwiftCrossUI.EnvironmentValues, onChange: @escaping (Int?) -> Void) {

    // }

    // public func setSelectedOption(ofPicker picker: Widget, to selectedOption: Int?) {

    // }

    // public func createProgressSpinner() -> Widget {

    // }

    // public func createProgressBar() -> Widget {

    // }

    // public func updateProgressBar(_ widget: Widget, progressFraction: Double?, environment: SwiftCrossUI.EnvironmentValues) {

    // }

    // public func createPopoverMenu() -> Menu {

    // }

    // public func updatePopoverMenu(_ menu: Menu, content: SwiftCrossUI.ResolvedMenu, environment: SwiftCrossUI.EnvironmentValues) {

    // }

    // public func showPopoverMenu(_ menu: Menu, at position: SIMD2<Int>, relativeTo widget: Widget, closeHandler handleClose: @escaping () -> Void) {

    // }

    // public func createAlert() -> Alert {

    // }

    // public func updateAlert(_ alert: Alert, title: String, actionLabels: [String], environment: SwiftCrossUI.EnvironmentValues) {

    // }

    // public func showAlert(_ alert: Alert, window: Window?, responseHandler handleResponse: @escaping (Int) -> Void) {

    // }

    // public func dismissAlert(_ alert: Alert, window: Window?) {

    // }

    // public func createSheet(content: Widget) -> Sheet {

    // }

    // public func updateSheet(_ sheet: Sheet, window: Window, environment: SwiftCrossUI.EnvironmentValues, size: SIMD2<Int>, onDismiss: @escaping () -> Void, cornerRadius: Double?, detents: [SwiftCrossUI.PresentationDetent], dragIndicatorVisibility: SwiftCrossUI.Visibility, backgroundColor: SwiftCrossUI.Color.Resolved?, interactiveDismissDisabled: Bool) {

    // }

    // public func presentSheet(_ sheet: Sheet, window: Window, parentSheet: Sheet?) {

    // }

    // public func dismissSheet(_ sheet: Sheet, window: Window, parentSheet: Sheet?) {

    // }

    // public func size(ofSheet sheet: Sheet) -> SIMD2<Int> {

    // }

    // public func showOpenDialog(fileDialogOptions: SwiftCrossUI.FileDialogOptions, openDialogOptions: SwiftCrossUI.OpenDialogOptions, window: Window?, resultHandler handleResult: @escaping (SwiftCrossUI.DialogResult<[URL]>) -> Void) {

    // }

    // public func showSaveDialog(fileDialogOptions: SwiftCrossUI.FileDialogOptions, saveDialogOptions: SwiftCrossUI.SaveDialogOptions, window: Window?, resultHandler handleResult: @escaping (SwiftCrossUI.DialogResult<URL>) -> Void) {

    // }

    // public func createTapGestureTarget(wrapping child: Widget, gesture: SwiftCrossUI.TapGesture) -> Widget {

    // }

    // public func updateTapGestureTarget(_ tapGestureTarget: Widget, gesture: SwiftCrossUI.TapGesture, environment: SwiftCrossUI.EnvironmentValues, action: @escaping () -> Void) {

    // }

    // public func createHoverTarget(wrapping child: Widget) -> Widget {

    // }

    // public func updateHoverTarget(_ hoverTarget: Widget, environment: SwiftCrossUI.EnvironmentValues, action: @escaping (Bool) -> Void) {

    // }

    // public func createPathWidget() -> Widget {

    // }

    // public func createPath() -> Path {

    // }

    // public func updatePath(_ path: Path, _ source: SwiftCrossUI.Path, bounds: SwiftCrossUI.Path.Rect, pointsChanged: Bool, environment: SwiftCrossUI.EnvironmentValues) {

    // }

    // public func renderPath(_ path: Path, container: Widget, strokeColor: SwiftCrossUI.Color.Resolved, fillColor: SwiftCrossUI.Color.Resolved, overrideStrokeStyle: SwiftCrossUI.StrokeStyle?) {

    // }

    // public func createWebView() -> Widget {

    // }

    // public func updateWebView(_ webView: Widget, environment: SwiftCrossUI.EnvironmentValues, onNavigate: @escaping (URL) -> Void) {

    // }

    // public func navigateWebView(_ webView: Widget, to url: URL) {

    // }
}
