import Foundation

@MainActor
public protocol AppBackend_Base: Sendable {
    /// Creates an instance of the backend.
    init()

    /// The class of device that the backend is currently running on.
    ///
    /// This is used to determine text sizing and other adaptive properties.
    var deviceClass: DeviceClass { get }

    /// Runs the backend's main run loop.
    ///
    /// The app will exit when this method returns. This will always be the
    /// first method called by SwiftCrossUI.
    ///
    /// Often in UI frameworks (such as Gtk), code is run in a callback
    /// after starting the app, and hence this generic root window creation
    /// API must reflect that. This is always the first method to be called
    /// and is where boilerplate app setup should happen.
    ///
    /// The callback is where SwiftCrossUI will create windows, render
    /// initial views, start state handlers, etc. The setup action must be
    /// run exactly once. The backend must be fully functional before the
    /// callback is ready.
    ///
    /// It is up to the backend to decide whether the callback runs before or
    /// after the main loop starts. For example, some backends (such as
    /// `AppKitBackend`) can create windows and widgets before the run loop
    /// starts, so it makes the most sense to run the setup before the main run
    /// loop starts (it's also not possible to run the setup function once the
    /// main run loop starts anyway). On the other side is `GtkBackend` which
    /// must be on the main loop to create windows and widgets (because
    /// otherwise the root window has not yet been created, which is essential
    /// in Gtk), so the setup function is passed to `Gtk` as a callback to run
    /// once the main run loop starts.
    ///
    /// - Parameter callback: The callback to run.
    func runMainLoop(
        _ callback: @escaping @MainActor () -> Void
    )

    /// Sets the application's global menu.
    ///
    /// Some backends may make use of the host platform's global menu bar
    /// (such as macOS's menu bar), and others may render their own menu bar
    /// within the application.
    ///
    /// - Parameter submenus: The submenus of the global menu.
    func setApplicationMenu(_ submenus: [ResolvedMenu.Submenu])

    /// Runs an action in the app's main thread if required to perform UI updates
    /// by the backend.
    ///
    /// Predominantly used by ``Publisher`` to publish changes to a thread
    /// compatible with dispatching UI updates. Can be synchronous or
    /// asynchronous (for now).
    ///
    /// - Parameter action: The action to run in the main thread.
    nonisolated func runInMainThread(action: @escaping @MainActor () -> Void)

    /// Computes the root environment for an app (e.g. by checking the system's
    /// current theme).
    ///
    /// May fall back on the provided defaults where reasonable.
    ///
    /// - Parameter defaultEnvironment: The default environment.
    /// - Returns: The computed root environment.
    func computeRootEnvironment(defaultEnvironment: EnvironmentValues) -> EnvironmentValues

    /// Sets the handler to be notified when the root environment may need
    /// recomputation.
    ///
    /// This is intended to only be called once. Calling it more than once may
    /// or may not override the previous handler.
    ///
    /// - Parameter action: The root environment change handler.
    func setRootEnvironmentChangeHandler(to action: @escaping () -> Void)
}

/// A backend that can be used to run an app. Usually built on top of an
/// existing UI framework.
///
/// Default placeholder implementations are available for all non-essential
/// app lifecycle methods. These implementations will fatally crash when called
/// and are simply intended to allow incremental implementation of backends,
/// not a production-ready fallback for views that cannot be represented by a
/// given backend. The methods you need to implemented up-front (which don't
/// have default implementations) are: ``AppBackend/createWindow(withDefaultSize:)``,
/// ``AppBackend/setTitle(ofWindow:to:)``,
/// ``AppBackend/setBehaviors(ofWindow:closable:minimizable:resizable:)``,
/// ``AppBackend/setChild(ofWindow:to:)``, ``AppBackend/show(window:)``,
/// ``AppBackend/runMainLoop(_:)``, ``AppBackend/runInMainThread(action:)``,
/// ``AppBackend/isWindowProgrammaticallyResizable(_:)``,
/// ``AppBackend/show(widget:)``.
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
@MainActor
public protocol AppBackend:
    AppBackend_Base,
    AppBackend_Containers,
    AppBackend_PassiveViews,
    AppBackend_Controls,
    AppBackend_Alert,
    AppBackend_Sheet,
    AppBackend_Menus,
    AppBackend_CornerRadius,
    AppBackend_FileDialogs,
    AppBackend_Paths,
    AppBackend_WebView,
    AppBackend_Gestures,
    AppBackend_ExternalURLs,
    AppBackend_RevealFile
{}

extension AppBackend {
    /// Used by placeholder implementations of backend methods.
    private func todo(_ function: String = #function) -> Never {
        logger.critical("\(type(of: self)): \(function) not implemented")
        Foundation.exit(1)
    }

    private func ignored(_ function: String = #function) {
        #if DEBUG
            logger.warning(
                "\(type(of: self)): \(function) is being ignored; consult the documentation for further information"
            )
        #endif
    }

    // MARK: System

    public func openExternalURL(_ url: URL) throws {
        todo()
    }

    public func revealFile(_ url: URL) throws {
        todo()
    }

    // MARK: Windows

    public func setCloseHandler(
        ofWindow window: Window,
        to action: @escaping () -> Void
    ) {
        todo()
    }

    public func close(window: Window) {
        todo()
    }

    // MARK: Application

    public func setApplicationMenu(_ submenus: [ResolvedMenu.Submenu]) {
        todo()
    }

    public func setIncomingURLHandler(to action: @escaping (URL) -> Void) {
        todo()
    }

    // MARK: Containers

    public func createColorableRectangle() -> Widget {
        todo()
    }

    public func setColor(ofColorableRectangle widget: Widget, to color: Color.Resolved) {
        todo()
    }

    public func setCornerRadius(of widget: Widget, to radius: Int) {
        todo()
    }

    public func createScrollContainer(for child: Widget) -> Widget {
        todo()
    }

    public func updateScrollContainer(
        _ scrollView: Widget,
        environment: EnvironmentValues,
        bounceHorizontally: Bool,
        bounceVertically: Bool,
        hasHorizontalScrollBar: Bool,
        hasVerticalScrollBar: Bool
    ) {
        todo()
    }

    public func createSelectableListView() -> Widget {
        todo()
    }

    public func updateSelectableListView(
        _ selectableListView: Widget,
        environment: EnvironmentValues
    ) {
        todo()
    }

    public func baseItemPadding(ofSelectableListView listView: Widget) -> EdgeInsets {
        todo()
    }

    public func minimumRowSize(ofSelectableListView listView: Widget) -> SIMD2<Int> {
        todo()
    }

    public func setItems(
        ofSelectableListView listView: Widget,
        to items: [Widget],
        withRowHeights rowHeights: [Int]
    ) {
        todo()
    }

    public func setSelectionHandler(
        forSelectableListView listView: Widget,
        to action: @escaping (_ selectedIndex: Int) -> Void
    ) {
        todo()
    }

    public func setSelectedItem(ofSelectableListView listView: Widget, toItemAt index: Int?) {
        todo()
    }

    public func createSplitView(leadingChild: Widget, trailingChild: Widget) -> Widget {
        todo()
    }

    public func setResizeHandler(
        ofSplitView splitView: Widget,
        to action: @escaping () -> Void
    ) {
        todo()
    }

    public func sidebarWidth(ofSplitView splitView: Widget) -> Int {
        todo()
    }

    public func setSidebarWidthBounds(
        ofSplitView splitView: Widget,
        minimum minimumWidth: Int,
        maximum maximumWidth: Int
    ) {
        todo()
    }

    public func createTooltipContainer(wrapping child: Widget) -> Widget {
        todo()
    }

    public func updateTooltipContainer(_ widget: Widget, tooltip: String) {
        todo()
    }

    // MARK: Passive views

    public func size(
        of text: String,
        whenDisplayedIn widget: Widget,
        proposedWidth: Int?,
        proposedHeight: Int?,
        environment: EnvironmentValues
    ) -> SIMD2<Int> {
        todo()
    }

    public func createTextView(content: String, shouldWrap: Bool) -> Widget {
        todo()
    }
    public func updateTextView(
        _ textView: Widget,
        content: String,
        environment: EnvironmentValues
    ) {
        todo()
    }

    public func createImageView() -> Widget {
        todo()
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
        todo()
    }

    public func createTable() -> Widget {
        todo()
    }
    public func setRowCount(ofTable table: Widget, to rows: Int) {
        todo()
    }
    public func setColumnLabels(
        ofTable table: Widget,
        to labels: [String],
        environment: EnvironmentValues
    ) {
        todo()
    }
    public func setCells(
        ofTable table: Widget,
        to cells: [Widget],
        withRowHeights rowHeights: [Int]
    ) {
        todo()
    }

    // MARK: Controls

    public func createButton() -> Widget {
        todo()
    }
    public func updateButton(
        _ button: Widget,
        label: String,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        todo()
    }
    public func updateButton(
        _ button: Widget,
        label: String,
        menu: Menu,
        environment: EnvironmentValues
    ) {
        todo()
    }

    public func createToggle() -> Widget {
        todo()
    }
    public func updateToggle(
        _ toggle: Widget,
        label: String,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        todo()
    }
    public func setState(ofToggle toggle: Widget, to state: Bool) {
        todo()
    }

    public func createSwitch() -> Widget {
        todo()
    }
    public func updateSwitch(
        _ switchWidget: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        todo()
    }
    public func setState(ofSwitch switchWidget: Widget, to state: Bool) {
        todo()
    }

    public func createCheckbox() -> Widget {
        todo()
    }
    public func updateCheckbox(
        _ checkboxWidget: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        todo()
    }
    public func setState(ofCheckbox checkboxWidget: Widget, to state: Bool) {
        todo()
    }

    public func createSlider() -> Widget {
        todo()
    }
    public func updateSlider(
        _ slider: Widget,
        minimum: Double,
        maximum: Double,
        decimalPlaces: Int,
        environment: EnvironmentValues,
        onChange: @escaping (Double) -> Void
    ) {
        todo()
    }
    public func setValue(ofSlider slider: Widget, to value: Double) {
        todo()
    }

    public func createTextField() -> Widget {
        todo()
    }
    public func updateTextField(
        _ textField: Widget,
        placeholder: String,
        environment: EnvironmentValues,
        onChange: @escaping (String) -> Void,
        onSubmit: @escaping () -> Void
    ) {
        todo()
    }
    public func setContent(ofTextField textField: Widget, to content: String) {
        todo()
    }
    public func getContent(ofTextField textField: Widget) -> String {
        todo()
    }

    public func createTextEditor() -> Widget {
        todo()
    }
    public func updateTextEditor(
        _ textEditor: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (String) -> Void
    ) {
        todo()
    }
    public func setContent(ofTextEditor textEditor: Widget, to content: String) {
        todo()
    }
    public func getContent(ofTextEditor textEditor: Widget) -> String {
        todo()
    }

    public func createPicker(style: BackendPickerStyle) -> Widget {
        todo()
    }
    public func updatePicker(
        _ picker: Widget,
        options: [String],
        environment: EnvironmentValues,
        onChange: @escaping (Int?) -> Void
    ) {
        todo()
    }
    public func setSelectedOption(ofPicker picker: Widget, to selectedOption: Int?) {
        todo()
    }

    public func createProgressSpinner() -> Widget {
        todo()
    }

    public func createProgressBar() -> Widget {
        todo()
    }
    public func updateProgressBar(
        _ widget: Widget,
        progressFraction: Double?,
        environment: EnvironmentValues
    ) {
        todo()
    }

    public func createPopoverMenu() -> Menu {
        todo()
    }
    public func updatePopoverMenu(
        _ menu: Menu,
        content: ResolvedMenu,
        environment: EnvironmentValues
    ) {
        todo()
    }
    public func showPopoverMenu(
        _ menu: Menu,
        at position: SIMD2<Int>,
        relativeTo widget: Widget,
        closeHandler handleClose: @escaping () -> Void
    ) {
        todo()
    }

    public func createAlert() -> Alert {
        todo()
    }
    public func updateAlert(
        _ alert: Alert,
        title: String,
        actionLabels: [String],
        environment: EnvironmentValues
    ) {
        todo()
    }
    public func showAlert(
        _ alert: Alert,
        window: Window?,
        responseHandler handleResponse: @escaping (Int) -> Void
    ) {
        todo()
    }
    public func dismissAlert(_ alert: Alert, window: Window?) {
        todo()
    }

    public func showOpenDialog(
        fileDialogOptions: FileDialogOptions,
        openDialogOptions: OpenDialogOptions,
        window: Window?,
        resultHandler handleResult: @escaping (DialogResult<[URL]>) -> Void
    ) {
        todo()
    }
    public func showSaveDialog(
        fileDialogOptions: FileDialogOptions,
        saveDialogOptions: SaveDialogOptions,
        window: Window?,
        resultHandler handleResult: @escaping (DialogResult<URL>) -> Void
    ) {
        todo()
    }

    public func createTapGestureTarget(wrapping child: Widget, gesture: TapGesture) -> Widget {
        todo()
    }
    public func updateTapGestureTarget(
        _ clickTarget: Widget,
        gesture: TapGesture,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        todo()
    }

    // MARK: Paths
    public func createPathWidget() -> Widget {
        todo()
    }
    public func createPath() -> Path {
        todo()
    }
    public func updatePath(
        _ path: Path,
        _ source: SwiftCrossUI.Path,
        bounds: SwiftCrossUI.Path.Rect,
        pointsChanged: Bool,
        environment: EnvironmentValues
    ) {
        todo()
    }
    public func renderPath(
        _ path: Path,
        container: Widget,
        strokeColor: Color.Resolved,
        fillColor: Color.Resolved,
        overrideStrokeStyle: StrokeStyle?
    ) {
        todo()
    }

    public func createWebView() -> Widget {
        todo()
    }
    public func updateWebView(
        _ webView: Widget,
        environment: EnvironmentValues,
        onNavigate: @escaping (URL) -> Void
    ) {
        todo()
    }
    public func navigateWebView(
        _ webView: Widget,
        to url: URL
    ) {
        todo()
    }

    public func createHoverTarget(wrapping child: Widget) -> Widget {
        todo()
    }
    public func updateHoverTarget(
        _ container: Widget,
        environment: EnvironmentValues,
        action: @escaping (Bool) -> Void
    ) {
        todo()
    }

    public func createSheet(content: Widget) -> Sheet {
        todo()
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
        todo()
    }

    public func size(
        ofSheet sheet: Sheet
    ) -> SIMD2<Int> {
        todo()
    }

    public func presentSheet(
        _ sheet: Sheet,
        window: Window,
        parentSheet: Sheet?
    ) {
        todo()
    }

    public func dismissSheet(
        _ sheet: Sheet,
        window: Window,
        parentSheet: Sheet?
    ) {
        todo()
    }

    public func createDatePicker() -> Widget { todo() }

    public func updateDatePicker(
        _ datePicker: Widget,
        environment: EnvironmentValues,
        date: Date,
        range: ClosedRange<Date>,
        components: DatePickerComponents,
        onChange: @escaping (Date) -> Void
    ) { todo() }
}
