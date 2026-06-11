import AppKit
import SwiftCrossUI

extension App {
    public typealias Backend = AppKitBackend

    public var backend: AppKitBackend {
        AppKitBackend()
    }
}

public final class AppKitBackend: FullAppBackend {
    public typealias Window = NSCustomWindow
    public typealias Widget = NSView

    public let defaultTableRowContentHeight = 20
    public let defaultTableCellVerticalPadding = 4
    public let defaultPaddingAmount = 10
    public let requiresToggleSwitchSpacer = false
    public let requiresImageUpdateOnScaleFactorChange = false
    public let supportsMultipleWindows = true
    public let deviceClass = DeviceClass.desktop
    public let canOverrideWindowColorScheme = true

    public var scrollBarWidth: Int {
        // We assume that all scrollers have their controlSize set to `.regular` by default.
        // The internet seems to indicate that this is true regardless of any system wide
        // preferences etc.
        if NSScroller.preferredScrollerStyle == .overlay {
            0
        } else {
            Int(
                NSScroller.scrollerWidth(
                    for: .regular,
                    scrollerStyle: NSScroller.preferredScrollerStyle
                ).rounded(.awayFromZero)
            )
        }
    }

    private let appDelegate = NSCustomApplicationDelegate()

    public init() {
        NSApplication.shared.delegate = appDelegate
    }

    public func runMainLoop(_ callback: @escaping @MainActor () -> Void) {
        // Immediately set up the default menus so that the Window menu can populate
        // correctly.
        MenuBar.setUpMenuBar(extraMenus: [])

        callback()
        NSApplication.shared.activate(ignoringOtherApps: true)
        NSApplication.shared.run()
    }

    public func createWindow(withDefaultSize defaultSize: SIMD2<Int>?) -> Window {
        // For bundled apps, the default activation policy is `regular`, but for unbundled
        // apps without an Info.plist the default is `prohibited` -- i.e. the app can't
        // create windows. We override that here.
        NSApplication.shared.setActivationPolicy(.regular)

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

        // NB: If this isn't set, AppKit will crash within -[NSApplication run]
        // the *second* time `openWindow` is called. I have absolutely no idea
        // why.
        window.isReleasedWhenClosed = false

        return window
    }

    public func updateWindow(_ window: Window, environment: EnvironmentValues) {
        window.appearance = environment.colorScheme.nsAppearance
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
        window.customDelegate.setResizeHandler(action)
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

    public func close(window: Window) {
        window.close()
    }

    public func setCloseHandler(
        ofWindow window: Window,
        to action: @escaping () -> Void
    ) {
        window.customDelegate.setCloseHandler(action)
    }

    public func openExternalURL(_ url: URL) throws {
        NSWorkspace.shared.open(url)
    }

    public func revealFile(_ url: URL) throws {
        NSWorkspace.shared.activateFileViewerSelecting([url])
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
                .with(\.appPhase, NSApplication.shared.isActive ? .active : .inactive)
    }

    public func setRootEnvironmentChangeHandler(
        to action: @escaping @Sendable @MainActor () -> Void
    ) {
        DistributedNotificationCenter.default.addObserver(
            forName: .AppleInterfaceThemeChangedNotification,
            object: nil,
            queue: OperationQueue.main
        ) { _ in
            Task { @MainActor in
                action()
            }
        }

        // This doesn't strictly affect the root environment, but it does require us
        // to re-compute the app's layout, and this is how backends should trigger top
        // level updates.
        DistributedNotificationCenter.default.addObserver(
            forName: NSScroller.preferredScrollerStyleDidChangeNotification,
            object: nil,
            queue: OperationQueue.main
        ) { _ in
            // Self.scrollBarWidth has changed
            Task { @MainActor in
                action()
            }
        }

        NotificationCenter.default.addObserver(
            forName: .NSSystemTimeZoneDidChange,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                action()
            }
        }

        // For updating views that rely on `appPhase`
        NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                action()
            }
        }
        NotificationCenter.default.addObserver(
            forName: NSApplication.didResignActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                action()
            }
        }
    }

    public func computeWindowEnvironment(
        window: Window,
        rootEnvironment: EnvironmentValues
    ) -> EnvironmentValues {
        window.lastBackingScaleFactor = window.backingScaleFactor

        return rootEnvironment
            .with(\.windowScaleFactor, window.backingScaleFactor)
            .with(\.scenePhase, window.isKeyWindow ? .active : .inactive)
    }

    public func setWindowEnvironmentChangeHandler(
        of window: Window,
        to action: @escaping @Sendable @MainActor () -> Void
    ) {
        // For updating window scale factor
        NotificationCenter.default.addObserver(
            forName: NSWindow.didChangeBackingPropertiesNotification,
            object: window,
            queue: .main
        ) { _ in
            Task { @MainActor in
                let backingScaleFactorChanged =
                    window.lastBackingScaleFactor != window.backingScaleFactor

                if backingScaleFactorChanged {
                    action()
                }
            }
        }

        // For updating views that rely on `scenePhase`
        NotificationCenter.default.addObserver(
            forName: NSWindow.didBecomeKeyNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                action()
            }
        }
        NotificationCenter.default.addObserver(
            forName: NSWindow.didResignKeyNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
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
                equalTo: container.leftAnchor,
                constant: CGFloat(position.x)
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
        if let constraint = widget.constraints.first(
            where: { $0.firstAnchor === widget.widthAnchor }
        ) {
            if let proposedWidth = proposedSize.width {
                constraint.constant = CGFloat(proposedWidth)
                constraint.isActive = true
            } else {
                constraint.isActive = false
            }
        } else if let proposedWidth = proposedSize.width {
            widget.widthAnchor.constraint(equalToConstant: proposedWidth).isActive = true
        }

        if let constraint = widget.constraints.first(
            where: { $0.firstAnchor === widget.heightAnchor }
        ) {
            if let proposedHeight = proposedSize.height {
                constraint.constant = CGFloat(proposedHeight)
                constraint.isActive = true
            } else {
                constraint.isActive = false
            }
        } else if let proposedHeight = proposedSize.height {
            widget.heightAnchor.constraint(equalToConstant: proposedHeight).isActive = true
        }
    }

    public func createTooltipContainer(wrapping child: NSView) -> NSView {
        child
    }

    public func updateTooltipContainer(_ widget: NSView, tooltip: String) {
        widget.toolTip = tooltip
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
@MainActor
final class ObjectAssociation<T: Any> {
    private let policy: AssociationPolicy

    init(policy: AssociationPolicy = .retainNonatomic) {
        self.policy = policy
    }

    subscript(index: AnyObject) -> T? {
        get {
            // Force-cast is fine here as we want it to fail loudly if we don't
            // use the correct type.
            objc_getAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque()) as! T?
        }
        set {
            objc_setAssociatedObject(
                index,
                Unmanaged.passUnretained(self).toOpaque(),
                newValue,
                policy.rawValue
            )
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
        var closeHandler: (() -> Void)?

        func setResizeHandler(_ resizeHandler: @escaping (SIMD2<Int>) -> Void) {
            self.resizeHandler = resizeHandler
        }

        func setCloseHandler(_ closeHandler: @escaping () -> Void) {
            self.closeHandler = closeHandler
        }

        func windowWillClose(_ notification: Notification) {
            closeHandler?()

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
                    x: sender.frame.origin.x,
                    y: sender.frame.origin.y,
                    width: frameSize.width,
                    height: frameSize.height
                )
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
