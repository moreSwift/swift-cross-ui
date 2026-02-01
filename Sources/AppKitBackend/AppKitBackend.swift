import AppKit
import SwiftCrossUI
import WebKit

extension App {
    public typealias Backend = AppKitBackend

    public var backend: AppKitBackend {
        AppKitBackend()
    }
}

public final class AppKitBackend: AppBackend {
    public typealias Window = NSCustomWindow
    public typealias Widget = NSView
    public typealias Menu = NSMenu
    public typealias Alert = NSAlert
    public typealias Path = NSBezierPath
    public typealias Sheet = NSCustomSheet

    public let defaultTableRowContentHeight = 20
    public let defaultTableCellVerticalPadding = 4
    public let defaultPaddingAmount = 10
    public let requiresToggleSwitchSpacer = false
    public let requiresImageUpdateOnScaleFactorChange = false
    public let menuImplementationStyle = MenuImplementationStyle.dynamicPopover
    public let canRevealFiles = true
    public let deviceClass = DeviceClass.desktop
    public let supportedDatePickerStyles: [DatePickerStyle] = [.automatic, .graphical, .compact]

    public var scrollBarWidth: Int {
        // We assume that all scrollers have their controlSize set to `.regular` by default.
        // The internet seems to indicate that this is true regardless of any system wide
        // preferences etc.
        return Int(
            NSScroller.scrollerWidth(
                for: .regular,
                scrollerStyle: NSScroller.preferredScrollerStyle
            ).rounded(.awayFromZero)
        )
    }

    private let appDelegate = NSCustomApplicationDelegate()

    public init() {
        NSApplication.shared.delegate = appDelegate
    }

    public func runMainLoop(_ callback: @escaping @MainActor () -> Void) {
        callback()
        NSApplication.shared.activate(ignoringOtherApps: true)
        NSApplication.shared.run()
    }

    public func createWindow(withDefaultSize defaultSize: SIMD2<Int>?) -> Window {
        let nsApp = NSApplication.shared
        nsApp.setActivationPolicy(.regular)

        let window = NSCustomWindow(
            contentRect: NSRect(
                x: 0,
                y: 0,
                width: CGFloat(defaultSize?.x ?? 0),
                height: CGFloat(defaultSize?.y ?? 0)
            ),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: true
        )
        window.delegate = window.customDelegate

        return window
    }

    public func size(ofWindow window: Window) -> SIMD2<Int> {
        let contentRect = window.contentRect(forFrameRect: window.frame)
        return SIMD2(
            Int(contentRect.width.rounded(.towardZero)),
            Int(contentRect.height.rounded(.towardZero))
        )
    }

    public func isWindowProgrammaticallyResizable(_ window: Window) -> Bool {
        !window.styleMask.contains(.fullScreen)
    }

    public func setSize(ofWindow window: Window, to newSize: SIMD2<Int>) {
        window.setContentSize(NSSize(width: newSize.x, height: newSize.y))
    }

    public func setSizeLimits(
        ofWindow window: Window,
        minimum minimumSize: SIMD2<Int>,
        maximum maximumSize: SIMD2<Int>?
    ) {
        window.contentMinSize = CGSize(width: minimumSize.x, height: minimumSize.y)
        window.contentMaxSize =
            if let maximumSize {
                CGSize(width: maximumSize.x, height: maximumSize.y)
            } else {
                CGSize(width: Double.infinity, height: .infinity)
            }
    }

    public func setResizeHandler(
        ofWindow window: Window,
        to action: @escaping (SIMD2<Int>) -> Void
    ) {
        window.customDelegate.setHandler(action)
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
        if closable {
            window.styleMask.insert(.closable)
        } else {
            window.styleMask.remove(.closable)
        }

        if minimizable {
            window.styleMask.insert(.miniaturizable)
        } else {
            window.styleMask.remove(.miniaturizable)
        }

        if resizable {
            window.styleMask.insert(.resizable)
        } else {
            window.styleMask.remove(.resizable)
        }
    }

    public func setChild(ofWindow window: Window, to child: Widget) {
        window.contentView = child
    }

    public func show(window: Window) {
        window.makeKeyAndOrderFront(nil)
    }

    public func activate(window: Window) {
        window.makeKeyAndOrderFront(nil)
    }

    public func openExternalURL(_ url: URL) throws {
        NSWorkspace.shared.open(url)
    }

    public func revealFile(_ url: URL) throws {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    private static func renderMenuItems(_ items: [ResolvedMenu.Item]) -> [NSMenuItem] {
        items.map { item in
            switch item {
                case .button(let label, let action):
                    // Custom subclass is used to keep strong reference to action
                    // wrapper.
                    let renderedItem = NSCustomMenuItem(
                        title: label,
                        action: nil,
                        keyEquivalent: ""
                    )
                    if let action {
                        let wrappedAction = Action(action)
                        renderedItem.actionWrapper = wrappedAction
                        renderedItem.action = #selector(wrappedAction.run)
                        renderedItem.target = wrappedAction
                    }
                    return renderedItem
                case .toggle(let label, let value, let onChange):
                    // Custom subclass is used to keep strong reference to action
                    // wrapper.
                    let renderedItem = NSCustomMenuItem(
                        title: label,
                        action: nil,
                        keyEquivalent: ""
                    )
                    renderedItem.isOn = value

                    let wrappedAction = Action {
                        onChange(!renderedItem.isOn)
                    }
                    renderedItem.actionWrapper = wrappedAction
                    renderedItem.action = #selector(wrappedAction.run)
                    renderedItem.target = wrappedAction

                    return renderedItem
                case .separator:
                    return NSCustomMenuItem.separator()
                case .submenu(let submenu):
                    return renderSubmenu(submenu)
            }
        }
    }

    private static func renderSubmenu(_ submenu: ResolvedMenu.Submenu) -> NSMenuItem {
        let renderedMenu = NSMenu()
        for item in renderMenuItems(submenu.content.items) {
            renderedMenu.addItem(item)
        }

        let menuItem = NSMenuItem()
        menuItem.title = submenu.label
        menuItem.submenu = renderedMenu
        return menuItem
    }

    /// The submenu pointed to by `helpMenu` still appears in `menuBar`. It's
    /// whichever submenu has the name 'Help'.
    private static func renderMenuBar(
        _ submenus: [ResolvedMenu.Submenu]
    ) -> (menuBar: NSMenu, helpMenu: NSMenu?) {
        let menuBar = NSMenu()

        // The first menu item is special and always takes on the name of the app.
        let about = NSMenuItem()
        about.submenu = createDefaultAboutMenu()
        menuBar.addItem(about)
        let edit = NSMenuItem()
        edit.submenu = createDefaultEditMenu()
        menuBar.addItem(edit)

        var helpMenu: NSMenu?
        for submenu in submenus {
            let renderedSubmenu = renderSubmenu(submenu)
            menuBar.addItem(renderedSubmenu)

            if submenu.label == "Help" {
                helpMenu = renderedSubmenu.submenu
            }
        }

        return (menuBar, helpMenu)
    }

    public static func createDefaultAboutMenu() -> NSMenu {
        let appName = ProcessInfo.processInfo.processName
        let appMenu = NSMenu(title: appName)
        appMenu.addItem(
            withTitle: "About \(appName)",
            action: #selector(NSApp.orderFrontStandardAboutPanel(_:)),
            keyEquivalent: ""
        )
        appMenu.addItem(NSMenuItem.separator())

        let hideMenu = appMenu.addItem(
            withTitle: "Hide \(appName)",
            action: #selector(NSApp.hide(_:)),
            keyEquivalent: "h"
        )
        hideMenu.keyEquivalentModifierMask = .command

        let hideOthers = appMenu.addItem(
            withTitle: "Hide Others",
            action: #selector(NSApp.hideOtherApplications(_:)),
            keyEquivalent: "h"
        )
        hideOthers.keyEquivalentModifierMask = [.option, .command]

        appMenu.addItem(
            withTitle: "Show All",
            action: #selector(NSApp.unhideAllApplications(_:)),
            keyEquivalent: ""
        )

        let quitMenu = appMenu.addItem(
            withTitle: "Quit \(appName)",
            action: #selector(NSApp.terminate(_:)),
            keyEquivalent: "q"
        )
        quitMenu.keyEquivalentModifierMask = .command

        return appMenu
    }

    /// A vessel for empty methods that we use to construct selectors. We only
    /// do it this way, because Swift complains if we provide method selectors
    /// such as `undo:` and `redo:` as strings (even though they don't come
    /// from any particular class as far as I can tell).
    ///
    /// I've failed to find which class (if any) these methods are supposed to
    /// come from, and the following Apple documentation article makes it sound
    /// like undo and redo are just stringly-typed objc messages:
    /// https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/UndoArchitecture/Articles/AppKitUndo.html
    class FirstResponder {
        /// I'm not sure exactly what type this first argument is meant to have,
        /// but I believe that it actually doesn't matter, because the number
        /// of parameters (and their corresponding labels) are what actually matter.
        @objc func undo(_ sender: NSObject) {}
        @objc func redo(_ sender: NSObject) {}
    }

    public static func createDefaultEditMenu() -> NSMenu {
        // You may notice that multiple different base types are used in the
        // action selectors of the various menu items. This is because the
        // selectors get sent to the app's first responder at the time of
        // the command getting sent. If the first responder doesn't have a
        // method matching the selector, then AppKit automatically disables
        // the corresponding menu item.

        let editMenu = NSMenu(title: "Edit")
        let undoItem = editMenu.addItem(
            withTitle: "Undo",
            action: #selector(FirstResponder.undo(_:)),
            keyEquivalent: "z"
        )
        undoItem.keyEquivalentModifierMask = .command

        let redoItem = editMenu.addItem(
            withTitle: "Redo",
            action: #selector(FirstResponder.redo(_:)),
            keyEquivalent: "z"
        )
        redoItem.keyEquivalentModifierMask = [.command, .shift]

        editMenu.addItem(NSMenuItem.separator())

        let cutItem = editMenu.addItem(
            withTitle: "Cut",
            action: #selector(NSTextView.cut),
            keyEquivalent: "x"
        )
        cutItem.keyEquivalentModifierMask = .command

        let copyItem = editMenu.addItem(
            withTitle: "Copy",
            action: #selector(NSTextView.copy),
            keyEquivalent: "c"
        )
        copyItem.keyEquivalentModifierMask = .command

        let pasteItem = editMenu.addItem(
            withTitle: "Paste",
            action: #selector(NSTextView.paste),
            keyEquivalent: "v"
        )
        pasteItem.keyEquivalentModifierMask = .command

        let selectAllItem = editMenu.addItem(
            withTitle: "Select all",
            action: #selector(NSTextView.selectAll),
            keyEquivalent: "a"
        )
        selectAllItem.keyEquivalentModifierMask = .command

        return editMenu
    }

    public func setApplicationMenu(_ submenus: [ResolvedMenu.Submenu]) {
        let (menuBar, helpMenu) = Self.renderMenuBar(submenus)
        NSApplication.shared.mainMenu = menuBar

        // We point the app's `helpMenu` at whichever submenu is named 'Help'
        // (if any) so that AppKit can install its help menu search function.
        NSApplication.shared.helpMenu = helpMenu
    }

    public func runInMainThread(action: @escaping @MainActor () -> Void) {
        DispatchQueue.main.async {
            action()
        }
    }

    public func computeRootEnvironment(defaultEnvironment: EnvironmentValues) -> EnvironmentValues {
        let isDark = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
        return
            defaultEnvironment
            .with(\.colorScheme, isDark ? .dark : .light)
    }

    public func setRootEnvironmentChangeHandler(to action: @escaping () -> Void) {
        DistributedNotificationCenter.default.addObserver(
            forName: .AppleInterfaceThemeChangedNotification,
            object: nil,
            queue: OperationQueue.main
        ) { notification in
            action()
        }

        // This doesn't strictly affect the root environment, but it does require us
        // to re-compute the app's layout, and this is how backends should trigger top
        // level updates.
        DistributedNotificationCenter.default.addObserver(
            forName: NSScroller.preferredScrollerStyleDidChangeNotification,
            object: nil,
            queue: OperationQueue.main
        ) { notification in
            // Self.scrollBarWidth has changed
            action()
        }

        NotificationCenter.default.addObserver(
            forName: .NSSystemTimeZoneDidChange,
            object: nil,
            queue: .main
        ) { _ in
            action()
        }
    }

    public func computeWindowEnvironment(
        window: Window,
        rootEnvironment: EnvironmentValues
    ) -> EnvironmentValues {
        window.lastBackingScaleFactor = window.backingScaleFactor

        return rootEnvironment.with(\.windowScaleFactor, window.backingScaleFactor)
    }

    public func setWindowEnvironmentChangeHandler(
        of window: Window,
        to action: @escaping () -> Void
    ) {
        // For updating window scale factor
        NotificationCenter.default.addObserver(
            forName: NSWindow.didChangeBackingPropertiesNotification,
            object: window,
            queue: .main
        ) { notification in
            let backingScaleFactorChanged = window.lastBackingScaleFactor != window.backingScaleFactor
			
            if backingScaleFactorChanged {
                action()
            }
        }
    }

    public func setIncomingURLHandler(to action: @escaping (URL) -> Void) {
        appDelegate.onOpenURLs = { urls in
            for url in urls {
                action(url)
            }
        }
    }

    public func show(widget: Widget) {}

    public func createContainer() -> Widget {
        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }

    public func removeAllChildren(of container: Widget) {
        container.subviews = []
    }

    public func insert(_ child: Widget, into container: Widget, at index: Int) {
        container.subviews.insert(child, at: index)
        child.translatesAutoresizingMaskIntoConstraints = false
    }

    public func swap(childAt firstIndex: Int, withChildAt secondIndex: Int, in container: NSView) {
        assert(
            container.subviews.indices.contains(firstIndex)
            && container.subviews.indices.contains(secondIndex),
            """
            attempted to swap container child out of bounds; container count \
            = \(container.subviews.count); firstIndex = \(firstIndex); \
            secondIndex = \(secondIndex)
            """
        )

        container.subviews.swapAt(firstIndex, secondIndex)
    }

    public func setPosition(ofChildAt index: Int, in container: Widget, to position: SIMD2<Int>) {
        assert(
            container.subviews.indices.contains(index),
            """
            attempted to set position of non-existent container child; container \
            count = \(container.subviews.count); index = \(index); position = \
            \(position)
            """
        )

        let child = container.subviews[index]

        var foundConstraint = false
        for constraint in container.constraints {
            if constraint.firstAnchor === child.leftAnchor
                && constraint.secondAnchor === container.leftAnchor
            {
                constraint.constant = CGFloat(position.x)
                foundConstraint = true
                break
            }
        }

        if !foundConstraint {
            let constraint = child.leftAnchor.constraint(
                equalTo: container.leftAnchor, constant: CGFloat(position.x)
            )
            constraint.isActive = true
        }

        foundConstraint = false
        for constraint in container.constraints {
            if constraint.firstAnchor === child.topAnchor
                && constraint.secondAnchor === container.topAnchor
            {
                constraint.constant = CGFloat(position.y)
                foundConstraint = true
                break
            }
        }

        if !foundConstraint {
            child.topAnchor.constraint(
                equalTo: container.topAnchor,
                constant: CGFloat(position.y)
            ).isActive = true
        }
    }

    public func remove(childAt index: Int, from container: Widget) {
        container.subviews.remove(at: index)
    }

    public func createColorableRectangle() -> Widget {
        let widget = NSView()
        widget.wantsLayer = true
        return widget
    }

    public func setColor(ofColorableRectangle widget: Widget, to color: Color.Resolved) {
        widget.layer?.backgroundColor = color.nsColor.cgColor
    }

    public func setCornerRadius(of widget: Widget, to radius: Int) {
        widget.clipsToBounds = true
        widget.wantsLayer = true
        widget.layer?.cornerRadius = CGFloat(radius)
    }

    public func naturalSize(of widget: Widget) -> SIMD2<Int> {
        if let spinner = widget.subviews.first as? NSProgressIndicator,
            spinner.style == .spinning
        {
            let size = spinner.intrinsicContentSize
            return SIMD2(
                Int(size.width),
                Int(size.height)
            )
        }
        let size = widget.intrinsicContentSize
        return SIMD2(
            Int(size.width),
            Int(size.height)
        )
    }

    public func setSize(of widget: Widget, to size: SIMD2<Int>) {
        setSize(of: widget, to: ProposedViewSize(ViewSize(Double(size.x), Double(size.y))))
    }

    func setSize(of widget: Widget, to proposedSize: ProposedViewSize) {
        var foundConstraint = false
        for constraint in widget.constraints {
            if constraint.firstAnchor === widget.widthAnchor {
                if let proposedWidth = proposedSize.width {
                    constraint.constant = CGFloat(proposedWidth)
                    constraint.isActive = true
                } else {
                    constraint.isActive = false
                }
                foundConstraint = true
                break
            }
        }

        if !foundConstraint, let proposedWidth = proposedSize.width {
            widget.widthAnchor.constraint(equalToConstant: proposedWidth).isActive = true
        }

        foundConstraint = false
        for constraint in widget.constraints {
            if constraint.firstAnchor === widget.heightAnchor {
                if let proposedHeight = proposedSize.height {
                    constraint.constant = CGFloat(proposedHeight)
                    constraint.isActive = true
                } else {
                    constraint.isActive = false
                }
                foundConstraint = true
                break
            }
        }

        if !foundConstraint, let proposedHeight = proposedSize.height {
            widget.heightAnchor.constraint(equalToConstant: proposedHeight).isActive = true
        }
    }

    public func size(
        of text: String,
        whenDisplayedIn widget: Widget,
        proposedWidth: Int?,
        proposedHeight: Int?,
        environment: EnvironmentValues
    ) -> SIMD2<Int> {
        let proposedSize = NSSize(
            width: proposedWidth.map(Double.init) ?? .greatestFiniteMagnitude,
            height: proposedHeight.map(Double.init) ?? .greatestFiniteMagnitude
        )
        let rect = NSString(string: text).boundingRect(
            with: proposedSize,
            options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine],
            attributes: Self.attributes(forTextIn: environment)
        )
        return SIMD2(
            Int(rect.size.width.rounded(.awayFromZero)),
            Int(rect.size.height.rounded(.awayFromZero))
        )
    }

    public func createTextView() -> Widget {
        let field = NSTextField(wrappingLabelWithString: "")
        // Somewhat unintuitively, this changes the behaviour of the text field even
        // though it's not editable. It prevents the text from resetting to default
        // styles when clicked (yeah that happens...)
        field.allowsEditingTextAttributes = true
        field.isSelectable = false
        field.cell?.truncatesLastVisibleLine = true
        return field
    }

    public func updateTextView(
        _ textView: Widget,
        content: String,
        environment: EnvironmentValues
    ) {
        let field = textView as! NSTextField
        field.attributedStringValue = Self.attributedString(for: content, in: environment)
        if field.isSelectable && !environment.isTextSelectionEnabled {
            field.abortEditing()
        }
        field.isSelectable = environment.isTextSelectionEnabled
    }

    public func createButton() -> Widget {
        return NSButton(title: "", target: nil, action: nil)
    }

    public func updateButton(
        _ button: Widget,
        label: String,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        let button = button as! NSButton
        button.attributedTitle = Self.attributedString(
            for: label,
            in: environment.with(\.multilineTextAlignment, .center)
        )
        button.bezelStyle = .regularSquare
        button.appearance = environment.colorScheme.nsAppearance
        button.isEnabled = environment.isEnabled
        button.onAction = { _ in
            action()
        }
    }

    public func createSwitch() -> Widget {
        return NSSwitch()
    }

    public func updateSwitch(
        _ toggleSwitch: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        let toggleSwitch = toggleSwitch as! NSSwitch
        toggleSwitch.isEnabled = environment.isEnabled
        toggleSwitch.onAction = { toggleSwitch in
            let toggleSwitch = toggleSwitch as! NSSwitch
            onChange(toggleSwitch.state == .on)
        }
    }

    public func setState(ofSwitch toggleSwitch: Widget, to state: Bool) {
        let toggleSwitch = toggleSwitch as! NSSwitch
        toggleSwitch.state = state ? .on : .off
    }

    public func createToggle() -> Widget {
        let toggle = NSButton()
        toggle.setButtonType(.pushOnPushOff)
        return toggle
    }

    public func updateToggle(
        _ toggle: Widget,
        label: String,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        let toggle = toggle as! NSButton
        toggle.attributedTitle = Self.attributedString(
            for: label,
            in: environment.with(\.multilineTextAlignment, .center)
        )
        toggle.isEnabled = environment.isEnabled
        toggle.onAction = { toggle in
            let toggle = toggle as! NSButton
            onChange(toggle.state == .on)
        }
    }

    public func setState(ofToggle toggle: Widget, to state: Bool) {
        let toggle = toggle as! NSButton
        toggle.state = state ? .on : .off
    }

    public func createCheckbox() -> Widget {
        NSButton(checkboxWithTitle: "", target: nil, action: nil)
    }

    public func updateCheckbox(
        _ checkbox: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        let checkbox = checkbox as! NSButton
        checkbox.isEnabled = environment.isEnabled
        checkbox.onAction = { toggle in
            let checkbox = toggle as! NSButton
            onChange(checkbox.state == .on)
        }
    }

    public func setState(ofCheckbox checkbox: Widget, to state: Bool) {
        let toggle = checkbox as! NSButton
        toggle.state = state ? .on : .off
    }

    public func createSlider() -> Widget {
        return NSSlider()
    }

    public func updateSlider(
        _ slider: Widget,
        minimum: Double,
        maximum: Double,
        decimalPlaces: Int,
        environment: EnvironmentValues,
        onChange: @escaping (Double) -> Void
    ) {
        // TODO: Implement decimalPlaces
        let slider = slider as! NSSlider
        slider.minValue = minimum
        slider.maxValue = maximum
        slider.onAction = { slider in
            let slider = slider as! NSSlider
            onChange(slider.doubleValue)
        }
        slider.isEnabled = environment.isEnabled
    }

    public func setValue(ofSlider slider: Widget, to value: Double) {
        let slider = slider as! NSSlider
        slider.doubleValue = value
    }

    public func createPicker() -> Widget {
        return NSPopUpButton()
    }

    public func updatePicker(
        _ picker: Widget,
        options: [String],
        environment: EnvironmentValues,
        onChange: @escaping (Int?) -> Void
    ) {
        let picker = picker as! NSPopUpButton
        picker.isEnabled = environment.isEnabled
        picker.menu?.removeAllItems()
        for option in options {
            let item = NSMenuItem()
            item.attributedTitle = Self.attributedString(for: option, in: environment)
            picker.menu?.addItem(item)
        }
        picker.onAction = { picker in
            let picker = picker as! NSPopUpButton
            onChange(picker.indexOfSelectedItem)
        }
        picker.bezelStyle = .regularSquare
    }

    public func setSelectedOption(ofPicker picker: Widget, to selectedOption: Int?) {
        let picker = picker as! NSPopUpButton
        if let index = selectedOption {
            picker.selectItem(at: index)
        } else {
            picker.select(nil)
        }
    }

    public func createTextField() -> Widget {
        // Using the `(string:)` initializer ensures that the TextField scrolls
        // smoothly on horizontal overflow instead of jumping a full width at a
        // time.
        let field = NSObservableTextField(string: "")
        return field
    }

    public func updateTextField(
        _ textField: Widget,
        placeholder: String,
        environment: EnvironmentValues,
        onChange: @escaping (String) -> Void,
        onSubmit: @escaping () -> Void
    ) {
        let textField = textField as! NSObservableTextField
        textField.isEnabled = environment.isEnabled
        textField.placeholderString = placeholder
        textField.appearance = environment.colorScheme.nsAppearance
        let resolvedFont = environment.resolvedFont
        if textField.font != Self.font(for: resolvedFont) {
            textField.font = Self.font(for: resolvedFont)
        }
        textField.onEdit = { textField in
            onChange(textField.stringValue)
        }
        textField.onSubmit = onSubmit

        if #available(macOS 14, *) {
            textField.contentType =
                switch environment.textContentType {
                    case .url:
                        .URL
                    case .phoneNumber:
                        .telephoneNumber
                    case .name:
                        .name
                    case .emailAddress:
                        .emailAddress
                    case .text, .digits(_), .decimal(_):
                        nil
                }
        }
    }

    public func getContent(ofTextField textField: Widget) -> String {
        let textField = textField as! NSTextField
        return textField.stringValue
    }

    public func setContent(ofTextField textField: Widget, to content: String) {
        let textField = textField as! NSTextField
        textField.stringValue = content
    }

    public func createTextEditor() -> Widget {
        let textEditor = NSObservableTextView()
        textEditor.drawsBackground = false
        textEditor.delegate = textEditor
        textEditor.allowsUndo = true
        textEditor.textContainerInset = .zero
        textEditor.textContainer?.lineFragmentPadding = 0
        return textEditor
    }

    public func updateTextEditor(
        _ textEditor: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (String) -> Void
    ) {
        let textEditor = textEditor as! NSObservableTextView
        textEditor.onEdit = { textView in
            onChange(self.getContent(ofTextEditor: textView))
        }
        let resolvedFont = environment.resolvedFont
        if textEditor.font != Self.font(for: resolvedFont) {
            textEditor.font = Self.font(for: resolvedFont)
        }
        textEditor.appearance = environment.colorScheme.nsAppearance
        textEditor.isEditable = environment.isEnabled

        if #available(macOS 14, *) {
            textEditor.contentType =
                switch environment.textContentType {
                    case .url:
                        .URL
                    case .phoneNumber:
                        .telephoneNumber
                    case .name:
                        .name
                    case .emailAddress:
                        .emailAddress
                    case .text, .digits(_), .decimal(_):
                        nil
                }
        }
    }

    public func setContent(ofTextEditor textEditor: Widget, to content: String) {
        let textEditor = textEditor as! NSObservableTextView
        textEditor.string = content
    }

    public func getContent(ofTextEditor textEditor: Widget) -> String {
        let textEditor = textEditor as! NSObservableTextView
        return textEditor.string
    }

    public func createScrollContainer(for child: Widget) -> Widget {
        let scrollView = NSScrollView()

        let clipView = scrollView.contentView
        let documentView = NSStackView()
        documentView.orientation = .vertical
        documentView.alignment = .centerX
        documentView.translatesAutoresizingMaskIntoConstraints = false
        documentView.addView(child, in: .top)
        scrollView.documentView = documentView

        scrollView.drawsBackground = false

        documentView.topAnchor.constraint(equalTo: clipView.topAnchor).isActive = true
        documentView.leftAnchor.constraint(equalTo: clipView.leftAnchor).isActive = true
        documentView.heightAnchor.constraint(greaterThanOrEqualTo: clipView.heightAnchor)
            .isActive = true
        documentView.widthAnchor.constraint(greaterThanOrEqualTo: clipView.widthAnchor)
            .isActive = true

        return scrollView
    }

    public func updateScrollContainer(_ scrollView: Widget, environment: EnvironmentValues) {}

    public func setScrollBarPresence(
        ofScrollContainer scrollView: Widget,
        hasVerticalScrollBar: Bool,
        hasHorizontalScrollBar: Bool
    ) {
        let scrollView = scrollView as! NSScrollView
        scrollView.hasVerticalScroller = hasVerticalScrollBar
        scrollView.hasHorizontalScroller = hasHorizontalScrollBar
    }

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
        let listView = (listView as! NSScrollView).documentView! as! NSCustomTableView
        listView.customDelegate.rowCount = items.count
        listView.customDelegate.widgets = items
        listView.customDelegate.rowHeights = rowHeights
        listView.reloadData()
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
        listView.selectRowIndexes(IndexSet([index].compactMap { $0 }), byExtendingSelection: false)
    }

    public func createSplitView(leadingChild: Widget, trailingChild: Widget) -> Widget {
        let splitView = NSCustomSplitView()
        let leadingChildWithEffect = NSVisualEffectView()
        leadingChildWithEffect.blendingMode = .behindWindow
        leadingChildWithEffect.material = .sidebar
        leadingChildWithEffect.addSubview(leadingChild)
        leadingChild.widthAnchor.constraint(equalTo: leadingChildWithEffect.widthAnchor)
            .isActive = true
        leadingChild.heightAnchor.constraint(equalTo: leadingChildWithEffect.heightAnchor)
            .isActive = true
        leadingChild.topAnchor.constraint(equalTo: leadingChildWithEffect.topAnchor)
            .isActive = true
        leadingChild.leadingAnchor.constraint(equalTo: leadingChildWithEffect.leadingAnchor)
            .isActive = true
        leadingChild.translatesAutoresizingMaskIntoConstraints = false
        leadingChildWithEffect.translatesAutoresizingMaskIntoConstraints = false

        splitView.addArrangedSubview(leadingChildWithEffect)
        splitView.addArrangedSubview(trailingChild)
        splitView.isVertical = true
        splitView.dividerStyle = .thin
        let defaultLeadingWidth = 200
        splitView.setPosition(CGFloat(defaultLeadingWidth), ofDividerAt: 0)
        splitView.adjustSubviews()

        let delegate = NSSplitViewResizingDelegate()
        delegate.leadingWidth = defaultLeadingWidth
        splitView.delegate = delegate
        splitView.resizingDelegate = delegate
        return splitView
    }

    public func setResizeHandler(
        ofSplitView splitView: Widget,
        to action: @escaping () -> Void
    ) {
        let splitView = splitView as! NSCustomSplitView
        splitView.resizingDelegate?.setResizeHandler {
            action()
        }
    }

    public func sidebarWidth(ofSplitView splitView: Widget) -> Int {
        let splitView = splitView as! NSCustomSplitView
        return splitView.resizingDelegate!.leadingWidth
    }

    public func setSidebarWidthBounds(
        ofSplitView splitView: Widget,
        minimum minimumWidth: Int,
        maximum maximumWidth: Int
    ) {
        let splitView = splitView as! NSCustomSplitView
        splitView.resizingDelegate!.minimumLeadingWidth = minimumWidth
        splitView.resizingDelegate!.maximumLeadingWidth = maximumWidth
    }

    public func createImageView() -> Widget {
        let imageView = NSImageView()
        imageView.imageScaling = .scaleAxesIndependently
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
        guard dataHasChanged else {
            return
        }

        let imageView = imageView as! NSImageView
        var rgbaData = rgbaData
        let context = CGContext(
            data: &rgbaData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 4 * width,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        let cgImage = context!.makeImage()!

        imageView.image = NSImage(cgImage: cgImage, size: NSSize(width: width, height: height))
    }

    public func createTable() -> Widget {
        let scrollView = NSScrollView()
        let table = NSCustomTableView()
        table.delegate = table.customDelegate
        table.dataSource = table.customDelegate
        table.usesAlternatingRowBackgroundColors = true
        table.rowHeight = CGFloat(
            defaultTableRowContentHeight + 2 * defaultTableCellVerticalPadding
        )
        table.columnAutoresizingStyle = .lastColumnOnlyAutoresizingStyle
        table.allowsColumnSelection = false
        scrollView.documentView = table
        return scrollView
    }

    public func setRowCount(ofTable table: Widget, to rowCount: Int) {
        let table = (table as! NSScrollView).documentView as! NSCustomTableView
        table.customDelegate.rowCount = rowCount
    }

    public func setColumnLabels(
        ofTable table: Widget,
        to labels: [String],
        environment: EnvironmentValues
    ) {
        let table = (table as! NSScrollView).documentView as! NSCustomTableView
        var columnIndices: [ObjectIdentifier: Int] = [:]
        let columns = labels.enumerated().map { (i, label) in
            let column = NSTableColumn(
                identifier: NSUserInterfaceItemIdentifier("Column \(i)")
            )
            column.headerCell = NSTableHeaderCell()
            column.headerCell.attributedStringValue = Self.attributedString(
                for: label,
                in: environment
            )
            columnIndices[ObjectIdentifier(column)] = i
            return column
        }
        table.customDelegate.columnIndices = columnIndices
        for column in table.tableColumns {
            table.removeTableColumn(column)
        }
        table.customDelegate.columnCount = labels.count
        for column in columns {
            table.addTableColumn(column)
        }
    }

    public func setCells(
        ofTable table: Widget,
        to cells: [Widget],
        withRowHeights rowHeights: [Int]
    ) {
        let table = (table as! NSScrollView).documentView as! NSCustomTableView
        table.customDelegate.widgets = cells
        table.customDelegate.rowHeights = rowHeights
        table.reloadData()
    }

    private static func attributedString(
        for text: String,
        in environment: EnvironmentValues
    ) -> NSAttributedString {
        NSAttributedString(
            string: text,
            attributes: attributes(forTextIn: environment)
        )
    }

    private static func attributes(
        forTextIn environment: EnvironmentValues
    ) -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment =
            switch environment.multilineTextAlignment {
                case .leading:
                    .left
                case .center:
                    .center
                case .trailing:
                    .right
            }

        let resolvedFont = environment.resolvedFont

        // This is definitely what these properties were intended for
        paragraphStyle.minimumLineHeight = CGFloat(resolvedFont.lineHeight)
        paragraphStyle.maximumLineHeight = CGFloat(resolvedFont.lineHeight)
        paragraphStyle.lineSpacing = 0

        return [
            .foregroundColor: environment.suggestedForegroundColor.resolve(in: environment).nsColor,
            .font: font(for: resolvedFont),
            .paragraphStyle: paragraphStyle,
        ]
    }

    private static func font(for font: Font.Resolved) -> NSFont {
        let size = CGFloat(font.pointSize)
        let weight = weight(for: font.weight)

        let nsFont: NSFont
        switch font.identifier.kind {
            case .system:
                switch font.design {
                    case .default:
                        nsFont = NSFont.systemFont(ofSize: size, weight: weight)
                    case .monospaced:
                        nsFont = NSFont.monospacedSystemFont(ofSize: size, weight: weight)
                }
        }

        if font.isItalic {
            return NSFontManager.shared.convert(nsFont, toHaveTrait: .italicFontMask)
        } else {
            return nsFont
        }
    }

    private static func weight(for weight: Font.Weight) -> NSFont.Weight {
        switch weight {
            case .thin:
                .thin
            case .ultraLight:
                .ultraLight
            case .light:
                .light
            case .regular:
                .regular
            case .medium:
                .medium
            case .semibold:
                .semibold
            case .bold:
                .bold
            case .black:
                .black
            case .heavy:
                .heavy
        }
    }

    public func createProgressSpinner() -> Widget {
        let container = NSView()
        let spinner = NSProgressIndicator()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.isIndeterminate = true
        spinner.style = .spinning
        spinner.startAnimation(nil)
        container.addSubview(spinner)
        return container
    }

    public func setSize(
        ofProgressSpinner widget: Widget,
        to size: SIMD2<Int>
    ) {
        guard Int(widget.frame.size.height) != size.y else { return }
        setSize(of: widget, to: size)
        let spinner = NSProgressIndicator()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.isIndeterminate = true
        spinner.style = .spinning
        spinner.startAnimation(nil)
        spinner.widthAnchor.constraint(equalToConstant: CGFloat(size.x)).isActive = true
        spinner.heightAnchor.constraint(equalToConstant: CGFloat(size.y)).isActive = true

        widget.subviews = []
        widget.addSubview(spinner)
    }

    public func createProgressBar() -> Widget {
        let progressBar = NSProgressIndicator()
        progressBar.isIndeterminate = false
        progressBar.style = .bar
        progressBar.minValue = 0
        progressBar.maxValue = 1
        return progressBar
    }

    public func updateProgressBar(
        _ widget: Widget,
        progressFraction: Double?,
        environment: EnvironmentValues
    ) {
        let progressBar = widget as! NSProgressIndicator
        progressBar.doubleValue = progressFraction ?? 0
        progressBar.appearance = environment.colorScheme.nsAppearance

        if progressFraction == nil && !progressBar.isIndeterminate {
            // Start the indeterminate animation
            progressBar.isIndeterminate = true
            progressBar.startAnimation(nil)
        } else if progressFraction != nil && progressBar.isIndeterminate {
            // Stop the indeterminate animation
            progressBar.isIndeterminate = false
            progressBar.stopAnimation(nil)
        }
    }

    public func createPopoverMenu() -> Menu {
        return NSMenu()
    }

    public func updatePopoverMenu(
        _ menu: Menu,
        content: ResolvedMenu,
        environment: EnvironmentValues
    ) {
        menu.appearance = environment.colorScheme.nsAppearance
        menu.items = Self.renderMenuItems(content.items)
    }

    public func showPopoverMenu(
        _ menu: Menu, at position: SIMD2<Int>, relativeTo widget: Widget,
        closeHandler handleClose: @escaping () -> Void
    ) {
        // NSMenu.popUp(position:at:in:) blocks until the pop up is closed, and has to
        // run on the main thread, so I'm not exactly sure how it doesn't break things,
        // but it hasn't broken anything yet.
        menu.popUp(
            positioning: nil,
            at: NSPoint(x: CGFloat(position.x + 2), y: CGFloat(position.y + 8)),
            in: widget
        )
        handleClose()
    }

    public func createAlert() -> Alert {
        NSAlert()
    }

    public func updateAlert(
        _ alert: Alert,
        title: String,
        actionLabels: [String],
        environment: EnvironmentValues
    ) {
        alert.messageText = title
        for label in actionLabels {
            alert.addButton(withTitle: label)
        }
    }

    public func showAlert(
        _ alert: Alert,
        window: Window?,
        responseHandler handleResponse: @escaping (Int) -> Void
    ) {
        let completionHandler: (NSApplication.ModalResponse) -> Void = { response in
            guard response != .stop, response != .continue else {
                return
            }

            guard response != .abort, response != .cancel else {
                logger.warning("got abort or cancel modal response, unexpected and unhandled")
                return
            }

            let firstButton = NSApplication.ModalResponse.alertFirstButtonReturn.rawValue
            let action = response.rawValue - firstButton
            handleResponse(action)
        }

        if let window {
            alert.beginSheetModal(
                for: window,
                completionHandler: completionHandler
            )
        } else {
            let response = alert.runModal()
            completionHandler(response)
        }
    }

    public func dismissAlert(_ alert: Alert, window: Window?) {
        if let window {
            window.endSheet(alert.window)
        } else {
            NSApplication.shared.stopModal()
        }
    }

    public func showOpenDialog(
        fileDialogOptions: FileDialogOptions,
        openDialogOptions: OpenDialogOptions,
        window: Window?,
        resultHandler handleResult: @escaping (DialogResult<[URL]>) -> Void
    ) {
        let panel = NSOpenPanel()
        panel.message = fileDialogOptions.title
        panel.prompt = fileDialogOptions.defaultButtonLabel
        panel.directoryURL = fileDialogOptions.initialDirectory
        panel.showsHiddenFiles = fileDialogOptions.showHiddenFiles
        panel.allowsOtherFileTypes = fileDialogOptions.allowOtherContentTypes

        // TODO: allowedContentTypes

        panel.allowsMultipleSelection = openDialogOptions.allowMultipleSelections
        panel.canChooseFiles = openDialogOptions.allowSelectingFiles
        panel.canChooseDirectories = openDialogOptions.allowSelectingDirectories

        let handleResponse: (NSApplication.ModalResponse) -> Void = { response in
            guard response != .continue else {
                return
            }

            if response == .OK {
                handleResult(.success(panel.urls))
            } else {
                handleResult(.cancelled)
            }
        }

        if let window {
            panel.beginSheetModal(for: window, completionHandler: handleResponse)
        } else {
            let response = panel.runModal()
            handleResponse(response)
        }
    }

    public func showSaveDialog(
        fileDialogOptions: FileDialogOptions,
        saveDialogOptions: SaveDialogOptions,
        window: Window?,
        resultHandler handleResult: @escaping (DialogResult<URL>) -> Void
    ) {
        let panel = NSSavePanel()
        panel.message = fileDialogOptions.title
        panel.prompt = fileDialogOptions.defaultButtonLabel
        panel.directoryURL = fileDialogOptions.initialDirectory
        panel.showsHiddenFiles = fileDialogOptions.showHiddenFiles
        panel.allowsOtherFileTypes = fileDialogOptions.allowOtherContentTypes

        // TODO: allowedContentTypes

        panel.nameFieldLabel = saveDialogOptions.nameFieldLabel ?? panel.nameFieldLabel
        panel.nameFieldStringValue = saveDialogOptions.defaultFileName ?? ""

        let handleResponse: (NSApplication.ModalResponse) -> Void = { response in
            guard response != .continue else {
                return
            }

            if response == .OK {
                handleResult(.success(panel.url!))
            } else {
                handleResult(.cancelled)
            }
        }

        if let window {
            panel.beginSheetModal(for: window, completionHandler: handleResponse)
        } else {
            let response = panel.runModal()
            handleResponse(response)
        }
    }

    public func createTapGestureTarget(wrapping child: Widget, gesture _: TapGesture) -> Widget {
        let container = NSView()

        container.addSubview(child)
        child.leadingAnchor.constraint(equalTo: container.leadingAnchor)
            .isActive = true
        child.topAnchor.constraint(equalTo: container.topAnchor)
            .isActive = true
        child.translatesAutoresizingMaskIntoConstraints = false

        let tapGestureTarget = NSCustomTapGestureTarget()
        container.addSubview(tapGestureTarget)
        tapGestureTarget.leadingAnchor.constraint(equalTo: container.leadingAnchor)
            .isActive = true
        tapGestureTarget.topAnchor.constraint(equalTo: container.topAnchor)
            .isActive = true
        tapGestureTarget.trailingAnchor.constraint(equalTo: container.trailingAnchor)
            .isActive = true
        tapGestureTarget.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            .isActive = true
        tapGestureTarget.translatesAutoresizingMaskIntoConstraints = false

        return container
    }

    public func updateTapGestureTarget(
        _ container: Widget,
        gesture: TapGesture,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        let tapGestureTarget = container.subviews[1] as! NSCustomTapGestureTarget
        switch (gesture.kind, environment.isEnabled) {
            case (_, false):
                tapGestureTarget.leftClickHandler = nil
                tapGestureTarget.rightClickHandler = nil
                tapGestureTarget.longPressHandler = nil
            case (.primary, true):
                tapGestureTarget.leftClickHandler = action
                tapGestureTarget.rightClickHandler = nil
                tapGestureTarget.longPressHandler = nil
            case (.secondary, true):
                tapGestureTarget.leftClickHandler = nil
                tapGestureTarget.rightClickHandler = action
                tapGestureTarget.longPressHandler = nil
            case (.longPress, true):
                tapGestureTarget.leftClickHandler = nil
                tapGestureTarget.rightClickHandler = nil
                tapGestureTarget.longPressHandler = action
        }
    }

    public func createHoverTarget(wrapping child: Widget) -> Widget {
        let container = NSView()

        container.addSubview(child)
        child.leadingAnchor.constraint(equalTo: container.leadingAnchor)
            .isActive = true
        child.topAnchor.constraint(equalTo: container.topAnchor)
            .isActive = true
        child.translatesAutoresizingMaskIntoConstraints = false

        let hoverGestureTarget = NSCustomHoverTarget()
        container.addSubview(hoverGestureTarget)
        hoverGestureTarget.leadingAnchor.constraint(equalTo: container.leadingAnchor)
            .isActive = true
        hoverGestureTarget.topAnchor.constraint(equalTo: container.topAnchor)
            .isActive = true
        hoverGestureTarget.trailingAnchor.constraint(equalTo: container.trailingAnchor)
            .isActive = true
        hoverGestureTarget.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            .isActive = true
        hoverGestureTarget.translatesAutoresizingMaskIntoConstraints = false

        return container
    }

    public func updateHoverTarget(
        _ container: Widget,
        environment: EnvironmentValues,
        action: @escaping (Bool) -> Void
    ) {
        let hoverGestureTarget = container.subviews[1] as! NSCustomHoverTarget
        hoverGestureTarget.hoverChangesHandler = action
    }

    final class NSBezierPathView: NSView {
        var path: NSBezierPath!
        var fillColor: NSColor = .clear
        var strokeColor: NSColor = .clear

        override func draw(_ dirtyRect: NSRect) {
            fillColor.set()
            path.fill()
            strokeColor.set()
            path.stroke()
        }
    }

    public func createPathWidget() -> NSView {
        NSBezierPathView()
    }

    public func createPath() -> Path {
        NSBezierPath()
    }

    func applyStrokeStyle(_ strokeStyle: StrokeStyle, to path: NSBezierPath) {
        path.lineWidth = CGFloat(strokeStyle.width)

        path.lineCapStyle =
            switch strokeStyle.cap {
                case .butt:
                    .butt
                case .round:
                    .round
                case .square:
                    .square
            }

        switch strokeStyle.join {
            case .miter(let limit):
                path.lineJoinStyle = .miter
                path.miterLimit = CGFloat(limit)
            case .round:
                path.lineJoinStyle = .round
            case .bevel:
                path.lineJoinStyle = .bevel
        }
    }

    public func updatePath(
        _ path: Path,
        _ source: SwiftCrossUI.Path,
        bounds: SwiftCrossUI.Path.Rect,
        pointsChanged: Bool,
        environment: EnvironmentValues
    ) {
        applyStrokeStyle(source.strokeStyle, to: path)

        if pointsChanged {
            path.removeAllPoints()
            applyActions(
                source.actions,
                to: path,
                bounds: bounds,
                applyCoordinateSystemCorrection: true
            )
        }
    }

    func applyActions(
        _ actions: [SwiftCrossUI.Path.Action],
        to path: NSBezierPath,
        bounds: SwiftCrossUI.Path.Rect,
        applyCoordinateSystemCorrection: Bool
    ) {
        for action in actions {
            switch action {
                case .moveTo(let point):
                    path.move(to: NSPoint(x: point.x, y: point.y))
                case .lineTo(let point):
                    if path.isEmpty {
                        path.move(to: .zero)
                    }
                    path.line(to: NSPoint(x: point.x, y: point.y))
                case .quadCurve(let control, let end):
                    if path.isEmpty {
                        path.move(to: .zero)
                    }

                    if #available(macOS 14, *) {
                        // Use the native quadratic curve function
                        path.curve(
                            to: NSPoint(x: end.x, y: end.y),
                            controlPoint: NSPoint(x: control.x, y: control.y)
                        )
                    } else {
                        let start = path.currentPoint
                        // Build a cubic curve that follows the same path as the quadratic
                        path.curve(
                            to: NSPoint(x: end.x, y: end.y),
                            controlPoint1: NSPoint(
                                x: (start.x + 2.0 * control.x) / 3.0,
                                y: (start.y + 2.0 * control.y) / 3.0
                            ),
                            controlPoint2: NSPoint(
                                x: (2.0 * control.x + end.x) / 3.0,
                                y: (2.0 * control.y + end.y) / 3.0
                            )
                        )
                    }
                case .cubicCurve(let control1, let control2, let end):
                    if path.isEmpty {
                        path.move(to: .zero)
                    }

                    path.curve(
                        to: NSPoint(x: end.x, y: end.y),
                        controlPoint1: NSPoint(x: control1.x, y: control1.y),
                        controlPoint2: NSPoint(x: control2.x, y: control2.y)
                    )
                case .rectangle(let rect):
                    path.appendRect(
                        NSRect(
                            origin: NSPoint(x: rect.x, y: rect.y),
                            size: NSSize(
                                width: CGFloat(rect.width),
                                height: CGFloat(rect.height)
                            )
                        )
                    )
                case .circle(let center, let radius):
                    path.appendOval(
                        in: NSRect(
                            origin: NSPoint(x: center.x - radius, y: center.y - radius),
                            size: NSSize(
                                width: CGFloat(radius) * 2.0,
                                height: CGFloat(radius) * 2.0
                            )
                        )
                    )
                case .arc(
                    let center,
                    let radius,
                    let startAngle,
                    let endAngle,
                    let clockwise
                ):
                    path.appendArc(
                        withCenter: NSPoint(x: center.x, y: center.y),
                        radius: CGFloat(radius),
                        startAngle: CGFloat(startAngle * 180.0 / .pi),
                        endAngle: CGFloat(endAngle * 180.0 / .pi),
                        // Due to being in a flipped coordinate system (before the
                        // correction gets applied), we have to reverse all arcs.
                        clockwise: !clockwise
                    )
                case .transform(let transform):
                    let affineTransform = Foundation.AffineTransform(
                        m11: CGFloat(transform.linearTransform.x),
                        m12: CGFloat(transform.linearTransform.z),
                        m21: CGFloat(transform.linearTransform.y),
                        m22: CGFloat(transform.linearTransform.w),
                        tX: CGFloat(transform.translation.x),
                        tY: CGFloat(transform.translation.y)
                    )
                    path.transform(using: affineTransform)
                case .subpath(let subpathActions):
                    let subpath = NSBezierPath()
                    // We don't apply the coordinate system correction to the subpath,
                    // we only want to apply it to the whole path once we're done.
                    applyActions(
                        subpathActions,
                        to: subpath,
                        bounds: bounds,
                        applyCoordinateSystemCorrection: false
                    )
                    path.append(subpath)
            }
        }

        if applyCoordinateSystemCorrection {
            // AppKit's coordinate system has a flipped Y axis so we have to correct for that
            // once we've constructed the whole path.
            var coordinateSystemCorrection = Foundation.AffineTransform(scaleByX: 1, byY: -1)
            coordinateSystemCorrection.append(
                Foundation.AffineTransform(translationByX: 0, byY: bounds.maxY + bounds.y)
            )
            path.transform(using: coordinateSystemCorrection)
        }
    }

    public func renderPath(
        _ path: Path,
        container: Widget,
        strokeColor: Color.Resolved,
        fillColor: Color.Resolved,
        overrideStrokeStyle: StrokeStyle?
    ) {
        if let overrideStrokeStyle {
            applyStrokeStyle(overrideStrokeStyle, to: path)
        }

        let widget = container as! NSBezierPathView
        widget.path = path
        widget.strokeColor = strokeColor.nsColor
        widget.fillColor = fillColor.nsColor

        widget.needsDisplay = true
    }

    public func createWebView() -> Widget {
        let webView = CustomWKWebView()
        webView.navigationDelegate = webView.strongNavigationDelegate
        return webView
    }

    public func updateWebView(
        _ webView: Widget,
        environment: EnvironmentValues,
        onNavigate: @escaping (URL) -> Void
    ) {
        let webView = webView as! CustomWKWebView
        webView.strongNavigationDelegate.onNavigate = onNavigate
    }

    public func navigateWebView(_ webView: Widget, to url: URL) {
        let webView = webView as! CustomWKWebView
        let request = URLRequest(url: url)
        webView.load(request)
    }

    public func createSheet(content: NSView) -> NSCustomSheet {
        // Initialize with a default contentRect, similar to `createWindow`
        let sheet = NSCustomSheet(
            contentRect: NSRect(
                x: 0,
                y: 0,
                width: 400,
                height: 400
            ),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: true
        )

        let backgroundView = NSView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.wantsLayer = true

        let contentView = NSView()
        contentView.addSubview(backgroundView)
        contentView.addSubview(content)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: content.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: content.bottomAnchor),
            contentView.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
            contentView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
        ])
        contentView.translatesAutoresizingMaskIntoConstraints = false

        sheet.contentView = contentView
        sheet.backgroundView = backgroundView

        return sheet
    }

    public func updateSheet(
        _ sheet: NSCustomSheet,
        window: NSCustomWindow,
        environment: EnvironmentValues,
        size: SIMD2<Int>,
        onDismiss: @escaping () -> Void,
        cornerRadius: Double?,
        detents: [PresentationDetent],
        dragIndicatorVisibility: Visibility,
        backgroundColor: Color.Resolved?,
        interactiveDismissDisabled: Bool
    ) {
        sheet.setContentSize(NSSize(width: size.x, height: size.y))
        sheet.onDismiss = onDismiss

        let background = sheet.backgroundView!
        background.layer?.backgroundColor = backgroundColor?.nsColor.cgColor
        sheet.interactiveDismissDisabled = interactiveDismissDisabled

        // - dragIndicatorVisibility is only for mobile so we ignore it
        // - detents are only for mobile so we ignore them
        // - cornerRadius isn't supported by macOS so we ignore it
    }

    public func size(ofSheet sheet: NSCustomSheet) -> SIMD2<Int> {
        guard let size = sheet.contentView?.frame.size else {
            return SIMD2(x: 0, y: 0)
        }
        return SIMD2(x: Int(size.width), y: Int(size.height))
    }

    public func presentSheet(_ sheet: NSCustomSheet, window: Window, parentSheet: Sheet?) {
        let parent = parentSheet ?? window
        // beginSheet and beginCriticalSheet should be equivalent here, because we
        // directly present the sheet on top of the top-most sheet. If we were to
        // instead present sheets on top of the root window every time, then
        // beginCriticalSheet would produce the desired behaviour and beginSheet
        // would wait for the parent sheet to finish before presenting the nested sheet.
        parent.beginSheet(sheet)
        parent.nestedSheet = sheet
    }

    public func dismissSheet(_ sheet: NSCustomSheet, window: Window, parentSheet: Sheet?) {
        let parent = parentSheet ?? window

        // Dismiss nested sheets first
        if let nestedSheet = sheet.nestedSheet {
            dismissSheet(nestedSheet, window: window, parentSheet: sheet)
            // Although the current sheet has been dismissed programmatically,
            // the nested sheets kind of haven't (at least, they weren't
            // directly dismissed by SwiftCrossUI, so we must called onDismiss
            // to let SwiftUI react to the dismissals of nested sheets).
            nestedSheet.onDismiss?()
        }

        parent.endSheet(sheet)
        parent.nestedSheet = nil
    }

    public func createDatePicker() -> NSView {
        let datePicker = CustomDatePicker()
        datePicker.delegate = datePicker.strongDelegate
        return datePicker
    }

    // Depending on the calendar, era is either necessary or must be omitted. Making the wrong
    // choice for the current calendar means the cursor position is reset after every keystroke. I
    // know of no simple way to tell whether NSDatePicker requires or forbids eras for a given
    // calendar, so in lieu of that I have hardcoded the calendar identifiers.
    private let calendarsRequiringEra: Set<Calendar.Identifier> = [
        .buddhist, .coptic, .ethiopicAmeteAlem, .ethiopicAmeteMihret, .indian, .islamic,
        .islamicCivil, .islamicTabular, .islamicUmmAlQura, .japanese, .persian, .republicOfChina,
    ]

    public func updateDatePicker(
        _ datePicker: NSView,
        environment: EnvironmentValues,
        date: Date,
        range: ClosedRange<Date>,
        components: DatePickerComponents,
        onChange: @escaping (Date) -> Void
    ) {
        let datePicker = datePicker as! CustomDatePicker

        datePicker.isEnabled = environment.isEnabled
        datePicker.textColor = environment.suggestedForegroundColor.resolve(in: environment).nsColor

        // If the time zone is set to autoupdatingCurrent, then the cursor position is reset after
        // every keystroke. Thanks Apple
        datePicker.timeZone =
            environment.timeZone == .autoupdatingCurrent ? .current : environment.timeZone

        // A couple properties cause infinite update loops if we assign to them on every update, so
        // check their values first.
        if datePicker.calendar != environment.calendar {
            datePicker.calendar = environment.calendar
        }

        if datePicker.dateValue != date {
            datePicker.dateValue = date
        }

        var elementFlags: NSDatePicker.ElementFlags = []
        if components.contains(.date) {
            elementFlags.insert(.yearMonthDay)
            if calendarsRequiringEra.contains(environment.calendar.identifier) {
                elementFlags.insert(.era)
            }
        }
        if components.contains(.hourMinuteAndSecond) {
            elementFlags.insert(.hourMinuteSecond)
        } else if components.contains(.hourAndMinute) {
            elementFlags.insert(.hourMinute)
        }

        if datePicker.datePickerElements != elementFlags {
            datePicker.datePickerElements = elementFlags
        }

        datePicker.strongDelegate.onChange = onChange

        datePicker.minDate = range.lowerBound
        datePicker.maxDate = range.upperBound

        datePicker.datePickerStyle =
            switch environment.datePickerStyle {
                case .automatic, .compact:
                    .textFieldAndStepper
                case .graphical:
                    .clockAndCalendar
            }
    }
}

public final class NSCustomSheet: NSCustomWindow, NSWindowDelegate {
    public var onDismiss: (() -> Void)?

    public var interactiveDismissDisabled: Bool = false

    public var backgroundView: NSView?

    @objc override public func cancelOperation(_ sender: Any?) {
        if !interactiveDismissDisabled {
            sheetParent?.endSheet(self)
            onDismiss?()
        }
    }
}

final class NSCustomTapGestureTarget: NSView {
    var leftClickHandler: (() -> Void)? {
        didSet {
            if leftClickHandler != nil && leftClickRecognizer == nil {
                let gestureRecognizer = NSClickGestureRecognizer(
                    target: self, action: #selector(leftClick))
                addGestureRecognizer(gestureRecognizer)
                leftClickRecognizer = gestureRecognizer
            } else if leftClickHandler == nil, let leftClickRecognizer {
                removeGestureRecognizer(leftClickRecognizer)
                self.leftClickRecognizer = nil
            }
        }
    }

    var rightClickHandler: (() -> Void)? {
        didSet {
            if rightClickHandler != nil && rightClickRecognizer == nil {
                let gestureRecognizer = NSClickGestureRecognizer(
                    target: self, action: #selector(rightClick))
                gestureRecognizer.buttonMask = 1 << 1
                addGestureRecognizer(gestureRecognizer)
                rightClickRecognizer = gestureRecognizer
            } else if rightClickHandler == nil, let rightClickRecognizer {
                removeGestureRecognizer(rightClickRecognizer)
                self.rightClickRecognizer = nil
            }
        }
    }

    var longPressHandler: (() -> Void)? {
        didSet {
            if longPressHandler != nil && longPressRecognizer == nil {
                let gestureRecognizer = NSPressGestureRecognizer(
                    target: self, action: #selector(longPress))
                // Both GTK and UIKit default to half a second for long presses
                gestureRecognizer.minimumPressDuration = 0.5
                addGestureRecognizer(gestureRecognizer)
                longPressRecognizer = gestureRecognizer
            } else if longPressHandler == nil, let longPressRecognizer {
                removeGestureRecognizer(longPressRecognizer)
                self.longPressRecognizer = nil
            }
        }
    }

    private var leftClickRecognizer: NSClickGestureRecognizer?
    private var rightClickRecognizer: NSClickGestureRecognizer?
    private var longPressRecognizer: NSPressGestureRecognizer?

    @objc
    func leftClick() {
        leftClickHandler?()
    }

    @objc
    func rightClick() {
        rightClickHandler?()
    }

    @objc
    func longPress(sender: NSPressGestureRecognizer) {
        // GTK emits the event once as soon as the gesture is recognized.
        // AppKit emits it twice, once when it's recognized and once when you release the mouse button.
        // For consistency, ignore the second event.
        if sender.state != .ended {
            longPressHandler?()
        }
    }
}

final class NSCustomHoverTarget: NSView {
    var hoverChangesHandler: ((Bool) -> Void)? {
        didSet {
            if hoverChangesHandler != nil && trackingArea == nil {
                setNewTrackingArea()
            } else if hoverChangesHandler == nil, let trackingArea {
                removeTrackingArea(trackingArea)
                self.trackingArea = nil
            }
        }
    }

    private var trackingArea: NSTrackingArea?

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingArea {
            self.removeTrackingArea(trackingArea)
        }
        setNewTrackingArea()
    }

    override func mouseEntered(with event: NSEvent) {
        hoverChangesHandler?(true)
    }

    override func mouseExited(with event: NSEvent) {
        hoverChangesHandler?(false)
    }

    private func setNewTrackingArea() {
        let options: NSTrackingArea.Options = [
            .mouseEnteredAndExited,
            .activeInKeyWindow,
        ]
        let area = NSTrackingArea(
            rect: self.bounds,
            options: options,
            owner: self,
            userInfo: nil)
        addTrackingArea(area)
        trackingArea = area
    }
}

final class NSCustomMenuItem: NSMenuItem {
    /// This property's only purpose is to keep a strong reference to the wrapped
    /// action so that it sticks around for long enough to be useful.
    var actionWrapper: Action?

    var isOn: Bool {
        get { state == .on }
        set { state = newValue ? .on : .off }
    }
}

// TODO: Update all controls to use this style of action passing, seems way nicer
//   than the existing associated keys based approach. And probably more efficient too.
// Source: https://stackoverflow.com/a/36983811
final class Action: NSObject {
    var action: () -> Void

    init(_ action: @escaping () -> Void) {
        self.action = action
        super.init()
    }

    @objc func run() {
        action()
    }
}

class NSCustomTableView: NSTableView {
    var customDelegate = NSCustomTableViewDelegate()
}

class NSCustomTableViewDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    var widgets: [AppKitBackend.Widget] = []
    var rowHeights: [Int] = []
    var columnIndices: [ObjectIdentifier: Int] = [:]
    var rowCount = 0
    var columnCount = 0
    var allowSelections = false
    var selectionHandler: ((Int) -> Void)?

    func numberOfRows(in tableView: NSTableView) -> Int {
        return rowCount
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return CGFloat(rowHeights[row])
    }

    func tableView(
        _ tableView: NSTableView,
        viewFor tableColumn: NSTableColumn?,
        row: Int
    ) -> NSView? {
        guard let tableColumn else {
            logger.warning("no column provided")
            return nil
        }
        guard let columnIndex = columnIndices[ObjectIdentifier(tableColumn)] else {
            logger.warning("NSTableView asked for value of non-existent column")
            return nil
        }
        return widgets[row * columnCount + columnIndex]
    }

    func tableView(
        _ tableView: NSTableView,
        selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet
    ) -> IndexSet {
        if allowSelections {
            selectionHandler?(proposedSelectionIndexes.first!)
            return proposedSelectionIndexes
        } else {
            return []
        }
    }

    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let view = NSTableRowView()
        view.wantsLayer = true
        view.layer?.cornerRadius = 5
        return view
    }
}

extension ColorScheme {
    var nsAppearance: NSAppearance? {
        switch self {
            case .light:
                return NSAppearance(named: .aqua)
            case .dark:
                return NSAppearance(named: .darkAqua)
        }
    }
}

// Source: https://gist.github.com/sindresorhus/3580ce9426fff8fafb1677341fca4815
enum AssociationPolicy {
    case assign
    case retainNonatomic
    case copyNonatomic
    case retain
    case copy

    var rawValue: objc_AssociationPolicy {
        switch self {
            case .assign:
                return .OBJC_ASSOCIATION_ASSIGN
            case .retainNonatomic:
                return .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            case .copyNonatomic:
                return .OBJC_ASSOCIATION_COPY_NONATOMIC
            case .retain:
                return .OBJC_ASSOCIATION_RETAIN
            case .copy:
                return .OBJC_ASSOCIATION_COPY
        }
    }
}

// Source: https://gist.github.com/sindresorhus/3580ce9426fff8fafb1677341fca4815
final class ObjectAssociation<T: Any> {
    private let policy: AssociationPolicy

    init(policy: AssociationPolicy = .retainNonatomic) {
        self.policy = policy
    }

    subscript(index: AnyObject) -> T? {
        get {
            // Force-cast is fine here as we want it to fail loudly if we don't use the correct type.
            // swiftlint:disable:next force_cast
            objc_getAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque()) as! T?
        }
        set {
            objc_setAssociatedObject(
                index, Unmanaged.passUnretained(self).toOpaque(), newValue, policy.rawValue)
        }
    }
}

class NSObservableTextField: NSTextField {
    override func textDidChange(_ notification: Notification) {
        onEdit?(self)
    }

    var onEdit: ((NSTextField) -> Void)?
    var _onSubmitAction = Action({})
    var onSubmit: () -> Void {
        get {
            _onSubmitAction.action
        }
        set {
            _onSubmitAction.action = newValue
            action = #selector(_onSubmitAction.run)
            target = _onSubmitAction
        }
    }
}

class NSObservableTextView: NSTextView, NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        onEdit?(self)
    }

    var onEdit: ((NSTextView) -> Void)?
}

// Source: https://gist.github.com/sindresorhus/3580ce9426fff8fafb1677341fca4815
extension NSControl {
    typealias ActionClosure = ((NSControl) -> Void)
    typealias EditClosure = ((NSTextField) -> Void)

    struct AssociatedKeys {
        static let onActionClosure = ObjectAssociation<ActionClosure>()
        static let onEditClosure = ObjectAssociation<EditClosure>()
    }

    @objc
    func callClosure(_ sender: NSControl) {
        onAction?(sender)
    }

    var onAction: ActionClosure? {
        get {
            return AssociatedKeys.onActionClosure[self]
        }
        set {
            AssociatedKeys.onActionClosure[self] = newValue
            action = #selector(callClosure)
            target = self
        }
    }
}

class NSCustomSplitView: NSSplitView {
    var resizingDelegate: NSSplitViewResizingDelegate?
}

class NSSplitViewResizingDelegate: NSObject, NSSplitViewDelegate {
    var resizeHandler: (() -> Void)?
    var leadingWidth = 0
    var minimumLeadingWidth = 0
    var maximumLeadingWidth = 0
    var isFirstUpdate = true
    /// Tracks whether AppKit is resizing the side bar (as opposed to the user resizing it).
    var appKitIsResizing = false

    func setResizeHandler(_ handler: @escaping () -> Void) {
        resizeHandler = handler
    }

    func splitView(_ splitView: NSSplitView, shouldAdjustSizeOfSubview view: NSView) -> Bool {
        appKitIsResizing = true
        return true
    }

    func splitViewDidResizeSubviews(_ notification: Notification) {
        appKitIsResizing = false
        let splitView = notification.object! as! NSSplitView
        let paneWidths = splitView.subviews.map(\.frame.width).map { width in
            Int(width.rounded())
        }
        let previousWidth = leadingWidth
        leadingWidth = paneWidths[0]

        // Only call the handler if the side bar has actually changed size.
        if leadingWidth != previousWidth {
            resizeHandler?()
        }
    }

    func splitView(
        _ splitView: NSSplitView,
        constrainMinCoordinate proposedMinimumPosition: CGFloat,
        ofSubviewAt dividerIndex: Int
    ) -> CGFloat {
        if dividerIndex == 0 {
            return CGFloat(minimumLeadingWidth)
        } else {
            return proposedMinimumPosition
        }
    }

    func splitView(
        _ splitView: NSSplitView,
        constrainMaxCoordinate proposedMaximumPosition: CGFloat,
        ofSubviewAt dividerIndex: Int
    ) -> CGFloat {
        if dividerIndex == 0 {
            return CGFloat(maximumLeadingWidth)
        } else {
            return proposedMaximumPosition
        }
    }

    func splitView(_ splitView: NSSplitView, resizeSubviewsWithOldSize oldSize: NSSize) {
        splitView.adjustSubviews()

        if isFirstUpdate {
            splitView.setPosition(max(200, CGFloat(minimumLeadingWidth)), ofDividerAt: 0)
            isFirstUpdate = false
        } else {
            let newWidth = splitView.subviews[0].frame.width
            // If AppKit is trying to automatically resize our side bar (e.g. because the split
            // view has changed size), only let it do so if not doing so would put out side bar
            // outside of the allowed bounds.
            if appKitIsResizing
                && leadingWidth >= minimumLeadingWidth
                && leadingWidth <= maximumLeadingWidth
            {
                splitView.setPosition(CGFloat(leadingWidth), ofDividerAt: 0)
            } else {
                // Magic! Thanks https://stackoverflow.com/a/30494691. This one line fixed all
                // of the split view resizing issues.
                splitView.setPosition(newWidth, ofDividerAt: 0)
            }
        }
    }
}

public class NSCustomWindow: NSWindow {
    var customDelegate = Delegate()
    var persistentUndoManager = UndoManager()

    /// A reference to the sheet currently presented on top of this window, if any.
    /// If the sheet itself has another sheet presented on top of it, then that doubly
    /// nested sheet gets stored as the sheet's nestedSheet, and so on.
    var nestedSheet: NSCustomSheet?

    var lastBackingScaleFactor: CGFloat?
    /// Allows the backing scale factor to be overridden. Useful for keeping
    /// UI tests consistent across devices.
    ///
    /// Idea from https://github.com/pointfreeco/swift-snapshot-testing/pull/533
    public var backingScaleFactorOverride: CGFloat?

    public override var backingScaleFactor: CGFloat {
        backingScaleFactorOverride ?? super.backingScaleFactor
    }

    class Delegate: NSObject, NSWindowDelegate {
        var resizeHandler: ((SIMD2<Int>) -> Void)?

        func setHandler(_ resizeHandler: @escaping (SIMD2<Int>) -> Void) {
            self.resizeHandler = resizeHandler
        }

        func windowWillClose(_ notification: Notification) {
            guard let window = notification.object as? NSCustomWindow else { return }

            // Not sure if this is actually needed
            NotificationCenter.default.removeObserver(window)
        }

        func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
            guard let resizeHandler else {
                return frameSize
            }

            let contentSize = sender.contentRect(
                forFrameRect: NSRect(
                    x: sender.frame.origin.x, y: sender.frame.origin.y, width: frameSize.width,
                    height: frameSize.height)
            )

            resizeHandler(
                SIMD2(
                    Int(contentSize.width.rounded(.towardZero)),
                    Int(contentSize.height.rounded(.towardZero))
                )
            )

            return frameSize
        }

        func windowWillReturnUndoManager(_ window: NSWindow) -> UndoManager? {
            (window as! NSCustomWindow).persistentUndoManager
        }
    }
}

extension Notification.Name {
    static let AppleInterfaceThemeChangedNotification = Notification.Name(
        "AppleInterfaceThemeChangedNotification"
    )
}

final class NSCustomApplicationDelegate: NSObject, NSApplicationDelegate {
    var onOpenURLs: (([URL]) -> Void)?

    func application(_ application: NSApplication, open urls: [URL]) {
        onOpenURLs?(urls)
    }
}

/// A scroll view with scrolling gestures disabled. Used as a dummy scroll view to
/// allow us to properly set the width of NSTableView (had some weird issues).
final class NSDisabledScrollView: NSScrollView {
    override func scrollWheel(with event: NSEvent) {
        self.nextResponder?.scrollWheel(with: event)
    }
}

final class CustomWKWebView: WKWebView {
    var strongNavigationDelegate = CustomWKNavigationDelegate()
}

final class CustomWKNavigationDelegate: NSObject, WKNavigationDelegate {
    var onNavigate: ((URL) -> Void)?

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        guard let url = webView.url else {
            logger.warning("web view has no URL")
            return
        }

        onNavigate?(url)
    }
}

final class CustomDatePicker: NSDatePicker {
    var strongDelegate = CustomDatePickerDelegate()
}

final class CustomDatePickerDelegate: NSObject, NSDatePickerCellDelegate {
    var onChange: ((Date) -> Void)?

    func datePickerCell(
        _: NSDatePickerCell,
        validateProposedDateValue proposedDateValue: AutoreleasingUnsafeMutablePointer<NSDate>,
        timeInterval _: UnsafeMutablePointer<TimeInterval>?
    ) {
        onChange?(proposedDateValue.pointee as Date)
    }
}
