import Android
import Foundation
import SwiftCrossUI
import AndroidKit
import AndroidGraphics
import AndroidBackendShim

/// A widget is just its integer node ID.
public typealias ComposeWidget = Int32

public extension ComposeWidget {
  init() {
    self = -1
  }
}

/// Per-widget closures registered when a widget is created.
public struct EventHandlers {
    var onClick: (() -> Void)?
    var onChange: ((String) -> Void)?
    var onToggle: ((Bool) -> Void)?
    var onSlide:  ((Double) -> Void)?
}

/// Decoded event from the JSON queue.
private struct IncomingEvent: Decodable {
    let id: Int32
    let type: String
    let payload: String

    init?(_ json: String) {
        guard
            let data  = json.data(using: .utf8),
            let event = try? JSONDecoder().decode(IncomingEvent.self, from: data)
        else { return nil }
        self = event
    }
}

func log(_ message: String) {
    android_log(Int32(ANDROID_LOG_DEBUG.rawValue), "swift", message)
}

/// A valid AndroidBackend shim must call this to begin execution of the app.
/// Once initial setup and rendering is done, this function returns control
/// back to the JVM (by returning).
@MainActor
@_cdecl("AndroidBackend_entrypoint")
public func entrypoint(_ env: UnsafeMutablePointer<JNIEnv?>, _ object: jobject) {
    AndroidComposeBackend.env = env

    let holder = JavaObjectHolder(object: object, environment: env)
    AndroidComposeBackend.javaHolder = holder
    AndroidComposeBackend.activity = Activity(javaHolder: holder)

    // Source: https://phatbl.at/2019/01/08/intercepting-stdout-in-swift.html
    func makeMessageHandler(priority: UInt32) -> @Sendable (FileHandle) -> Void {
        @Sendable
        nonisolated func forward(_ fileHandle: FileHandle) {
            let data = fileHandle.availableData
            guard let string = String(data: data, encoding: .utf8) else {
                return
            }

            android_log(
                Int32(priority),
                "Swift",
                string
            )
        }
        return forward
    }

    AndroidComposeBackend.stdoutPipe.fileHandleForReading.readabilityHandler =
        makeMessageHandler(priority: ANDROID_LOG_INFO.rawValue)

    AndroidComposeBackend.stderrPipe.fileHandleForReading.readabilityHandler =
        makeMessageHandler(priority: ANDROID_LOG_ERROR.rawValue)

    dup2(
        AndroidComposeBackend.stdoutPipe.fileHandleForWriting.fileDescriptor,
        FileHandle.standardOutput.fileDescriptor
    )

    dup2(
        AndroidComposeBackend.stderrPipe.fileHandleForWriting.fileDescriptor,
        FileHandle.standardError.fileDescriptor
    )

    // Pass dummy arguments to application main function
    let argv = UnsafeMutableBufferPointer<UnsafeMutablePointer<CChar>?>.allocate(capacity: 1)
    argv[0] = nil

    main(0, argv.baseAddress)
}

extension App {
    public typealias Backend = AndroidComposeBackend

    public var backend: AndroidComposeBackend {
        AndroidComposeBackend()
    }
}

public final class AndroidComposeBackend: BackendFeatures.BaseStubs {
    public final class Window {
        var content: Widget?
    }
  
    public typealias Widget = ComposeWidget

    static let stdoutPipe = Pipe()
    static let stderrPipe = Pipe()
    
    /// Used to determine adaptive sizing behaviour such as
    /// the sizes of the various dynamic ``Font/TextStyle``s.
    public lazy var deviceClass: DeviceClass = .phone
  
    // Shared bridge to the Kotlin host
    public let bridge: AndroidComposeBackendBridge

    // Widget ID allocator — Swift owns this, never Kotlin
    private var nextId: Int32 = 1
    public func allocateId() -> Int32 {
        defer { nextId += 1 }
        return nextId
    }

    // Event handler registry — keyed by widget ID
    public var handlers: [Int32: EventHandlers] = [:]
    
    // Parent widgets.
    private var nodeParent: [Int32: Int32] = [:]
  
    // Children widgets.
    private var children: [Int32: [Int32]] = [:]

    // The Task running the event polling loop
    private var eventLoopTask: Task<Void, Never>?

    private var measuredSizes: [Int32: SIMD2<Int>] = [:]
    private var environmentChangeHandler: (@Sendable @MainActor () -> Void)?
    private var cachedWindowWidth: Int = 426
  
    public let defaultPaddingAmount = 10
    public let scrollBarWidth = 0
    public let requiresImageUpdateOnScaleFactorChange = false
    public let supportsMultipleWindows = false
    public let canOverrideWindowColorScheme = false
  
    /// A reference used to keep the tickler alive.
    var tickler: MainRunLoopTickler?
  
    /// The JNI environment pointer. Set by ``entrypoint``.
    static var env: UnsafeMutablePointer<JNIEnv?>!
    /// The underlying java object. Set by ``entrypoint``.
    static var javaHolder: JavaObjectHolder!
    /// The main activity. Set by ``entrypoint``.
    static var activity: Activity!
  
    public init() {
        self.bridge = AndroidComposeBackendBridge(javaHolder: Self.javaHolder)
        startEventLoop()
    }

    deinit {
        eventLoopTask?.cancel()
        try? bridge.clearAll()
    }

    /// swift-cross-ui calls this to hand control to the backend's run loop.
    /// On Android the Activity already has a Looper, so we just invoke the
    /// callback (which builds the initial widget tree) and return.
    public func runMainLoop(
        _ callback: @escaping @MainActor () -> Void
    ) {
        let tickler = MainRunLoopTickler(environment: Self.env)
        tickler.start()
        self.tickler = tickler
      
        callback()
    }
  
    public func runInMainThread(action: @escaping @MainActor () -> Void) {
        Task { @MainActor in
            action()
        }
    }
  
    public func computeRootEnvironment(defaultEnvironment: EnvironmentValues) -> EnvironmentValues {
        var environment = defaultEnvironment
      
        // TODO(furbytm): Properly detect color scheme, instead of
        // hardcoding this value.

        environment.colorScheme = .dark

        environment.isCircularScreen = Self.activity
            .getResources()
            .getConfiguration()
            .isScreenRound()

        // TODO(bbrk24): Properly detect time zone and calendar, since
        // `.current` is broken on Android.

        return environment
    }
  
    public func createWindow(withDefaultSize defaultSize: SIMD2<Int>?) -> Window {
        // TODO(stackotter): Properly support multiple calls to createWindow
        return Window()
    }
  
    public func setTitle(ofWindow window: Window, to title: String) {
        // TODO(stackotter): Handle navigation titles.
    }
  
    public func setResizeHandler(
        ofWindow window: Window,
        to action: @escaping (_ newSize: SIMD2<Int>) -> Void
    ) {
        // TODO(stackotter): Handle orientation changes and other changes such
        // as density changes.
    }
  
    public func setWindowEnvironmentChangeHandler(
        of window: Window,
        to action: @escaping @Sendable @MainActor () -> Void
    ) {
        // TODO(stackotter): React to per-window environment changes. See
        // computeWindowEnvironment.
    }
  
    public func computeWindowEnvironment(
        window: Window,
        rootEnvironment: EnvironmentValues
    ) -> EnvironmentValues {
        var environment = rootEnvironment
        if let metrics = Self.activity.getResources().getDisplayMetrics() {
            environment.windowScaleFactor = Double(metrics.density)
        }
        return environment
    }
  
    public func setRootEnvironmentChangeHandler(
        to action: @escaping @Sendable @MainActor () -> Void
    ) {
        self.environmentChangeHandler = action
    }
  
    public func isWindowProgrammaticallyResizable(_ window: Window) -> Bool {
        false
    }
  
    public func size(ofWindow window: Window) -> SIMD2<Int> {
        guard let metrics = Self.activity.getResources().getDisplayMetrics() else {
            return SIMD2(360, 800)
        }
        let density = Double(metrics.density)
        let widthDp = Int((Double(metrics.widthPixels) / density).rounded(.down))
        let heightDp = Int((Double(metrics.heightPixels) / density).rounded(.down))
        let insets = (try? bridge.getWindowInsets()) ?? (statusBar: 0, navBar: 0)
        let statusBarDp = insets.statusBar > 0
            ? Int((Double(insets.statusBar) / density).rounded(.down))
            : Int((156.0 / density).rounded(.down))
        let navBarDp = insets.navBar > 0
            ? Int((Double(insets.navBar) / density).rounded(.down))
            : Int((72.0 / density).rounded(.down))
        log("size(ofWindow) density=\(density) w=\(widthDp) h=\(heightDp) statusBar=\(statusBarDp) navBar=\(navBarDp)")
        let result = SIMD2(widthDp, heightDp - statusBarDp - navBarDp)
        cachedWindowWidth = result.x  // ← add this line
        return result
    }
  
    public func updateWindow(_ window: Window, environment: EnvironmentValues) {
        // TODO(stackotter): Update window theme?
        // updateInsets(ofWindow: window)
    }

    public func show(window: Window) {
        log("Show window")
    }
  
    public func show(widget: Widget) {}
  
    public func setChild(ofWindow window: Window, to child: Widget) {
        log("setChild called with child=\(child)")
        if let existing = window.content {
            // Clear the old root before setting new one
            try? bridge.clearAll()
            children.removeAll()
            handlers.removeAll()
            nextId = 1
        }
        let container = createContainer()
        log("created container=\(container)")
        insert(child, into: container, at: 0)
        setPosition(ofChildAt: 0, in: container, to: SIMD2(0, 0))
        window.content = container
        setRootWidget(container)
        log("setRootWidget called with container=\(container)")
    }

    public func createContainer() -> Widget {
        let id = allocateId()
        bridgeCall("createNode Container \(id)") { try bridge.createNode(id: id, type: "Container") }
        return id
    }

    public func setPosition(ofChildAt index: Int, in container: Widget, to position: SIMD2<Int>) {
        guard position.x < 100_000, position.y < 100_000 else {
            log("setPosition: skipping bogus position for container=\(container) pos=\(position)")
            return
        }
        let x = max(0, position.x)
        let y = max(0, position.y)
        if x > 0 {
            log("setPosition: container=\(container) childAt=\(index) x=\(x) y=\(y)")
        }
        try? bridge.setPosition(containerId: container, index: Int32(index), x: Int32(x), y: Int32(y))
    }

    public func setChildren(_ children: [Widget], ofContainer container: Widget) {
        if children.contains(1) {
            log("setChildren: node 1 is being placed in container \(container) with children \(children)")
        }
      
        // Unregister old children's parent
        for child in self.children[container, default: []] {
            nodeParent.removeValue(forKey: child)
        }
        self.children[container] = children
        // Register new children's parent
        for child in children {
            nodeParent[child] = container
        }
        try? bridge.setChildren(parentId: container, childIds: children)
    }

    public func setRootWidget(_ widget: Widget) {
        log("setRootWidget: \(widget)")
        bridgeCall("setRootNode \(widget)") { try bridge.setRootNode(id: widget) }
    }

    public func bridgeCall(_ label: String, _ call: () throws -> Void) {
        do {
            try call()
        } catch {
            log("bridge error [\(label)]: \(error)")
        }
    }
  
    public func remove(childAt index: Int, from container: Widget) {
        log("remove: childAt=\(index) from=\(container)")
        var current = children[container, default: []]
        guard index < current.count else { return }
        current.remove(at: index)
        children[container] = current
        try? bridge.setChildren(parentId: container, childIds: current)
    }
  
    public func insert(_ child: Widget, into container: Widget, at index: Int) {
        log("insert: child=\(child) into=\(container) at=\(index) [oldParent=\(nodeParent[child] ?? -1)]")
        var current = children[container, default: []]
        current.removeAll { $0 == child }
        current.insert(child, at: min(index, current.count))
        children[container] = current
        try? bridge.setChildren(parentId: container, childIds: current)
    }
  
    public func createTextView() -> Widget {
        createTextView(content: "", shouldWrap: false)
    }
  
    public func createTextView(content: String, shouldWrap: Bool) -> Widget {
        let id = allocateId()
        try? bridge.createNode(id: id, type: "Text")
        try? bridge.setProperty(id: id, key: "text", value: content)
        return id
    }
  
    public func setContent(ofTextField textField: Widget, to content: String) {
        try? bridge.setProperty(id: textField, key: "value", value: content)
    }

    public func updateTextView(
        _ textView: Widget,
        content: String,
        environment: EnvironmentValues
    ) {
        try? bridge.setProperty(id: textView, key: "text", value: content)
        let font = environment.resolvedFont
        try? bridge.setProperty(id: textView, key: "fontSize", value: "\(Int(font.pointSize))")
        let weight: String
        switch font.weight {
            case .bold:   weight = "bold"
            case .medium: weight = "medium"
            case .light:  weight = "light"
            default:      weight = "normal"
        }
        try? bridge.setProperty(id: textView, key: "fontWeight", value: weight)
    }
  
    public func updateTextView(_ widget: Widget, content: String, shouldWrap: Bool) {
        try? bridge.setProperty(id: widget, key: "text", value: content)
    }

    public func createButton() -> Widget {
        let id = allocateId()
        try? bridge.createNode(id: id, type: "Button")
        return id
    }
  
    public func createButton(label: String, action: @escaping () -> Void) -> Widget {
        let id = allocateId()
        try? bridge.createNode(id: id, type: "Button")
        try? bridge.setProperty(id: id, key: "label", value: label)
        handlers[id, default: EventHandlers()].onClick = action
        return id
    }

    public func updateButton(_ widget: Widget, label: String, action: @escaping () -> Void) {
        try? bridge.setProperty(id: widget, key: "label", value: label)
        handlers[widget, default: EventHandlers()].onClick = action
    }

    public func updateButton(
        _ widget: Widget,
        label: String,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        try? bridge.setProperty(id: widget, key: "label", value: label)
        handlers[widget, default: EventHandlers()].onClick = action
    }
  
    public func createTextField() -> Widget {
        let id = allocateId()
        try? bridge.createNode(id: id, type: "TextField")
        return id
    }
  
    public func createTextField(
        placeholder: String,
        value: String,
        onChange: @escaping (String) -> Void
    ) -> Widget {
        let id = allocateId()
        try? bridge.createNode(id: id, type: "TextField")
        try? bridge.setProperty(id: id, key: "placeholder", value: placeholder)
        try? bridge.setProperty(id: id, key: "value", value: value)
        handlers[id, default: EventHandlers()].onChange = onChange
        return id
    }

    public func updateTextField(
        _ textField: Widget,
        placeholder: String,
        environment: EnvironmentValues,
        onChange: @escaping (String) -> Void,
        onSubmit: @escaping () -> Void
    ) {
        try? bridge.setProperty(id: textField, key: "placeholder", value: placeholder)
        handlers[textField, default: EventHandlers()].onChange = onChange
    }
  
    public func updateTextField(
        _ widget: Widget,
        placeholder: String,
        value: String,
        onChange: @escaping (String) -> Void
    ) {
        try? bridge.setProperty(id: widget, key: "placeholder", value: placeholder)
        try? bridge.setProperty(id: widget, key: "value", value: value)
        handlers[widget, default: EventHandlers()].onChange = onChange
    }
  
    public func getContent(ofTextField textField: Widget) -> String {
        return (try? bridge.getTextFieldValue(id: textField)) ?? ""
    }
  
    public func createToggle(
        label: String,
        value: Bool,
        onChange: @escaping (Bool) -> Void
    ) -> Widget {
        let id = allocateId()
        try? bridge.createNode(id: id, type: "Toggle")
        try? bridge.setProperty(id: id, key: "label", value: label)
        try? bridge.setProperty(id: id, key: "value", value: value ? "true" : "false")
        handlers[id, default: EventHandlers()].onToggle = onChange
        return id
    }
  
    public func updateToggle(_ widget: Widget, label: String, value: Bool) {
        try? bridge.setProperty(id: widget, key: "label", value: label)
        try? bridge.setProperty(id: widget, key: "value", value: value ? "true" : "false")
    }
  
    public func createSlider() -> Widget {
        let id = allocateId()
        try? bridge.createNode(id: id, type: "Slider")
        return id
    }

    public func createSlider(
        value: Double,
        min: Double,
        max: Double,
        onChange: @escaping (Double) -> Void
    ) -> Widget {
        let id = allocateId()
        try? bridge.createNode(id: id, type: "Slider")
        try? bridge.setProperty(id: id, key: "value", value: "\(value)")
        try? bridge.setProperty(id: id, key: "min", value: "\(min)")
        try? bridge.setProperty(id: id, key: "max", value: "\(max)")
        handlers[id, default: EventHandlers()].onSlide = onChange
        return id
    }

    public func updateSlider(
        _ widget: Widget,
        minimum: Double,
        maximum: Double,
        decimalPlaces: Int,
        environment: EnvironmentValues,
        onChange: @escaping (Double) -> Void
    ) {
        try? bridge.setProperty(id: widget, key: "min", value: "\(minimum)")
        try? bridge.setProperty(id: widget, key: "max", value: "\(maximum)")
        handlers[widget, default: EventHandlers()].onSlide = onChange
    }
  
    public func setValue(ofSlider slider: Widget, to value: Double) {
        try? bridge.setProperty(id: slider, key: "value", value: "\(value)")
    }
  
    public func createSpacer(flexing: Bool, size: Int?) -> Widget {
        let id = allocateId()
        try? bridge.createNode(id: id, type: "Spacer")
        try? bridge.setProperty(id: id, key: "flex", value: flexing ? "true" : "false")
        if let s = size {
            try? bridge.setProperty(id: id, key: "size", value: "\(s)")
        }
        return id
    }

    public func createDivider() -> Widget {
        let id = allocateId()
        try? bridge.createNode(id: id, type: "Divider")
        return id
    }

    public func createSecureField() -> Widget {
        let id = allocateId()
        try? bridge.createNode(id: id, type: "SecureField")
        return id
    }

    public func updateSecureField(
        _ secureField: Widget,
        placeholder: String,
        environment: EnvironmentValues,
        onChange: @escaping (String) -> Void,
        onSubmit: @escaping () -> Void
    ) {
        try? bridge.setProperty(id: secureField, key: "placeholder", value: placeholder)
        try? bridge.setProperty(id: secureField, key: "enabled", value: environment.isEnabled ? "true" : "false")
        handlers[secureField, default: EventHandlers()].onChange = onChange
    }
  
    public func getContent(ofSecureField secureField: Widget) -> String {
        return (try? bridge.getTextFieldValue(id: secureField)) ?? ""
    }

    public func setContent(ofSecureField secureField: Widget, to content: String) {
        try? bridge.setProperty(id: secureField, key: "value", value: content)
    }
  
    public func createProgressSpinner() -> Widget {
        let id = allocateId()
        try? bridge.createNode(id: id, type: "ProgressSpinner")
        return id
    }
  
    public func setSize(ofProgressSpinner widget: Widget, to size: SIMD2<Int>) {
        try? bridge.setProperty(id: widget, key: "width", value: "\(size.x)")
        try? bridge.setProperty(id: widget, key: "height", value: "\(size.y)")
    }
  
    public func createScrollContainer(for child: Widget) -> Widget {
        let id = allocateId()
        try? bridge.createNode(id: id, type: "ScrollContainer")
        insert(child, into: id, at: 0)
        return id
    }

    public func updateScrollContainer(
        _ scrollView: Widget,
        environment: EnvironmentValues,
        bounceHorizontally: Bool,
        bounceVertically: Bool,
        hasHorizontalScrollBar: Bool,
        hasVerticalScrollBar: Bool
    ) {
        try? bridge.setProperty(id: scrollView, key: "scrollH", value: hasHorizontalScrollBar ? "true" : "false")
        try? bridge.setProperty(id: scrollView, key: "scrollV", value: hasVerticalScrollBar ? "true" : "false")
    }
  
    public func destroyWidget(_ widget: Widget) {
        handlers.removeValue(forKey: widget)
        children.removeValue(forKey: widget)
        try? bridge.removeNode(id: widget)
    }

    /// Runs on a background Swift concurrency Task. Drains the Kotlin event queue
    /// and dispatches to the registered handler closures.
    ///
    /// The loop yields after each poll so it doesn't pin a thread when idle.
    /// When there are pending events it spins without yielding for low latency.
    private func startEventLoop() {
        eventLoopTask = Task.detached(priority: .userInitiated) { [weak self] in
            do {
                while !Task.isCancelled {
                    guard let self else { return }

                    var dispatched = 0

                    for _ in 0..<64 {
                        let json: String?
                        do {
                            json = try await MainActor.run { try self.bridge.pollEvent() }
                        } catch {
                            log("pollEvent error: \(error)")
                            break
                        }

                        guard let json, !json.isEmpty else { break }
                        log(json)

                        guard let event = IncomingEvent(json) else { continue }
                        await self.dispatch(event)
                        dispatched += 1
                    }

                    if dispatched == 0 {
                        try await Task.sleep(nanoseconds: 4_000_000)
                    }
                }
            } catch {
                // CancellationError from Task.sleep — just exit cleanly
            }
        }
    }

    @MainActor
    private func dispatch(_ event: IncomingEvent) {
        log("\(event)")
      
        // if event.type == "measured" {
        //     let parts = event.payload.split(separator: ",").compactMap { Int($0) }
        //     if parts.count == 2 {
        //         measuredSizes[event.id] = SIMD2(parts[0], parts[1])
        //     }
        //     return
        // }
      
        guard let h = handlers[event.id] else { return }
        switch event.type {
        case "click":
            h.onClick?()
        case "change":
            h.onChange?(event.payload)
        case "toggle":
            h.onToggle?(event.payload == "true")
        case "slide", "slideEnd":
            if let v = Double(event.payload) { h.onSlide?(v) }
        default:
            break
        }
    }
  
    public func setSizeLimits(
        ofWindow window: Window,
        minimum: SIMD2<Int>,
        maximum: SIMD2<Int>?
    ) {
        // Doesn't mean anything on Android until we support split screen
    }
  
    public func setSizeLimits(
        ofWindow window: Void,
        minimum minimumSize: SIMD2<Int>,
        maximum maximumSize: SIMD2<Int>?
    ) {}
  
    public func naturalSize(of widget: Widget) -> SIMD2<Int> {
        if let cached = measuredSizes[widget] {
            return SIMD2(min(cached.x, cachedWindowWidth), cached.y)
        }
        do {
            let result = try bridge.measureWidget(id: widget)
            if result.count >= 2, result[0] > 0 {
                let size = SIMD2(Int(result[0]), Int(result[1]))
                return SIMD2(min(size.x, cachedWindowWidth), size.y)
            }
        } catch {}
        return SIMD2(cachedWindowWidth, 0)
    }
  
    public func removeAllChildren(of container: Widget) {
        children[container] = []
        try? bridge.setChildren(parentId: container, childIds: [])
    }
  
    public func setSize(of widget: Widget, to size: SIMD2<Int>) {
        try? bridge.setProperty(id: widget, key: "width", value: "\(size.x)")
        try? bridge.setProperty(id: widget, key: "height", value: "\(size.y)")
    }
  
    public func size(
        of text: String,
        whenDisplayedIn widget: Widget,
        proposedWidth: Int?,
        proposedHeight: Int?,
        environment: EnvironmentValues
    ) -> SIMD2<Int> {
        let fontSize = Float(environment.resolvedFont.pointSize)
        let maxWidth = proposedWidth ?? 0
        if let result = try? bridge.measureText(text: text, fontSizeSp: fontSize, maxWidthDp: Int32(maxWidth)),
           result.count >= 2,
           result[0] > 20, result[1] > 4 {
            log("measureText: '\(text)' fontSize=\(fontSize) -> \(result[0])x\(result[1])")
            return SIMD2(Int(result[0]), Int(result[1]))
        }
        // fallback
        let charWidth = Int(Double(fontSize) * 0.6) + 1
        return SIMD2(text.count * charWidth, Int(fontSize) + 4)
    }
}
