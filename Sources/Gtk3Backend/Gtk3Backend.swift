import CGtk3
import Foundation
import Gtk3
import SwiftCrossUI

extension App {
    public typealias Backend = Gtk3Backend

    public var backend: Gtk3Backend {
        Gtk3Backend(appIdentifier: Self.metadata?.identifier)
    }
}

public final class Gtk3Backend: AppBackend {
    public typealias Window = Gtk3.ApplicationWindow
    public typealias Widget = Gtk3.Widget
    public typealias Menu = Gtk3.Menu
    public typealias Alert = Gtk3.MessageDialog
    public typealias Sheet = Gtk3.Window

    public final class Path {
        var path: SwiftCrossUI.Path?
        var scaleFactor: Double = 1
    }

    public let defaultTableRowContentHeight = 20
    public let defaultTableCellVerticalPadding = 4
    public let defaultPaddingAmount = 10
    public let requiresToggleSwitchSpacer = false
    public let scrollBarWidth = 0
    public let requiresImageUpdateOnScaleFactorChange = true
    public let menuImplementationStyle = MenuImplementationStyle.dynamicPopover
    public let canRevealFiles = true
    public let deviceClass = DeviceClass.desktop
    public let supportedDatePickerStyles: [DatePickerStyle] = []

    var gtkApp: Application

    /// A window to be returned on the next call to ``GtkBackend/createWindow``.
    /// This is necessary because Gtk creates a root window no matter what, and
    /// this needs to be returned on the first call to `createWindow`.
    var precreatedWindow: Window?

    /// All current windows associated with the application. Doesn't include the
    /// precreated window until it gets 'created' via `createWindow`.
    var windows: [Window] = []

    private struct LogLocation: Hashable, Equatable {
        let file: String
        let line: Int
        let column: Int
    }

    private var logsPerformed: Set<LogLocation> = []

    func debugLogOnce(
        _ message: String,
        file: String = #file,
        line: Int = #line,
        column: Int = #column
    ) {
        #if DEBUG
            let location = LogLocation(file: file, line: line, column: column)
            if logsPerformed.insert(location).inserted {
                logger.notice("\(message)")
            }
        #endif
    }

    // A separate initializer to satisfy ``AppBackend``'s requirements.
    public convenience init() {
        self.init(appIdentifier: nil)
    }

    /// Creates a backend instance. If `appIdentifier` is `nil`, the default
    /// identifier `com.example.SwiftCrossUIApp` is used.
    public init(appIdentifier: String?) {
        gtkApp = Application(
            applicationId: appIdentifier ?? "com.example.SwiftCrossUIApp",
            flags: G_APPLICATION_HANDLES_OPEN
        )
        gtkApp.registerSession = true
    }

    public func runMainLoop(_ callback: @escaping @MainActor () -> Void) {
        gtkApp.run { window in
            self.precreatedWindow = window
            callback()

            let provider = CSSProvider()
            provider.loadCss(
                from: """
                    .dialog-vbox .horizontal .vertical {
                        padding-top: 11px;
                        margin-bottom: -10px;
                    }

                    @binding-set DisableEscape {
                        unbind "Escape";
                    }

                    messagedialog {
                        -gtk-key-bindings: DisableEscape;
                    }

                    list {
                        background: none;
                    }

                    list > row {
                        padding: 0;
                        min-height: 0;
                    }

                    .navigation-sidebar {
                        margin: 0;
                        padding: 0;
                    }

                    .navigation-sidebar > row {
                        margin: 0;
                        padding: 0;
                    }

                    textview text {
                        background: none;
                    }
                    """
            )
            gtk_style_context_add_provider_for_screen(
                gdk_screen_get_default(),
                OpaquePointer(provider.pointer),
                guint(GTK_STYLE_PROVIDER_PRIORITY_APPLICATION)
            )

            #if !os(macOS)
                Self.mainRunLoopTicklingLoop()
            #endif
        }
    }

    private static func mainRunLoopTicklingLoop(nextDelayMilliseconds: Int? = nil) {
        Self.runInMainThread(afterMilliseconds: nextDelayMilliseconds ?? 50) {
            let nextDate = RunLoop.main.limitDate(forMode: .default)
            // This isn't expected to be nil, but if it is we can just loop
            // again quickly with the default delay.
            let nextDelay = nextDate.map {
                return max(min(Int($0.timeIntervalSinceNow * 1000), 50), 0)
            }
            mainRunLoopTicklingLoop(nextDelayMilliseconds: nextDelay)
        }
    }

    public func createWindow(withDefaultSize defaultSize: SIMD2<Int>?) -> Window {
        let window: Gtk3.ApplicationWindow
        if let precreatedWindow {
            self.precreatedWindow = nil
            window = precreatedWindow
            window.setPosition(to: .center)
        } else {
            window = Gtk3.ApplicationWindow(application: gtkApp)
        }

        windows.append(window)

        if let defaultSize {
            window.defaultSize = Size(
                width: defaultSize.x,
                height: defaultSize.y
            )
        }

        return window
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
        // FIXME: This doesn't seem to work on macOS at least
        window.deletable = closable

        // TODO: Figure out if there's some magic way to disable minimization
        //   in a framework where the minimize button usually doesn't even exist

        window.resizable = resizable
    }

    public func setChild(ofWindow window: Window, to child: Widget) {
        let container = CustomRootWidget()
        container.setChild(to: child)
        window.setChild(to: container)
    }

    private func menubarHeight(ofWindow window: Window) -> Int {
        #if os(macOS)
            return 0
        #else
            if window.showMenuBar {
                // TODO: Don't hardcode this (if possible), because some Gtk
                //   themes may affect the height of the menu bar.
                25
            } else {
                0
            }
        #endif
    }

    public func size(ofWindow window: Window) -> SIMD2<Int> {
        let child = window.child! as! CustomRootWidget
        let size = child.getSize()
        return SIMD2(size.width, size.height)
    }

    public func isWindowProgrammaticallyResizable(_ window: Window) -> Bool {
        // TODO: Detect whether window is fullscreen
        return true
    }

    public func setSize(ofWindow window: Window, to newSize: SIMD2<Int>) {
        let child = window.child! as! CustomRootWidget
        child.preemptAllocatedSize(
            allocatedWidth: newSize.x,
            allocatedHeight: newSize.y
        )
        window.size = Size(
            width: newSize.x,
            height: newSize.y + menubarHeight(ofWindow: window)
        )
    }

    public func setSizeLimits(
        ofWindow window: Window,
        minimum minimumSize: SIMD2<Int>,
        maximum maximumSize: SIMD2<Int>?
    ) {
        let child = window.child! as! CustomRootWidget
        child.setMinimumSize(minimumWidth: minimumSize.x, minimumHeight: minimumSize.y)

        // NB: GTK does not support setting maximum sizes for widgets. It just doesn't.
        // https://discourse.gnome.org/t/how-to-build-fixed-size-windows-in-gtk-4/22807/10
        if maximumSize != nil {
            debugLogOnce("GTK does not support setting maximum window sizes")
        }
    }

    public func setResizeHandler(
        ofWindow window: Window,
        to action: @escaping (_ newSize: SIMD2<Int>) -> Void
    ) {
        let child = window.child! as! CustomRootWidget
        child.setResizeHandler { size in
            action(SIMD2(size.width, size.height))
        }
    }

    private func renderMenu(
        _ menu: ResolvedMenu,
        actionMap: any GActionMap,
        actionNamespace: String,
        actionPrefix: String?
    ) -> GMenu {
        var currentSection = GMenu()
        var previousSections: [GMenu] = []

        for (i, item) in menu.items.enumerated() {
            let actionName =
                if let actionPrefix {
                    "\(actionPrefix)_\(i)"
                } else {
                    "\(i)"
                }

            switch item {
                case .button(let label, let action):
                    if let action {
                        actionMap.addAction(GSimpleAction(name: actionName, action: action))
                    }

                    currentSection.appendItem(
                        label: label,
                        actionName: "\(actionNamespace).\(actionName)"
                    )
                case .toggle(let label, let value, let onChange):
                    actionMap.addAction(
                        GSimpleAction(name: actionName, state: value, action: onChange)
                    )

                    currentSection.appendItem(
                        label: label,
                        actionName: "\(actionNamespace).\(actionName)"
                    )
                case .separator:
                    // GTK[3] doesn't have explicit separators per se, but instead deals with
                    // sections (actually quite similar to what you can do in SwiftUI with the
                    // Section view). It'll automatically draw separators between sections.
                    previousSections.append(currentSection)
                    currentSection = GMenu()
                case .submenu(let submenu):
                    currentSection.appendSubmenu(
                        label: submenu.label,
                        content: renderMenu(
                            submenu.content,
                            actionMap: actionMap,
                            actionNamespace: actionNamespace,
                            actionPrefix: actionName
                        )
                    )
            }
        }

        if previousSections.isEmpty {
            // There are no dividers; just return the current section to keep the menu tree flat.
            return currentSection
        } else {
            let model = GMenu()
            for section in previousSections + [currentSection] {
                model.appendSection(label: nil, content: section)
            }
            return model
        }
    }

    private func renderMenuBar(_ submenus: [ResolvedMenu.Submenu]) -> GMenu {
        let model = GMenu()
        for (i, submenu) in submenus.enumerated() {
            model.appendSubmenu(
                label: submenu.label,
                content: renderMenu(
                    submenu.content,
                    actionMap: gtkApp,
                    actionNamespace: "app",
                    actionPrefix: "\(i)"
                )
            )
        }

        return model
    }

    public func setApplicationMenu(_ submenus: [ResolvedMenu.Submenu]) {
        let model = renderMenuBar(submenus)
        gtkApp.menuBarModel = model

        let showMenuBar = !submenus.isEmpty
        for window in windows {
            window.showMenuBar = showMenuBar
        }
    }

    public func show(window: Window) {
        window.showAll()
    }

    public func activate(window: Window) {
        window.present()
    }

    public func openExternalURL(_ url: URL) throws {
        // Used instead of gtk_uri_launcher_launch to maintain <4.10 compatibility
        var error: UnsafeMutablePointer<GError>? = nil
        gtk_show_uri(nil, url.absoluteString, guint(GDK_CURRENT_TIME), &error)

        if let error {
            throw Gtk3Error(
                code: Int(error.pointee.code),
                domain: Int(error.pointee.domain),
                message: String(cString: error.pointee.message)
            )
        }
    }

    public func revealFile(_ url: URL) throws {
        var success = false

        #if !os(Windows)
            let fileURI = url.absoluteString.replacingOccurrences(
                of: ",",
                with: "\\,"
            )
            let process = Process()
            process.arguments = [
                "dbus-send", "--print-reply",
                "--dest=org.freedesktop.FileManager1",
                "/org/freedesktop/FileManager1",
                "org.freedesktop.FileManager1.ShowItems",
                "array:string:\(fileURI)",
                "string:",
            ]
            process.executableURL = URL(fileURLWithPath: "/usr/bin/env")

            do {
                try process.run()
                process.waitUntilExit()

                success = process.terminationStatus == 0
            } catch {
                // Fall through to fallback
            }
        #endif

        if !success {
            // Fall back to opening the parent directory without highlighting
            // the file.
            try openExternalURL(url.deletingLastPathComponent())
        }
    }

    class ThreadActionContext {
        var action: @MainActor () -> Void

        init(action: @escaping @MainActor () -> Void) {
            self.action = action
        }
    }

    public func runInMainThread(action: @escaping @MainActor () -> Void) {
        let action = ThreadActionContext(action: action)
        g_idle_add_full(
            0,
            { context in
                guard let context else {
                    fatalError("Gtk action callback called without context")
                }

                MainActor.assumeIsolated {
                    let action = Unmanaged<ThreadActionContext>.fromOpaque(context)
                        .takeUnretainedValue()
                    action.action()
                }

                return 0
            },
            Unmanaged<ThreadActionContext>.passRetained(action).toOpaque(),
            { _ in }
        )
    }

    private static func runInMainThread(
        afterMilliseconds delay: Int,
        action: @escaping () -> Void
    ) {
        let action = ThreadActionContext(action: action)
        g_timeout_add_full(
            0,
            guint(max(0, delay)),
            { context in
                guard let context else {
                    fatalError("Gtk action callback called without context")
                }

                MainActor.assumeIsolated {
                    let action = Unmanaged<ThreadActionContext>.fromOpaque(context)
                        .takeUnretainedValue()
                    action.action()
                }

                // Cancel the recurring timeout after one iteration
                return 0
            },
            Unmanaged<ThreadActionContext>.passRetained(action).toOpaque(),
            { _ in }
        )
    }

    public func computeRootEnvironment(defaultEnvironment: EnvironmentValues) -> EnvironmentValues {
        defaultEnvironment
    }

    public func setRootEnvironmentChangeHandler(to action: @escaping () -> Void) {
        // TODO: React to theme changes
    }

    public func computeWindowEnvironment(
        window: Window,
        rootEnvironment: EnvironmentValues
    ) -> EnvironmentValues {
        let windowScaleFactor = Int(gtk_widget_get_scale_factor(window.widgetPointer))
        return rootEnvironment.with(\.windowScaleFactor, Double(windowScaleFactor))
    }

    public func setWindowEnvironmentChangeHandler(
        of window: Window,
        to action: @escaping () -> Void
    ) {
        window.notifyScaleFactor = { _ in
            action()
        }
    }

    public func setIncomingURLHandler(to action: @escaping (URL) -> Void) {
        gtkApp.onOpen = { urls in
            for url in urls {
                action(url)
            }
        }
    }

    public func show(widget: Widget) {
        widget.show()
    }

    public func tag(widget: Widget, as tag: String) {
        widget.tag(as: tag)
    }

    // MARK: Containers

    public func createContainer() -> Widget {
        Fixed()
    }

    public func removeAllChildren(of container: Widget) {
        let container = container as! Fixed
        container.removeAllChildren()
    }

    public func insert(_ child: Widget, into container: Widget, at index: Int) {
        let container = container as! Fixed
        container.put(child, index: index, x: 0, y: 0)
    }

    public func setPosition(ofChildAt index: Int, in container: Widget, to position: SIMD2<Int>) {
        let container = container as! Fixed
        container.move(container.children[index], x: position.x, y: position.y)
    }

    public func remove(childAt index: Int, from container: Widget) {
        let container = container as! Fixed
        let child = container.children[index]
        container.remove(child)
    }

    public func swap(childAt firstIndex: Int, withChildAt secondIndex: Int, in container: Widget) {
        // Gtk3.Fixed doesn't let us rearrange children, so we just swap them in
        // our own list so that at least everything works on the SCUI side. The
        // only side effect of this approach is that overlapping widgets may
        // end up with unexpected z ordering. If that becomes an issue we may
        // have to make a custom replacement for Gtk3.Fixed.
        let container = container as! Fixed
        container.children.swapAt(firstIndex, secondIndex)
    }

    public func createColorableRectangle() -> Widget {
        return Box()
    }

    public func setColor(
        ofColorableRectangle widget: Widget,
        to color: SwiftCrossUI.Color.Resolved
    ) {
        widget.css.set(property: .backgroundColor(color.gtkColor))
        widget.css.set(property: CSSProperty(key: "background-clip", value: "border-box"))
    }

    public func setCornerRadius(of widget: Widget, to radius: Int) {
        widget.css.set(property: .cornerRadius(radius))
    }

    public func naturalSize(of widget: Widget) -> SIMD2<Int> {
        let currentSize = widget.getSizeRequest()
        widget.setSizeRequest(width: -1, height: -1)
        let (width, height) = widget.getNaturalSize()
        widget.setSizeRequest(width: currentSize.width, height: currentSize.height)
        return SIMD2(width, height)
    }

    public func setSize(of widget: Widget, to size: SIMD2<Int>) {
        widget.setSizeRequest(width: size.x, height: size.y)
    }

    public func createSplitView(leadingChild: Widget, trailingChild: Widget) -> Widget {
        let widget = Paned(orientation: .horizontal)

        let leadingContainer = CustomRootWidget()
        leadingContainer.setChild(to: leadingChild)
        widget.startChild = leadingContainer

        let trailingContainer = CustomRootWidget()
        trailingContainer.setChild(to: trailingChild)
        widget.endChild = trailingContainer

        widget.position = 200
        return widget
    }

    public func setResizeHandler(
        ofSplitView splitView: Widget,
        to action: @escaping () -> Void
    ) {
        let splitView = splitView as! Paned
        splitView.notifyPosition = { splitView in
            action()
        }
    }

    public func sidebarWidth(ofSplitView splitView: Widget) -> Int {
        let splitView = splitView as! Paned
        return splitView.position
    }

    public func setSidebarWidthBounds(
        ofSplitView splitView: Widget,
        minimum minimumWidth: Int,
        maximum maximumWidth: Int
    ) {
        let splitView = splitView as! Paned
        show(widget: splitView.startChild!)
        let width = splitView.getNaturalSize().width
        splitView.startChild?.setSizeRequest(width: minimumWidth, height: 0)
        splitView.endChild?.setSizeRequest(width: width - maximumWidth, height: 0)
    }

    public func createScrollContainer(for child: Widget) -> Widget {
        let scrollView = ScrolledWindow()
        scrollView.add(child)
        return scrollView
    }

    public func updateScrollContainer(_ scrollView: Widget, environment: EnvironmentValues) {}

    public func setScrollBarPresence(
        ofScrollContainer scrollView: Widget,
        hasVerticalScrollBar: Bool,
        hasHorizontalScrollBar: Bool
    ) {
        let scrollView = scrollView as! ScrolledWindow
        scrollView.setScrollBarPresence(
            hasVerticalScrollBar: hasVerticalScrollBar,
            hasHorizontalScrollBar: hasHorizontalScrollBar
        )
    }

    public func createSelectableListView() -> Widget {
        let listView = ListBox()
        listView.selectionMode = .single
        return listView
    }

    public func baseItemPadding(
        ofSelectableListView listView: Widget
    ) -> SwiftCrossUI.EdgeInsets {
        SwiftCrossUI.EdgeInsets()
    }

    public func minimumRowSize(ofSelectableListView listView: Widget) -> SIMD2<Int> {
        .zero
    }

    public func setItems(
        ofSelectableListView listView: Widget,
        to items: [Widget],
        withRowHeights rowHeights: [Int]
    ) {
        let listView = listView as! ListBox
        listView.removeAll()
        for item in items {
            listView.add(item)
        }
    }

    public func setSelectionHandler(
        forSelectableListView listView: Widget,
        to action: @escaping (_ selectedIndex: Int) -> Void
    ) {
        let listView = listView as! ListBox
        listView.rowSelected = { _, selectedRow in
            guard let selectedRow else {
                return
            }
            action(Int(gtk_list_box_row_get_index(selectedRow)))
        }
    }

    public func setSelectedItem(ofSelectableListView listView: Widget, toItemAt index: Int?) {
        let listView = listView as! ListBox
        let handler = listView.rowSelected
        listView.rowSelected = nil
        if let index {
            listView.selectRow(at: index)
        } else {
            listView.unselectAll()
        }
        listView.rowSelected = handler
    }

    // MARK: Passive views

    public func createTextView() -> Widget {
        let textView = CustomLabel(string: "")
        textView.horizontalAlignment = .start
        textView.wrap = true
        textView.lineWrapMode = .wordCharacter
        textView.ellipsize = .end
        return textView
    }

    public func updateTextView(
        _ textView: Widget,
        content: String,
        environment: EnvironmentValues
    ) {
        let textView = textView as! CustomLabel
        textView.label = content
        textView.justify =
            switch environment.multilineTextAlignment {
                case .leading:
                    Justification.left
                case .center:
                    Justification.center
                case .trailing:
                    Justification.right
            }

        textView.css.clear()
        textView.css.set(properties: Self.cssProperties(for: environment))
    }

    public func size(
        of text: String,
        whenDisplayedIn widget: Widget,
        proposedWidth: Int?,
        proposedHeight: Int?,
        environment: EnvironmentValues
    ) -> SIMD2<Int> {
        let pango = Pango(for: widget)
        let (width, height) = pango.getTextSize(
            text,
            ellipsize: (widget as! CustomLabel).ellipsize,
            proposedWidth: proposedWidth.map(Double.init),
            proposedHeight: proposedHeight.map(Double.init)
        )
        return SIMD2(width, height)
    }

    public func createImageView() -> Widget {
        let imageView = Gtk3.Image()
        return imageView
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
        let imageView = imageView as! Gtk3.Image

        // Check if the resulting image would be empty
        guard targetWidth > 0, targetHeight > 0 else {
            imageView.clear()
            return
        }

        let pixbuf = Pixbuf(
            rgbaData: rgbaData,
            width: width,
            height: height
        )

        let surface = pixbuf.hidpiAwareScaled(
            toLogicalWidth: targetWidth,
            andLogicalHeight: targetHeight,
            for: imageView
        )

        imageView.setCairoSurface(surface)
        imageView.show()
    }

    // private class Tables {
    //     var tableSizes: [ObjectIdentifier: (rows: Int, columns: Int)] = [:]
    // }

    // private let tables = Tables()

    // TODO: Implement tables
    // public func createTable(rows: Int, columns: Int) -> Widget {
    //     let widget = Grid()

    //     for i in 0..<rows {
    //         widget.insertRow(position: i)
    //     }

    //     for i in 0..<columns {
    //         widget.insertRow(position: i)
    //     }

    //     tables.tableSizes[ObjectIdentifier(widget)] = (rows: rows, columns: columns)

    //     widget.columnSpacing = 10
    //     widget.rowSpacing = 10

    //     return widget
    // }

    // public func setRowCount(ofTable table: Widget, to rows: Int) {
    //     let table = table as! Grid

    //     let rowDifference = rows - tables.tableSizes[ObjectIdentifier(table)]!.rows
    //     tables.tableSizes[ObjectIdentifier(table)]!.rows = rows
    //     if rowDifference < 0 {
    //         for _ in 0..<(-rowDifference) {
    //             table.removeRow(position: 0)
    //         }
    //     } else if rowDifference > 0 {
    //         for _ in 0..<rowDifference {
    //             table.insertRow(position: 0)
    //         }
    //     }

    // }

    // public func setColumnCount(ofTable table: Widget, to columns: Int) {
    //     let table = table as! Grid

    //     let columnDifference = columns - tables.tableSizes[ObjectIdentifier(table)]!.columns
    //     tables.tableSizes[ObjectIdentifier(table)]!.columns = columns
    //     if columnDifference < 0 {
    //         for _ in 0..<(-columnDifference) {
    //             table.removeColumn(position: 0)
    //         }
    //     } else if columnDifference > 0 {
    //         for _ in 0..<columnDifference {
    //             table.insertColumn(position: 0)
    //         }
    //     }

    // }

    // public func setCell(at position: CellPosition, inTable table: Widget, to widget: Widget) {
    //     let table = table as! Grid
    //     table.attach(
    //         child: widget,
    //         left: position.column,
    //         top: position.row,
    //         width: 1,
    //         height: 1
    //     )
    // }

    // MARK: Controls

    public func createButton() -> Widget {
        return Button()
    }

    public func updateButton(
        _ button: Widget,
        label: String,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        // TODO: Update button label color using environment
        let button = button as! Gtk3.Button
        button.sensitive = environment.isEnabled
        button.label = label
        button.clicked = { _ in action() }
        button.css.clear()
        button.css.set(
            properties: Self.cssProperties(for: environment, isControl: true)
        )
    }

    public func createToggle() -> Widget {
        return ToggleButton()
    }

    public func updateToggle(
        _ toggle: Widget,
        label: String,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        let toggle = toggle as! Gtk3.ToggleButton
        toggle.label = label
        toggle.sensitive = environment.isEnabled
        toggle.toggled = { widget in
            onChange(widget.active)
        }
        toggle.css.clear()
        // This is a control, but we set isControl to false anyway because isControl overrides
        // the button background and makes the on and off states of the toggle look identical.
        toggle.css.set(properties: Self.cssProperties(for: environment, isControl: false))
    }

    public func setState(ofToggle toggle: Widget, to state: Bool) {
        (toggle as! Gtk3.ToggleButton).active = state
    }

    public func createSwitch() -> Widget {
        return Switch()
    }

    public func updateSwitch(
        _ switchWidget: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        let switchWidget = switchWidget as! Gtk3.Switch
        switchWidget.sensitive = environment.isEnabled
        switchWidget.notifyActive = { widget, _ in
            onChange(widget.active)
        }
    }

    public func setState(ofSwitch switchWidget: Widget, to state: Bool) {
        (switchWidget as! Gtk3.Switch).active = state
    }

    public func createCheckbox() -> Widget {
        return Gtk3.CheckButton()
    }

    public func updateCheckbox(
        _ checkboxWidget: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        let checkboxWidget = checkboxWidget as! Gtk3.CheckButton
        checkboxWidget.sensitive = environment.isEnabled
        checkboxWidget.notifyActive = { widget, _ in
            onChange(widget.active)
        }
    }

    public func setState(ofCheckbox checkboxWidget: Widget, to state: Bool) {
        (checkboxWidget as! Gtk3.CheckButton).active = state
    }

    public func createSlider() -> Widget {
        let scale = Scale()
        scale.expandHorizontally = true
        return scale
    }

    public func updateSlider(
        _ slider: Widget,
        minimum: Double,
        maximum: Double,
        decimalPlaces: Int,
        environment: EnvironmentValues,
        onChange: @escaping (Double) -> Void
    ) {
        let slider = slider as! Scale
        slider.sensitive = environment.isEnabled
        slider.minimum = minimum
        slider.maximum = maximum
        slider.digits = decimalPlaces
        slider.valueChanged = { widget in
            onChange(widget.value)
        }
    }

    public func setValue(ofSlider slider: Widget, to value: Double) {
        (slider as! Scale).value = value
    }

    public func createTextField() -> Widget {
        return Entry()
    }

    public func updateTextField(
        _ textField: Widget,
        placeholder: String,
        environment: EnvironmentValues,
        onChange: @escaping (String) -> Void,
        onSubmit: @escaping () -> Void
    ) {
        let textField = textField as! Entry
        textField.sensitive = environment.isEnabled
        textField.placeholderText = placeholder
        textField.changed = { widget in
            onChange(widget.text)
        }
        textField.activate = { _ in
            onSubmit()
        }

        textField.css.clear()
        textField.css.set(properties: Self.cssProperties(for: environment, isControl: true))
    }

    public func setContent(ofTextField textField: Widget, to content: String) {
        (textField as! Entry).text = content
    }

    public func getContent(ofTextField textField: Widget) -> String {
        return (textField as! Entry).text
    }

    public func createTextEditor() -> Widget {
        let textEditor = Gtk3.TextView()
        textEditor.wrapMode = .wordCharacter
        return textEditor
    }

    public func updateTextEditor(
        _ textEditor: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (String) -> Void
    ) {
        let textEditor = textEditor as! Gtk3.TextView
        textEditor.buffer.changed = { buffer in
            onChange(buffer.text)
        }

        textEditor.css.clear()
        textEditor.css.set(properties: Self.cssProperties(for: environment, isControl: false))
        textEditor.css.set(property: CSSProperty(key: "background", value: "none"))
    }

    public func setContent(ofTextEditor textEditor: Widget, to content: String) {
        let textEditor = textEditor as! Gtk3.TextView
        textEditor.buffer.text = content
    }

    public func getContent(ofTextEditor textEditor: Widget) -> String {
        let textEditor = textEditor as! Gtk3.TextView
        return textEditor.buffer.text
    }

    // public func createPicker() -> Widget {
    //     return DropDown(strings: [])
    // }

    // public func updatePicker(
    //     _ picker: Widget,
    //     options: [String],
    //     environment: EnvironmentValues,
    //     onChange: @escaping (Int?) -> Void
    // ) {
    //     let picker = picker as! DropDown
    //     picker.sensitive = environment.isEnabled

    //     // Check whether the options need to be updated or not (avoiding unnecessary updates is
    //     // required to prevent an infinite loop caused by the onChange handler)
    //     var hasChanged = false
    //     for index in 0..<options.count {
    //         guard
    //             let item = gtk_string_list_get_string(picker.model, guint(index)),
    //             String(cString: item) == options[index]
    //         else {
    //             hasChanged = true
    //             break
    //         }
    //     }

    //     // picker.model could be longer than options
    //     if gtk_string_list_get_string(picker.model, guint(options.count)) != nil {
    //         hasChanged = true
    //     }

    //     // Apply the current text styles to the dropdown's labels
    //     var block = CSSBlock(forClass: picker.css.cssClass + " label")
    //     block.set(properties: Self.cssProperties(for: environment))
    //     picker.cssProvider.loadCss(from: block.stringRepresentation)

    //     guard hasChanged else {
    //         return
    //     }

    //     picker.model = gtk_string_list_new(
    //         UnsafePointer(
    //             options
    //                 .map({ UnsafePointer($0.unsafeUTF8Copy().baseAddress) })
    //                 .unsafeCopy()
    //                 .baseAddress
    //         )
    //     )

    //     picker.notifySelected = { picker in
    //         if picker.selected == GTK_INVALID_LIST_POSITION {
    //             onChange(nil)
    //         } else {
    //             onChange(picker.selected)
    //         }
    //     }
    // }

    // public func setSelectedOption(ofPicker picker: Widget, to selectedOption: Int?) {
    //     let picker = picker as! DropDown
    //     if selectedOption != picker.selected {
    //         picker.selected = selectedOption ?? Int(GTK_INVALID_LIST_POSITION)
    //     }
    // }

    public func createProgressSpinner() -> Widget {
        let spinner = Spinner()
        spinner.start()
        return spinner
    }

    public func createProgressBar() -> Widget {
        ProgressBar()
    }

    public func updateProgressBar(
        _ widget: Widget,
        progressFraction: Double?,
        environment: EnvironmentValues
    ) {
        let progressBar = widget as! ProgressBar
        progressBar.fraction = progressFraction ?? 0
    }

    public func createPopoverMenu() -> Menu {
        Gtk3.Menu()
    }

    public func updatePopoverMenu(
        _ menu: Menu,
        content: ResolvedMenu,
        environment: EnvironmentValues
    ) {
        // Update menu model and action handlers
        let actionGroup = Gtk3.GSimpleActionGroup()
        let model = renderMenu(
            content,
            actionMap: actionGroup,
            actionNamespace: "menu",
            actionPrefix: nil
        )
        menu.bindModel(model)
        menu.insertActionGroup("menu", actionGroup)

        // menu.cssProvider.loadCss(
        //     from: """
        //         menu {
        //             background: rgba(45, 45, 45, 1);
        //             color: white;
        //         }
        //         menuitem:hover {
        //             background: magenta;
        //             color: white;
        //         }
        //         """)
    }

    public func showPopoverMenu(
        _ menu: Menu,
        at position: SIMD2<Int>,
        relativeTo widget: Widget,
        closeHandler handleClose: @escaping () -> Void
    ) {
        menu.popUpAtWidget(widget, relativePosition: position)
        menu.onHide = {
            handleClose()
        }
    }

    public func createAlert() -> Alert {
        let dialog = Gtk3.MessageDialog()

        // The Ubuntu Gtk3 theme seems to only set the bottom corner radii.
        dialog.css.set(properties: [
            .cornerRadius(13)
        ])

        return dialog
    }

    public func updateAlert(
        _ alert: Alert,
        title: String,
        actionLabels: [String],
        environment: EnvironmentValues
    ) {
        alert.text = title
        for (i, label) in actionLabels.enumerated() {
            alert.addButton(label: label, responseId: i)
        }
    }

    public func showAlert(
        _ alert: Alert,
        window: Window?,
        responseHandler handleResponse: @escaping (Int) -> Void
    ) {
        alert.response = { _, responseId in
            guard responseId != Int(UInt32(bitPattern: -4)) else {
                // Ignore escape key for now. Once we support detecting
                // the primary and secondary actions of alerts we can wire
                // this up to whichever action is the default cancellation
                // action.
                return
            }

            alert.destroy()
            handleResponse(responseId)
        }
        alert.isModal = true
        alert.isDecorated = false
        alert.setTransient(for: window ?? windows[0])
        alert.show()
    }

    public func dismissAlert(_ alert: Alert, window: Window?) {
        alert.destroy()
    }

    public func showOpenDialog(
        fileDialogOptions: FileDialogOptions,
        openDialogOptions: OpenDialogOptions,
        window: Window?,
        resultHandler handleResult: @escaping (DialogResult<[URL]>) -> Void
    ) {
        showFileChooserDialog(
            fileDialogOptions: fileDialogOptions,
            action: .open,
            configure: { chooser in
                chooser.selectMultiple = openDialogOptions.allowMultipleSelections
            },
            window: window,
            resultHandler: handleResult
        )
    }

    public func showSaveDialog(
        fileDialogOptions: FileDialogOptions,
        saveDialogOptions: SaveDialogOptions,
        window: Window?,
        resultHandler handleResult: @escaping (DialogResult<URL>) -> Void
    ) {
        showFileChooserDialog(
            fileDialogOptions: fileDialogOptions,
            action: .save,
            configure: { chooser in
                if let defaultFileName = saveDialogOptions.defaultFileName {
                    chooser.setCurrentName(defaultFileName)
                }
            },
            window: window
        ) { result in
            switch result {
                case .success(let urls):
                    handleResult(.success(urls[0]))
                case .cancelled:
                    handleResult(.cancelled)
            }
        }

    }

    private func showFileChooserDialog(
        fileDialogOptions: FileDialogOptions,
        action: FileChooserAction,
        configure: (Gtk3.FileChooserNative) -> Void,
        window: Window?,
        resultHandler handleResult: @escaping (DialogResult<[URL]>) -> Void
    ) {
        let chooser = Gtk3.FileChooserNative(
            title: fileDialogOptions.title,
            parent: window?.widgetPointer.cast(),
            action: action.toGtk(),
            acceptLabel: fileDialogOptions.defaultButtonLabel,
            cancelLabel: "Cancel"
        )

        if let initialDirectory = fileDialogOptions.initialDirectory {
            chooser.setCurrentFolder(initialDirectory)
        }

        configure(chooser)

        chooser.registerSignals()
        chooser.response = { (_: NativeDialog, response: Int) -> Void in
            // Release our intentional retain cycle which ironically only exists
            // because of this line. The retain cycle keeps the file chooser
            // around long enough for the user to respond (it gets released
            // immediately if we don't do this in the response signal handler).
            chooser.response = nil

            let response = Int32(bitPattern: UInt32(UInt(response)))
            if response == Int(ResponseType.accept.toGtk().rawValue) {
                let files = chooser.getFiles()
                var urls: [URL] = []
                for i in 0..<files.count {
                    let url = URL(
                        fileURLWithPath: GFile(files[i]).path
                    )
                    urls.append(url)
                }
                handleResult(.success(urls))
            } else {
                handleResult(.cancelled)
            }
        }
        gtk_native_dialog_show(chooser.gobjectPointer.cast())
    }

    public func createTapGestureTarget(wrapping child: Widget, gesture: TapGesture) -> Widget {
        if gesture != .primary {
            fatalError("Unsupported gesture type \(gesture)")
        }
        let eventBox = Gtk3.EventBox()
        eventBox.setChild(to: child)
        eventBox.aboveChild = true
        return eventBox
    }

    public func updateTapGestureTarget(
        _ tapGestureTarget: Widget,
        gesture: TapGesture,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        if gesture != .primary {
            fatalError("Unsupported gesture type \(gesture)")
        }
        tapGestureTarget.onButtonPress = { _, buttonEvent in
            let eventType = buttonEvent.type
            guard
                environment.isEnabled,
                eventType == GDK_BUTTON_PRESS
                    || eventType == GDK_2BUTTON_PRESS
                    || eventType == GDK_3BUTTON_PRESS
            else {
                return
            }
            action()
        }
    }

    public func createPathWidget() -> Widget {
        Gtk3.DrawingArea()
    }

    public func createPath() -> Path {
        Path()
    }

    public func updatePath(
        _ path: Path,
        _ source: SwiftCrossUI.Path,
        bounds: SwiftCrossUI.Path.Rect,
        pointsChanged: Bool,
        environment: EnvironmentValues
    ) {
        path.path = source
        path.scaleFactor = environment.windowScaleFactor
    }

    /// Assumes that the path backing widget has already been given the correct
    /// size.
    public func renderPath(
        _ path: Path,
        container: Widget,
        strokeColor: SwiftCrossUI.Color.Resolved,
        fillColor: SwiftCrossUI.Color.Resolved,
        overrideStrokeStyle: StrokeStyle?
    ) {
        let drawingArea = container as! Gtk3.DrawingArea

        // We don't actually care about leaking backends, but might as well use
        // a weak reference anyway.
        drawingArea.doDraw = { [weak self] cairo in
            let scaleFactor = path.scaleFactor
            guard let self, let path = path.path else {
                return
            }

            let fillRule: cairo_fill_rule_t
            switch path.fillRule {
                case .evenOdd:
                    fillRule = CAIRO_FILL_RULE_EVEN_ODD
                case .winding:
                    fillRule = CAIRO_FILL_RULE_WINDING
            }
            cairo_set_fill_rule(cairo, fillRule)

            let strokeStyle = overrideStrokeStyle ?? path.strokeStyle
            let strokeCap: cairo_line_cap_t
            switch strokeStyle.cap {
                case .butt:
                    strokeCap = CAIRO_LINE_CAP_BUTT
                case .round:
                    strokeCap = CAIRO_LINE_CAP_ROUND
                case .square:
                    strokeCap = CAIRO_LINE_CAP_SQUARE
            }
            cairo_set_line_cap(cairo, strokeCap)

            let strokeJoin: cairo_line_join_t
            switch strokeStyle.join {
                case .bevel:
                    strokeJoin = CAIRO_LINE_JOIN_BEVEL
                case .miter(let limit):
                    strokeJoin = CAIRO_LINE_JOIN_MITER
                    cairo_set_miter_limit(cairo, limit)
                case .round:
                    strokeJoin = CAIRO_LINE_JOIN_ROUND
            }
            cairo_set_line_join(cairo, strokeJoin)

            cairo_set_line_width(cairo, strokeStyle.width)

            self.renderPathActions(path.actions, to: cairo)

            let fillPattern = cairo_pattern_create_rgba(
                Double(fillColor.red),
                Double(fillColor.green),
                Double(fillColor.blue),
                Double(fillColor.opacity)
            )
            cairo_set_source(cairo, fillPattern)
            cairo_fill_preserve(cairo)
            cairo_pattern_destroy(fillPattern)

            let strokePattern = cairo_pattern_create_rgba(
                Double(strokeColor.red),
                Double(strokeColor.green),
                Double(strokeColor.blue),
                Double(strokeColor.opacity)
            )
            cairo_set_source(cairo, strokePattern)
            cairo_stroke(cairo)
            cairo_pattern_destroy(strokePattern)
        }

        drawingArea.queueDraw()
    }

    private func renderPathActions(
        _ actions: [SwiftCrossUI.Path.Action],
        to cairo: OpaquePointer
    ) {
        for action in actions {
            switch action {
                case .transform(let transform):
                    var matrix = cairo_matrix_t()
                    matrix.xx = transform.linearTransform.x
                    matrix.xy = transform.linearTransform.y
                    matrix.yx = transform.linearTransform.z
                    matrix.yy = transform.linearTransform.w
                    matrix.x0 = transform.translation.x
                    matrix.y0 = transform.translation.y
                    cairo_transform(cairo, &matrix)
                default:
                    break
            }
        }

        for (index, action) in actions.enumerated() {
            switch action {
                case .moveTo(let point):
                    cairo_move_to(cairo, point.x, point.y)
                case .lineTo(let point):
                    if index == 0 {
                        cairo_move_to(cairo, 0, 0)
                    }
                    cairo_line_to(cairo, point.x, point.y)
                case .quadCurve(let control, let end):
                    if index == 0 {
                        cairo_move_to(cairo, 0, 0)
                    }
                    var startX = 0.0
                    var startY = 0.0
                    cairo_get_current_point(cairo, &startX, &startY)
                    let start = SIMD2(startX, startY)
                    let control1 = (start + 2 * control) / 3
                    let control2 = (end + 2 * control) / 3
                    cairo_curve_to(
                        cairo,
                        control1.x, control1.y,
                        control2.x, control2.y,
                        end.x, end.y
                    )
                case .cubicCurve(let control1, let control2, let end):
                    if index == 0 {
                        cairo_move_to(cairo, 0, 0)
                    }
                    cairo_curve_to(
                        cairo,
                        control1.x, control1.y,
                        control2.x, control2.y,
                        end.x, end.y
                    )
                case .rectangle(let rect):
                    cairo_rectangle(
                        cairo,
                        rect.origin.x, rect.origin.y,
                        rect.size.x, rect.size.y
                    )
                case .circle(let center, let radius):
                    cairo_arc(cairo, center.x, center.y, radius, 0, 2 * .pi)
                case .arc(
                    let center,
                    let radius,
                    let startAngle,
                    let endAngle,
                    let clockwise
                ):
                    let arcFunc = clockwise ? cairo_arc : cairo_arc_negative
                    arcFunc(
                        cairo,
                        center.x,
                        center.y,
                        radius,
                        startAngle,
                        endAngle
                    )
                case .transform(let transform):
                    var matrix = cairo_matrix_t()
                    matrix.xx = transform.linearTransform.x
                    matrix.xy = transform.linearTransform.y
                    matrix.yx = transform.linearTransform.z
                    matrix.yy = transform.linearTransform.w
                    matrix.x0 = transform.translation.x
                    matrix.y0 = transform.translation.y
                    cairo_matrix_invert(&matrix)
                    cairo_transform(cairo, &matrix)
                case .subpath(let subpathActions):
                    renderPathActions(subpathActions, to: cairo)
            }
        }
    }
    // MARK: Helpers

    private static func cssProperties(
        for environment: EnvironmentValues,
        isControl: Bool = false
    ) -> [CSSProperty] {
        var properties: [CSSProperty] = []
        properties.append(
            .foregroundColor(
                environment.suggestedForegroundColor.resolve(in: environment).gtkColor
            )
        )
        let font = environment.resolvedFont
        switch font.identifier.kind {
            case .system:
                properties.append(.fontSize(font.pointSize))
                let weightNumber =
                    switch font.weight {
                        case .ultraLight:
                            100
                        case .thin:
                            200
                        case .light:
                            300
                        case .regular:
                            400
                        case .medium:
                            500
                        case .semibold:
                            600
                        case .bold:
                            700
                        case .heavy:
                            800
                        case .black:
                            900
                    }
                properties.append(.fontWeight(weightNumber))
                switch font.design {
                    case .monospaced:
                        properties.append(.fontFamily("monospace"))
                    case .default:
                        break
                }
        }

        if font.isItalic {
            properties.append(.fontStyle("italic"))
        }

        if isControl {
            switch environment.colorScheme {
                case .light:
                    properties.append(.border(color: Color.eightBit(209, 209, 209), width: 1))
                    properties.append(.backgroundColor(Color(1, 1, 1, 1)))
                    properties.append(.caretColor(Color.eightBit(139, 142, 143)))
                case .dark:
                    properties.append(.border(color: Color.eightBit(32, 32, 32), width: 1))
                    properties.append(.backgroundColor(Color(1, 1, 1, 0.1)))
                    properties.append(.caretColor(Color(1, 1, 1)))
            }
            properties.append(.init(key: "box-shadow", value: "none"))
        }

        return properties
    }
}

extension UnsafeMutablePointer {
    func cast<T>() -> UnsafeMutablePointer<T> {
        let pointer = UnsafeRawPointer(self).bindMemory(to: T.self, capacity: 1)
        return UnsafeMutablePointer<T>(mutating: pointer)
    }
}

struct Gtk3Error: LocalizedError {
    var code: Int
    var domain: Int
    var message: String

    var errorDescription: String? {
        "gerror: code=\(code), domain=\(domain), message=\(message)"
    }
}

/// A custom label subclass that supports ellipsizing multi-line text. Regular
/// `Label`s only display a single line of text when ellipsizing is enabled
/// because they don't pass their size request to their underlying Pango layout.
class CustomLabel: Label {
    override func didMoveToParent() {
        super.didMoveToParent()

        doDraw = { [weak self] _ in
            guard let self else { return }
            self.setLayoutHeight(getSizeRequest().height)
        }
    }

    private func setLayoutHeight(_ height: Int) {
        // Override the label's layout height. We do this so that the label grows
        // vertically to fill available space even though we have ellipsizing
        // enabled (which generally causes labels to limit themselves to a single line).
        //
        // This code relies on the assumption that the layout won't get recreated
        // during rendering. From reading the Gtk 3 source code I believe that's
        // unlikely, but note that the docs recommend against mutating
        // the layout returned by gtk_label_get_layout.
        let layout = gtk_label_get_layout(castedPointer())
        pango_layout_set_height(
            layout,
            Int32((Double(height) * Double(PANGO_SCALE)).rounded(.towardZero))
        )
    }
}
