import Foundation

/// A backend that can be used to run an app. Usually built on top of an
/// existing UI framework.
///
/// Default placeholder implementations are available for all non-essential
/// app lifecycle methods. These implementations will fatally crash when called
/// and are simply intended to allow incremental implementation of backends,
/// not a production-ready fallback for views that cannot be represented by a
/// given backend. The methods you need to implemented up-front (which don't
/// have default implementations) are: ``AppBackend/createRootWindow(withDefaultSize:_:)``,
/// ``AppBackend/setTitle(ofWindow:to:)``, ``AppBackend/setResizability(ofWindow:to:)``,
/// ``AppBackend/setChild(ofWindow:to:)``, ``AppBackend/show(window:)``,
/// ``AppBackend/runMainLoop()``, ``AppBackend/runInMainThread(action:)``,
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
public protocol AppBackend: Sendable {
    associatedtype Window
    associatedtype Widget
    associatedtype Menu
    associatedtype Alert
    associatedtype Path
    associatedtype Sheet

    /// Creates an instance of the backend.
    init()

    /// The default height of a table row excluding cell padding. This is a
    /// recommendation by the backend that SwiftCrossUI won't necessarily
    /// follow in all cases.
    var defaultTableRowContentHeight: Int { get }
    /// The default vertical padding to apply to table cells. This is a
    /// recommendation by the backend that SwiftCrossUI won't necessarily
    /// follow in all cases. This is the amount of padding added above and
    /// below each cell, not the total amount added along the vertical axis.
    var defaultTableCellVerticalPadding: Int { get }
    /// The default amount of padding used when a user uses the ``View/padding(_:_:)``
    /// modifier.
    var defaultPaddingAmount: Int { get }
    /// Gets the layout width of a backend's scroll bars. Assumes that the width
    /// is the same for both vertical and horizontal scroll bars (where the width
    /// of a horizontal scroll bar is what pedants may call its height). If the
    /// backend uses overlay scroll bars then this width should be 0.
    ///
    /// This value may make sense to have as a computed property for some backends
    /// such as `AppKitBackend` where plugging in a mouse can cause the default
    /// scroll bar style to change. If something does cause this value to change,
    /// ensure that the configured root environment change handler gets called so
    /// that SwiftCrossUI can update the app's layout accordingly.
    var scrollBarWidth: Int { get }
    /// If `true`, a toggle in the ``ToggleStyle/switch`` style grows to fill its parent container.
    var requiresToggleSwitchSpacer: Bool { get }
    /// If `true`, all images in a window will get updated when the window's
    /// scale factor changes (``EnvironmentValues/windowScaleFactor``).
    ///
    /// Backends based on modern UI frameworks can usually get away with setting
    /// this to `false`, but backends such as `Gtk3Backend` have to set this to
    /// `true` to properly support HiDPI (aka Retina) displays because they
    /// manually rescale the image meaning that it must get rescaled when the
    /// scale factor changes.
    var requiresImageUpdateOnScaleFactorChange: Bool { get }
    /// How the backend handles rendering of menu buttons. Affects which menu-related methods
    /// are called.
    var menuImplementationStyle: MenuImplementationStyle { get }

    /// The class of device that the backend is currently running on. Used to
    /// determine text sizing and other adaptive properties.
    var deviceClass: DeviceClass { get }

    /// Whether the backend can reveal files in the system file manager or not.
    /// Mobile backends generally can't.
    var canRevealFiles: Bool { get }

    /// The supported date picker styles. Must include ``DatePickerStyle/automatic`` if date pickers
    /// are supported at all.
    nonisolated var supportedDatePickerStyles: [DatePickerStyle] { get }

    /// Often in UI frameworks (such as Gtk), code is run in a callback
    /// after starting the app, and hence this generic root window creation
    /// API must reflect that. This is always the first method to be called
    /// and is where boilerplate app setup should happen.
    ///
    /// Runs the backend's main run loop. The app will exit when this method
    /// returns. This wall always be the first method called by SwiftCrossUI.
    ///
    /// The callback is where SwiftCrossUI will create windows, render
    /// initial views, start state handlers, etc. The setup action must be
    /// run exactly once. The backend must be fully functional before the
    /// callback is ready.
    ///
    /// It is up to the backend to decide whether the callback runs before or
    /// after the main loop starts. For example, some backends such as the `AppKit`
    /// backend can create windows and widgets before the run loop starts, so it
    /// makes the most sense to run the setup before the main run loop starts (it's
    /// also not possible to run the setup function once the main run loop starts
    /// anyway). On the other side is the `Gtk` backend which must be on the
    /// main loop to create windows and widgets (because otherwise the root
    /// window has not yet been created, which is essential in Gtk), so the
    /// setup function is passed to `Gtk` as a callback to run once the main
    /// run loop starts.
    func runMainLoop(
        _ callback: @escaping @MainActor () -> Void
    )
    /// Creates a new window. For some backends it may make sense for this
    /// method to return the application's root window the first time its
    /// called, and only create new windows on subsequent invocations.
    ///
    /// The default size is a suggestion; for example some backends may choose
    /// to restore the user's preferred window size from a previous session.
    ///
    /// A window's content size has precendence over the default size. The
    /// window should always be at least the size of its content.
    func createWindow(withDefaultSize defaultSize: SIMD2<Int>?) -> Window
    /// Sets the title of a window.
    func setTitle(ofWindow window: Window, to title: String)
    /// Sets the behaviors of a window.
    /// - Parameters:
    ///   - window: The window to set the behaviors on.
    ///   - closable: Whether the window can be closed by the user.
    ///   - minimizable: Whether the window can be minimized by the user.
    ///   - resizable: Whether the window can be resized by the user. Even if
    ///     resizable, the window shouldn't be allowed to become smaller than its
    ///     minimum size, or larger than its maximum size.
    func setBehaviors(
        ofWindow window: Window,
        closable: Bool,
        minimizable: Bool,
        resizable: Bool
    )
    /// Sets the root child of a window (replaces the previous child if any).
    func setChild(ofWindow window: Window, to child: Widget)
    /// Gets the size of the given window in pixels.
    func size(ofWindow window: Window) -> SIMD2<Int>
    /// Check whether a window is programmatically resizable. This value does not necessarily
    /// reflect whether the window is resizable by the user.
    func isWindowProgrammaticallyResizable(_ window: Window) -> Bool
    /// Sets the size of the given window in pixels.
    func setSize(ofWindow window: Window, to newSize: SIMD2<Int>)
    /// Sets the minimum and maximum width and height of a window.
    ///
    /// Prevents the user from making the window any smaller or larger than the given minimum and
    /// maximum sizes, respectively.
    /// - Parameters:
    ///   - window: The window to set the size limits of.
    ///   - minimumSize: The minimum window size.
    ///   - maximumSize: The maximum window size. If `nil`, any existing maximum size
    ///     constraints should be removed.
    func setSizeLimits(
        ofWindow window: Window,
        minimum minimumSize: SIMD2<Int>,
        maximum maximumSize: SIMD2<Int>?
    )
    /// Sets the handler for the window's resizing events. `action` takes the proposed size
    /// of the window and returns the final size for the window (which allows SwiftCrossUI
    /// to implement features such as dynamic minimum window sizes based off the content's
    /// minimum size). Setting the resize handler overrides any previous handler.
    func setResizeHandler(
        ofWindow window: Window,
        to action: @escaping (_ newSize: SIMD2<Int>) -> Void
    )
    /// Shows a window after it has been created or updated (may be unnecessary
    /// for some backends). Predominantly used by window-based ``Scene``
    /// implementations after propagating updates.
    func show(window: Window)
    /// Brings a window to the front if possible. Called when the window
    /// receives an external URL or file to handle from the desktop environment.
    /// May be used in other circumstances eventually.
    func activate(window: Window)

    /// Sets the application's global menu. Some backends may make use of the host
    /// platform's global menu bar (such as macOS's menu bar), and others may render their
    /// own menu bar within the application.
    func setApplicationMenu(_ submenus: [ResolvedMenu.Submenu])

    /// Runs an action in the app's main thread if required to perform UI updates
    /// by the backend. Predominantly used by ``Publisher`` to publish changes to a thread
    /// compatible with dispatching UI updates. Can be synchronous or asynchronous (for now).
    nonisolated func runInMainThread(action: @escaping @MainActor () -> Void)

    /// Computes the root environment for an app (e.g. by checking the system's current
    /// theme). May fall back on the provided defaults where reasonable.
    func computeRootEnvironment(defaultEnvironment: EnvironmentValues) -> EnvironmentValues
    /// Sets the handler to be notified when the root environment may have to get
    /// recomputed. This is intended to only be called once. Calling it more than once
    /// may or may not override the previous handler.
    func setRootEnvironmentChangeHandler(to action: @escaping () -> Void)

    /// Resolves the given text style to concrete font properties.
    ///
    /// This method doesn't take ``EnvironmentValues`` because its result
    /// should be consistent when given the same text style twice. Font modifiers
    /// take effect later in the font resolution process.
    ///
    /// A default implementation is provided. It uses the backend's reported
    /// device class and looks up the text style in a lookup table derived
    /// from Apple's typography guidelines. See ``TextStyle/resolve(for:)``.
    func resolveTextStyle(_ textStyle: Font.TextStyle) -> Font.TextStyle.Resolved

    /// Resolves the given adaptive color to a concrete color given the current environment.
    ///
    /// The default implementation uses Apple's adaptive colors.
    func resolveAdaptiveColor(
        _ adaptiveColor: Color.SystemAdaptive,
        in environment: EnvironmentValues
    ) -> Color.Resolved

    /// Computes a window's environment based off the root environment. This may involve
    /// updating ``EnvironmentValues/windowScaleFactor`` etc.
    func computeWindowEnvironment(
        window: Window,
        rootEnvironment: EnvironmentValues
    ) -> EnvironmentValues
    /// Sets the handler to be notified when the window's contribution to the
    /// environment may have to be recomputed. Use this for things such as
    /// updating a window's scale factor in the environment when the window
    /// changes displays.
    ///
    /// In future this may be useful for color space handling.
    func setWindowEnvironmentChangeHandler(
        of window: Window,
        to action: @escaping () -> Void
    )

    /// Sets the handler for URLs directed to the application (e.g. URLs
    /// associated with a custom URL scheme).
    func setIncomingURLHandler(to action: @escaping (URL) -> Void)

    /// Opens an external URL in the system browser or app registered for the
    /// URL's protocol.
    func openExternalURL(_ url: URL) throws

    /// Reveals a file in the system's file manager. This opens
    /// the file's enclosing directory and highlighting the file.
    func revealFile(_ url: URL) throws

    /// Shows a widget after it has been created or updated (may be unnecessary
    /// for some backends). Predominantly used by ``ViewGraphNode`` after
    /// propagating updates.
    func show(widget: Widget)
    /// Adds a short tag to a widget to assist during debugging if the backend supports
    /// such a feature. Some backends may only apply tags under particular conditions
    /// such as when being built in debug mode.
    func tag(widget: Widget, as tag: String)

    // MARK: Containers

    /// Creates a container in which children can be layed out by SwiftCrossUI using exact
    /// pixel positions.
    func createContainer() -> Widget
    /// Removes all children of the given container.
    func removeAllChildren(of container: Widget)
    /// Inserts a child into a given container at a given index.
    func insert(_ child: Widget, into container: Widget, at index: Int)
    /// Swaps the child at firstIndex with the child at secondIndex. May crash if either
    /// index is out of bounds.
    func swap(childAt firstIndex: Int, withChildAt secondIndex: Int, in container: Widget)
    /// Sets the position of the specified child in a container.
    func setPosition(ofChildAt index: Int, in container: Widget, to position: SIMD2<Int>)
    /// Removes the child at the given index from the given container.
    func remove(childAt index: Int, from container: Widget)

    /// Creates a rectangular widget with configurable color.
    func createColorableRectangle() -> Widget
    /// Sets the color of a colorable rectangle.
    func setColor(ofColorableRectangle widget: Widget, to color: Color.Resolved)

    /// Sets the corner radius of a widget (any widget). Should affect the view's border radius
    /// as well.
    func setCornerRadius(of widget: Widget, to radius: Int)

    /// Gets the natural size of a given widget. E.g. the natural size of a button may be the size
    /// of the label (without line wrapping) plus a bit of padding and a border.
    func naturalSize(of widget: Widget) -> SIMD2<Int>
    /// Sets the size of a widget.
    func setSize(of widget: Widget, to size: SIMD2<Int>)

    /// Creates a scrollable single-child container wrapping the given widget.
    func createScrollContainer(for child: Widget) -> Widget
    /// Updates a scroll container with environment-specific values.
    ///
    /// This method is primarily used on iOS to apply environment changes
    /// that affect the scroll view’s behavior, such as keyboard dismissal mode.
    ///
    /// - Parameters:
    ///   - scrollView: The scroll container widget previously created by `createScrollContainer(for:)`.
    ///   - environment: The current `EnvironmentValues` to apply.
    func updateScrollContainer(
        _ scrollView: Widget,
        environment: EnvironmentValues
    )
    /// Sets the presence of scroll bars along each axis of a scroll container.
    func setScrollBarPresence(
        ofScrollContainer scrollView: Widget,
        hasVerticalScrollBar: Bool,
        hasHorizontalScrollBar: Bool
    )

    /// Creates a list with selectable rows.
    func createSelectableListView() -> Widget
    /// Gets the amount of padding introduced by the backend around the content of
    /// each row. Ideally backends should get rid of base padding so that SwiftCrossUI
    /// can give developers more freedom, but this isn't always possible.
    func baseItemPadding(ofSelectableListView listView: Widget) -> EdgeInsets
    /// Gets the minimum size for rows in the list view. This doesn't necessarily have to
    /// be just for hard requirements enforced by the backend, it can also just be an
    /// idiomatic minimum size for the platform.
    func minimumRowSize(ofSelectableListView listView: Widget) -> SIMD2<Int>
    /// Sets the items of a selectable list along with their heights. Row heights should
    /// include base item padding (i.e. they should be the external height of the row rather
    /// than the internal height).
    func setItems(
        ofSelectableListView listView: Widget,
        to items: [Widget],
        withRowHeights rowHeights: [Int]
    )
    /// Sets the action to perform when a user selects an item in the list.
    func setSelectionHandler(
        forSelectableListView listView: Widget,
        to action: @escaping (_ selectedIndex: Int) -> Void
    )
    /// Sets the list's selected item by index.
    func setSelectedItem(ofSelectableListView listView: Widget, toItemAt index: Int?)

    /// Creates a split view containing two children visible side by side.
    ///
    /// If you need to modify the leading and trailing children after creation nest them
    /// inside another container such as a VStack (avoiding update methods makes maintaining
    /// a multitude of backends a bit easier).
    func createSplitView(leadingChild: Widget, trailingChild: Widget) -> Widget
    /// Sets the function to be called when the split view's panes get resized.
    func setResizeHandler(
        ofSplitView splitView: Widget,
        to action: @escaping () -> Void
    )
    /// Gets the width of a split view's sidebar.
    func sidebarWidth(ofSplitView splitView: Widget) -> Int
    /// Sets the minimum and maximum width of a split view's sidebar.
    func setSidebarWidthBounds(
        ofSplitView splitView: Widget,
        minimum minimumWidth: Int,
        maximum maximumWidth: Int
    )

    // MARK: Passive views

    /// Gets the size that the given text would have if it were layed out attempting to stay
    /// within the proposed frame. The given text should be truncated/ellipsized to fit within
    /// the proposal if possible.
    ///
    /// The size returned by this function will be upheld by the layout
    /// system; child views always get the final say on their own size, parents just choose how
    /// the children get layed out. The text should get truncated to fit within the proposal if
    /// possible.
    ///
    /// SwiftCrossUI will never supply zero as the proposed width or height, because some UI
    /// frameworks handle that in special ways.
    ///
    /// The target widget is supplied because some backends (such as Gtk) require a
    /// reference to the target widget to get a text layout context.
    ///
    /// Used by both ``SwiftCrossUI/Text`` and ``SwiftCrossUI/TextEditor``.
    func size(
        of text: String,
        whenDisplayedIn widget: Widget,
        proposedWidth: Int?,
        proposedHeight: Int?,
        environment: EnvironmentValues
    ) -> SIMD2<Int>

    /// Creates a non-editable text view with optional text wrapping. Predominantly used
    /// by ``Text``.
    ///
    /// The returned widget should truncate and ellipsize its content when given a size
    /// which isn't big enough to fit the full content, as per
    /// ``size(of:whenDisplayedIn:proposedWidth:proposedHeight:environment)``.
    func createTextView() -> Widget
    /// Sets the content and wrapping mode of a non-editable text view.
    func updateTextView(_ textView: Widget, content: String, environment: EnvironmentValues)

    /// Creates an image view from an image file (specified by path). Predominantly used
    /// by ``Image``.
    func createImageView() -> Widget
    /// Sets the image data to be displayed.
    /// - Parameters:
    ///   - imageView: The image view to update.
    ///   - rgbaData: The pixel data (as rows of pixels concatenated into a flat array).
    ///   - width: The width of the image in pixels (should only be used to interpret `rgbaData`, not
    ///     to influence the size of the image on-screen).
    ///   - height: The height of the image in pixels (should only be used to interpret `rgbaData`, not
    ///     to influence the size of the image on-screen).
    ///   - targetWidth: The width that the image must have on-screen. Guaranteed to match
    ///     the width the widget will be given, so backends that don't have to manually
    ///     scale the underlying pixel data can safely ignore this parameter.
    ///   - targetHeight: the height that the image must have on-screen. Guaranteed to match
    ///     the height the widget will be given, so backends that don't have to manually
    ///     scale the underlying pixel data can safely ignore this parameter.
    ///   - dataHasChanged: If `false`, then `rgbaData` hasn't changed since the last call,
    ///     so backends that don't have to manually resize the image data don't have to do
    ///     anything.
    ///   - environment: The environment of the image view.
    func updateImageView(
        _ imageView: Widget,
        rgbaData: [UInt8],
        width: Int,
        height: Int,
        targetWidth: Int,
        targetHeight: Int,
        dataHasChanged: Bool,
        environment: EnvironmentValues
    )

    /// Creates an empty table.
    func createTable() -> Widget
    /// Sets the number of rows of a table. Existing rows outside of the new bounds should
    /// be deleted.
    func setRowCount(ofTable table: Widget, to rows: Int)
    /// Sets the labels of a table's columns. Also sets the number of columns of the table to the
    /// number of labels provided.
    func setColumnLabels(ofTable table: Widget, to labels: [String], environment: EnvironmentValues)
    /// Sets the contents of the table as a flat array of cells in order of and grouped by row. Also
    /// sets the height of each row's content.
    ///
    /// A nested array would have significantly more overhead, especially for large arrays.
    func setCells(ofTable table: Widget, to cells: [Widget], withRowHeights rowHeights: [Int])

    // MARK: Controls

    /// Creates a labelled button with an action triggered on click. Predominantly used
    /// by ``Button``.
    func createButton() -> Widget
    /// Sets a button's label and action. The action replaces any existing actions.
    func updateButton(
        _ button: Widget,
        label: String,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    )
    /// Sets a button's label and menu. Only used when ``menuImplementationStyle`` is
    /// ``MenuImplementationStyle/menuButton``.
    func updateButton(
        _ button: Widget,
        label: String,
        menu: Menu,
        environment: EnvironmentValues
    )

    /// Creates a labelled toggle that is either on or off.
    func createToggle() -> Widget
    /// Sets the label and change handler of a toggle (replaces any existing change handlers).
    /// The change handler is called whenever the button is toggled on or off.
    func updateToggle(
        _ toggle: Widget,
        label: String,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    )
    /// Sets the state of the button to active or not.
    func setState(ofToggle toggle: Widget, to state: Bool)

    /// Creates a switch that is either on or off.
    func createSwitch() -> Widget
    /// Sets the change handler of a switch (replaces any existing change handlers).
    /// The change handler is called whenever the switch is toggled on or off.
    func updateSwitch(
        _ switchWidget: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    )
    /// Sets the state of the switch to active or not.
    func setState(ofSwitch switchWidget: Widget, to state: Bool)

    /// Creates a checkbox that is either on or off.
    func createCheckbox() -> Widget
    /// Sets the change handler of a checkbox (replaces any existing change handlers).
    /// The change handler is called whenever the checkbox is toggled on or off.
    func updateCheckbox(
        _ checkboxWidget: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    )
    /// Sets the state of the checkbox to active or not.
    func setState(ofCheckbox checkboxWidget: Widget, to state: Bool)

    /// Creates a slider for choosing a numerical value from a range. Predominantly used
    /// by ``Slider``.
    func createSlider() -> Widget
    /// Sets the minimum and maximum selectable value of a slider (inclusive), the number of decimal
    /// places displayed by the slider, and the slider's change handler (replaces any existing
    /// change handlers).
    func updateSlider(
        _ slider: Widget,
        minimum: Double,
        maximum: Double,
        decimalPlaces: Int,
        environment: EnvironmentValues,
        onChange: @escaping (Double) -> Void
    )
    /// Sets the selected value of a slider.
    func setValue(ofSlider slider: Widget, to value: Double)

    /// Creates an editable text field with a placeholder label and change handler. The
    /// change handler is called whenever the displayed value changes. Predominantly
    /// used by ``TextField``.
    func createTextField() -> Widget
    /// Sets the placeholder label and change handler of an editable text field. The new
    /// change handler replaces any existing change handlers, and is called whenever the
    /// displayed value changes. `onSubmit` gets called when the user hits Enter/Return,
    /// or whatever the backend decides counts as submission of the field.
    ///
    /// The backend shouldn't wait until the user finishes typing to call the change handler;
    /// it should allow live access to the value.
    func updateTextField(
        _ textField: Widget,
        placeholder: String,
        environment: EnvironmentValues,
        onChange: @escaping (String) -> Void,
        onSubmit: @escaping () -> Void
    )
    /// Sets the value of an editable text field.
    func setContent(ofTextField textField: Widget, to content: String)
    /// Gets the value of an editable text field.
    func getContent(ofTextField textField: Widget) -> String

    /// Creates an editable multi-line text editor with a placeholder label and change
    /// handler. The change handler is called whenever the displayed value changes.
    /// Predominantly used by ``TextEditor``.
    func createTextEditor() -> Widget
    /// Sets the placeholder label and change handler of an editable multi-line text editor.
    /// The new change handler replaces any existing change handlers, and is called
    /// whenever the displayed value changes.
    ///
    /// The backend shouldn't wait until the user finishes typing to call the change
    /// handler; it should allow live access to the value.
    func updateTextEditor(
        _ textEditor: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (String) -> Void
    )
    /// Sets the value of an editable multi-line text editor.
    func setContent(ofTextEditor textEditor: Widget, to content: String)
    /// Gets the value of an editable multi-line text editor.
    func getContent(ofTextEditor textEditor: Widget) -> String

    /// Creates a picker for selecting from a finite set of options (e.g. a radio button group,
    /// a drop-down, a picker wheel). Predominantly used by ``Picker``. The change handler is
    /// called whenever a selection is made (even if the same option is picked again).
    func createPicker() -> Widget
    /// Sets the options for a picker to display, along with a change handler for when its
    /// selected option changes. The change handler replaces any existing change handlers and
    /// is called whenever a selection is made (even if the same option is picked again).
    func updatePicker(
        _ picker: Widget,
        options: [String],
        environment: EnvironmentValues,
        onChange: @escaping (Int?) -> Void
    )
    /// Sets the index of the selected option of a picker.
    func setSelectedOption(ofPicker picker: Widget, to selectedOption: Int?)

    func createDatePicker() -> Widget

    func updateDatePicker(
        _ datePicker: Widget,
        environment: EnvironmentValues,
        date: Date,
        range: ClosedRange<Date>,
        components: DatePickerComponents,
        onChange: @escaping (Date) -> Void
    )

    /// Creates an indeterminate progress spinner.
    func createProgressSpinner() -> Widget

    /// Sets the size of a progress spinner.
    ///
    /// This method exists because AppKitBackend requires special handling to resize progress spinners.
    ///
    /// The default implementation forwards to ``AppBackend/setSize(of:to:)``.
    func setSize(
        ofProgressSpinner widget: Widget,
        to size: SIMD2<Int>
    )

    /// Creates a progress bar.
    func createProgressBar() -> Widget
    /// Updates a progress bar to reflect the given progress (between 0 and 1), and the
    /// current view environment.
    /// - Parameter progressFraction: If `nil`, then the bar should show an indeterminate
    ///   animation if possible.
    func updateProgressBar(
        _ widget: Widget,
        progressFraction: Double?,
        environment: EnvironmentValues
    )

    /// Creates a popover menu (the sort you often see when right clicking on
    /// apps). The menu won't be visible when first created.
    func createPopoverMenu() -> Menu
    /// Updates a popover menu's content and appearance.
    func updatePopoverMenu(
        _ menu: Menu,
        content: ResolvedMenu,
        environment: EnvironmentValues
    )
    /// Shows the popover menu at a position relative to the given widget. Only used when
    /// ``menuImplementationStyle`` is ``MenuImplementationStyle/dynamicPopover``.
    func showPopoverMenu(
        _ menu: Menu,
        at position: SIMD2<Int>,
        relativeTo widget: Widget,
        closeHandler handleClose: @escaping () -> Void
    )

    /// Creates an alert object (without showing it yet). Alerts contain a
    /// title, an optional body, and a set of action buttons. They also
    /// prevent users from interacting with the parent window until dimissed.
    func createAlert() -> Alert
    /// Updates the content and appearance of an alert. Can only be called once.
    func updateAlert(
        _ alert: Alert,
        title: String,
        actionLabels: [String],
        environment: EnvironmentValues
    )
    /// Shows an alert as a modal on top of or within the given window.
    /// Users should be unable to interact with the parent window until the
    /// alert gets dismissed. `handleResponse` must get called once an action
    /// button is selected, with its sole argument representing the index of
    /// the action selected (as per the `actionLabels` array). The alert will
    /// have been hidden by the time the response handler gets called.
    ///
    /// Must only get called once for any given alert.
    ///
    /// If `window` is `nil`, the backend can either make the alert a whole
    /// app modal, a standalone window, or a modal for a window of its choosing.
    func showAlert(
        _ alert: Alert,
        window: Window?,
        responseHandler handleResponse: @escaping (Int) -> Void
    )
    /// Dismisses an alert programmatically without invoking the response
    /// handler. Must only be called after
    /// ``showAlert(_:window:responseHandler:)``.
    func dismissAlert(_ alert: Alert, window: Window?)

    /// Creates a sheet object (without showing it yet). Sheets contain view content.
    /// They optionally execute provided code on dismiss and
    /// prevent users from interacting with the parent window until dimissed.
    func createSheet(content: Widget) -> Sheet

    /// Updates the content, appearance and behaviour of a sheet.
    /// - Parameters:
    ///   - sheet: The sheet to update.
    ///   - window: The root window that the sheet will be presented in. Used on
    ///     platforms such as tvOS to compute layout constraints. The sheet
    ///     shouldn't get attached to the window by updateSheet. That is handled
    ///     by presentSheet which is guaranteed to be called exactly once (unlike
    ///     updateSheet which gets called whenever preferences or sizing change).
    ///   - environment: The environment that the sheet will be presented in. This
    ///     differs from the environment passed to the sheet's content.
    ///   - onDismiss: An action to perform when the sheet gets dismissed by
    ///     the user. Not triggered by programmatic dismissals. But is triggered
    ///     by the implicit dismissals of nested sheets when their parent sheet
    ///     is programmatically dismissed.
    ///   - cornerRadius: The radius of the sheet. If `nil`, the platform
    ///     default should be used. Not all backends can support this (e.g. macOS
    ///     doesn't support custom window corner radii).
    ///   - detents: An array of sizes that the sheet should snap to. This is
    ///     generally only a thing on mobile where sheets can be dragged up
    ///     and down.
    ///   - dragIndicatorVisibility: Whether the drag indicator should be shown.
    ///     Sheet drag indicators are generally only a thing on mobile, and
    ///     usually appear as a small horizontal bar at the top of the sheet.
    ///   - backgroundColor: The background color to use for the sheet. If `nil`,
    ///     the platform's default sheet background style should be used.
    ///   - interactiveDismissDisabled: Whether to dismiss user-driven sheet
    ///     dismissal. On mobile this disables swiping to dismiss a sheet, and on
    ///     desktop this usually disabled dismissal shortcuts such as the escape
    ///     key and/or removes system-provided close/cancel buttons from the sheet.
    func updateSheet(
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
    )

    /// Presents a sheet as a modal on top of or within the given window. Sheets
    /// should disable interaction with all content below them until they get
    /// dismissed.
    ///
    /// `onDismiss` only gets called once the sheet has been closed.
    ///
    /// This method must only be called once for any given sheet.
    ///
    /// - Parameters:
    ///   - sheet: The sheet to present.
    ///   - window: The window to present the sheet on top of.
    ///   - parentSheet: The sheet that the current sheet was presented from, if any.
    func presentSheet(
        _ sheet: Sheet,
        window: Window,
        parentSheet: Sheet?
    )

    /// Dismisses a sheet programmatically. Used by the ``View/sheet`` modifier
    /// to close sheets.
    ///
    /// - Parameters:
    ///   - sheet: The sheet to dismiss.
    ///   - window: The window that the sheet was presented in.
    ///   - parentSheet: The sheet that presented the current sheet, if any.
    func dismissSheet(_ sheet: Sheet, window: Window, parentSheet: Sheet?)

    /// Get the dimensions of a sheet
    func size(ofSheet sheet: Sheet) -> SIMD2<Int>

    /// Presents an 'Open file' dialog to the user for selecting files or
    /// folders.
    ///
    /// If `window` is `nil`, the backend can either make the dialog a whole
    /// app modal, a standalone window, or a modal for a window of its choosing.
    func showOpenDialog(
        fileDialogOptions: FileDialogOptions,
        openDialogOptions: OpenDialogOptions,
        window: Window?,
        resultHandler handleResult: @escaping (DialogResult<[URL]>) -> Void
    )

    /// Presents a 'Save file' dialog to the user for selecting a file save
    /// destination.
    ///
    /// If `window` is `nil`, the backend can either make the dialog a whole
    /// app modal, a standalone window, or a modal for a window of its choosing.
    func showSaveDialog(
        fileDialogOptions: FileDialogOptions,
        saveDialogOptions: SaveDialogOptions,
        window: Window?,
        resultHandler handleResult: @escaping (DialogResult<URL>) -> Void
    )

    /// Wraps a view in a container that can receive tap gestures. Some
    /// backends may not have to wrap the child, in which case they may
    /// just return the child as is.
    func createTapGestureTarget(wrapping child: Widget, gesture: TapGesture) -> Widget
    /// Update the tap gesture target with a new action. Replaces the old
    /// action.
    func updateTapGestureTarget(
        _ tapGestureTarget: Widget,
        gesture: TapGesture,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    )

    /// Wraps a view in a container that can receive mouse hover events. Some
    /// backends may not have to wrap the child, in which case they may
    /// just return the child as is.
    func createHoverTarget(wrapping child: Widget) -> Widget
    /// Update the hover target with a new action. Replaces the old
    /// action.
    func updateHoverTarget(
        _ hoverTarget: Widget,
        environment: EnvironmentValues,
        action: @escaping (Bool) -> Void
    )

    // MARK: Paths

    /// Create a widget that can contain a path.
    func createPathWidget() -> Widget
    /// Create a path. It will not be shown until ``renderPath(_:container:)`` is called.
    func createPath() -> Path
    /// Update a path. The updates do not need to be visible before ``renderPath(_:container:)``
    /// is called.
    /// - Parameters:
    ///   - path: The path to be updated.
    ///   - source: The source to copy the path from.
    ///   - bounds: The bounds that the path is getting rendered in. This gets
    ///     passed to backends because AppKit uses a different coordinate system
    ///     (with a flipped y axis) and therefore needs to perform coordinate
    ///     conversions.
    ///   - pointsChanged: If `false`, the ``Path/actions`` of the source have not changed.
    ///   - environment: The environment of the path.
    func updatePath(
        _ path: Path,
        _ source: SwiftCrossUI.Path,
        bounds: SwiftCrossUI.Path.Rect,
        pointsChanged: Bool,
        environment: EnvironmentValues
    )
    /// Draw a path to the screen.
    /// - Parameters:
    ///   - path: The path to be rendered.
    ///   - container: The container widget that the path will render in. Created with
    ///     ``createPathWidget()``.
    ///   - strokeColor: The color to draw the path's stroke.
    ///   - fillColor: The color to shade the path's fill.
    ///   - overrideStrokeStyle: If present, a value to override the path's stroke style.
    func renderPath(
        _ path: Path,
        container: Widget,
        strokeColor: Color.Resolved,
        fillColor: Color.Resolved,
        overrideStrokeStyle: StrokeStyle?
    )

    // MARK: Web view

    /// Create a web view.
    func createWebView() -> Widget
    /// Update a web view to reflect the given environment and use the given
    /// navigation handler.
    func updateWebView(
        _ webView: Widget,
        environment: EnvironmentValues,
        onNavigate: @escaping (URL) -> Void
    )
    /// Navigates a web view to a given URL.
    func navigateWebView(_ webView: Widget, to url: URL)
}

extension AppBackend {
    public func resolveTextStyle(
        _ textStyle: Font.TextStyle
    ) -> Font.TextStyle.Resolved {
        textStyle.resolve(for: deviceClass)
    }

    public func resolveAdaptiveColor(
        _ adaptiveColor: Color.SystemAdaptive,
        in environment: EnvironmentValues
    ) -> Color.Resolved {
        let color: Color = switch adaptiveColor.kind {
            case .blue: .blue
            case .brown: .brown
            case .gray: .gray
            case .green: .green
            case .orange: .orange
            case .purple: .purple
            case .red: .red
            case .yellow: .yellow
        }

        return color.resolve(in: environment)
    }

    public func tag(widget: Widget, as tag: String) {
        // This is only really to assist contributors when debugging backends,
        // so it's safe enough to have a no-op default implementation.
    }
}

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

    public func updateScrollContainer(_ scrollView: Widget, environment: EnvironmentValues) {
        todo()
    }

    public func setScrollBarPresence(
        ofScrollContainer scrollView: Widget,
        hasVerticalScrollBar: Bool,
        hasHorizontalScrollBar: Bool
    ) {
        todo()
    }

    public func createSelectableListView() -> Widget {
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

    public func createPicker() -> Widget {
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

    public func setSize(
        ofProgressSpinner widget: Widget,
        to size: SIMD2<Int>
    ) {
        setSize(of: widget, to: size)
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
