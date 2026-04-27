import Android
import Foundation
import SwiftCrossUI
import AndroidKit
import AndroidBackendShim

// Many force tries are required for the Android backend but we don't really want them
// anywhere else so just disable the lint rule at a file level.
// swiftlint:disable force_try

func log(_ message: String) {
    android_log(Int32(ANDROID_LOG_DEBUG.rawValue), "swift", message)
}

/// A valid AndroidBackend shim must call this to begin execution of the app.
/// Once initial setup and rendering is done, this function returns control
/// back to the JVM (by returning).
@MainActor
@_cdecl("AndroidBackend_entrypoint")
public func entrypoint(_ env: UnsafeMutablePointer<JNIEnv?>, _ object: jobject) {
    AndroidBackend.env = env

    let holder = JavaObjectHolder(object: object, environment: env)
    AndroidBackend.activity = Activity(javaHolder: holder)

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

    AndroidBackend.stdoutPipe.fileHandleForReading.readabilityHandler =
        makeMessageHandler(priority: ANDROID_LOG_INFO.rawValue)

    AndroidBackend.stderrPipe.fileHandleForReading.readabilityHandler =
        makeMessageHandler(priority: ANDROID_LOG_ERROR.rawValue)

    dup2(
        AndroidBackend.stdoutPipe.fileHandleForWriting.fileDescriptor,
        FileHandle.standardOutput.fileDescriptor
    )

    dup2(
        AndroidBackend.stderrPipe.fileHandleForWriting.fileDescriptor,
        FileHandle.standardError.fileDescriptor
    )

    // Pass dummy arguments to application main function
    let argv = UnsafeMutableBufferPointer<UnsafeMutablePointer<CChar>?>.allocate(capacity: 1)
    argv[0] = nil

    main(0, argv.baseAddress)
}

extension App {
    public typealias Backend = AndroidBackend

    public var backend: AndroidBackend {
        AndroidBackend()
    }
}

public final class AndroidBackend: AppBackend {
    public typealias Window = Void
    public typealias Widget = AndroidKit.View
    public typealias Menu = Never
    public typealias Alert = Never
    public typealias Path = Never
    public typealias Sheet = Never

    static let stdoutPipe = Pipe()
    static let stderrPipe = Pipe()

    // TODO(stackotter): Dynamically determine the device class
    public let deviceClass = DeviceClass.phone

    public let defaultTableRowContentHeight = 0
    public let defaultTableCellVerticalPadding = 0
    public let defaultPaddingAmount = 10
    public let scrollBarWidth = 0
    public let requiresToggleSwitchSpacer = false
    public let defaultToggleStyle = ToggleStyle.checkbox
    public let requiresImageUpdateOnScaleFactorChange = false
    public let menuImplementationStyle = MenuImplementationStyle.menuButton
    public let canRevealFiles = false
    public let supportsMultipleWindows = false
    public let supportedPickerStyles: [BackendPickerStyle] = []
    public let canOverrideWindowColorScheme = false
    public nonisolated let supportedDatePickerStyles: [DatePickerStyle] = [.automatic]

    /// A reference used to keep the tickler alive.
    var tickler: MainRunLoopTickler?

    /// The JNI environment pointer. Set by ``entrypoint``.
    static var env: UnsafeMutablePointer<JNIEnv?>!
    /// The main activity. Set by ``entrypoint``.
    static var activity: Activity!

    var helpers: AndroidBackendHelpers

    public init() {
        helpers = AndroidBackendHelpers(environment: Self.env)
    }

    public func runMainLoop(
        _ callback: @escaping @MainActor () -> Void
    ) {
        let tickler = MainRunLoopTickler(environment: Self.env)
        tickler.start()
        self.tickler = tickler

        // We just fall through to return control to Java when we're done
        // setting up the initial view hierarchy.
        callback()
    }

    public func createWindow(withDefaultSize defaultSize: SIMD2<Int>?) -> Window {
        // TODO(stackotter): Properly support multiple calls to createWindow
    }

    public func updateWindow(_ window: Window, environment: EnvironmentValues) {
        // TODO(stackotter): Update window theme?
    }

    public func setCloseHandler(ofWindow window: Window, to action: @escaping () -> Void) {
        // TODO(stackotter): Set close handler?
    }

    public func setTitle(ofWindow window: Window, to title: String) {
        // TODO(stackotter): Handle navigation titles.
    }

    public func setResizability(ofWindow window: Window, to resizable: Bool) {}

    public func setChild(ofWindow window: Window, to child: Widget) {
        Self.activity.setContentView(child)
    }

    public func size(ofWindow window: Window) -> SIMD2<Int> {
        let width = Int(helpers.getWindowWidth(Self.activity))
        let height = Int(helpers.getWindowHeight(Self.activity))
        return SIMD2(Int(width), Int(height))
    }

    public func isWindowProgrammaticallyResizable(_ window: Window) -> Bool {
        false
    }

    public func setSize(ofWindow window: Window, to newSize: SIMD2<Int>) {
        log("warning: Attempted to set size of Android window")
    }

    public func setSizeLimits(ofWindow window: Void, minimum minimumSize: SIMD2<Int>, maximum maximumSize: SIMD2<Int>?) {}

    public func setBehaviors(ofWindow window: Void, closable: Bool, minimizable: Bool, resizable: Bool) {}

    public func setResizeHandler(
        ofWindow window: Window,
        to action: @escaping (_ newSize: SIMD2<Int>) -> Void
    ) {
        // TODO(stackotter): Handle orientation changes and other changes such
        //   as density changes
    }

    public func show(window: Window) {
        log("Show window")
    }

    public func activate(window: Window) {}

    public func setApplicationMenu(
        _ submenus: [ResolvedMenu.Submenu],
        environment: EnvironmentValues
    ) {
        // TODO(stackotter): Register app menu items as shortcuts when we support keyboard
        //   shortcuts.
    }

    public func setIncomingURLHandler(to action: @escaping (Foundation.URL) -> Void) {
        // TODO(stackotter): Handle incoming URLs
    }

    public func runInMainThread(action: @escaping @MainActor () -> Void) {
        Task { @MainActor in
            action()
        }
    }

    public func computeRootEnvironment(defaultEnvironment: EnvironmentValues) -> EnvironmentValues {
        // TODO(stackotter): React to system theme
        defaultEnvironment
    }

    public func setRootEnvironmentChangeHandler(to action: @escaping @Sendable @MainActor () -> Void) {
        // TODO(stackotter): Listen for system theme changes
    }

    public func computeWindowEnvironment(
        window: Window,
        rootEnvironment: EnvironmentValues
    ) -> EnvironmentValues {
        // TODO(stackotter): Figure out if we'll ever need window-specific environment
        //   changes. Probably don't unless Android apps can support
        //   multi-windowing when external displays are connected, in which
        //   case we may need to handle per-window pixel density.
        rootEnvironment
    }

    public func setWindowEnvironmentChangeHandler(
        of window: Window,
        to action: @escaping @Sendable @MainActor () -> Void
    ) {
        // TODO(stackotter): React to per-window environment changes. See
        //   computeWindowEnvironment
    }

    public func show(widget: Widget) {}

    public func createContainer() -> Widget {
        RelativeLayout(Self.activity, environment: Self.env)
            .as(AndroidKit.View.self)!
    }

    public func removeAllChildren(of container: Widget) {
        let container = container.as(ViewGroup.self)!
        container.removeAllViews()
    }

    public func insert(_ child: Widget, into container: Widget, at index: Int) {
        let container = container.as(ViewGroup.self)!
        container.addView(child, Int32(index))
    }

    public func setPosition(
        ofChildAt index: Int,
        in container: Widget,
        to position: SIMD2<Int>
    ) {
        let container = container.as(ViewGroup.self)!
        let child = container.getChildAt(Int32(index))!

        let layoutParams = child.getLayoutParams().as(RelativeLayout.LayoutParams.self)!
        layoutParams.leftMargin = Int32(position.x)
        layoutParams.topMargin = Int32(position.y)

        child.setLayoutParams(layoutParams.as(ViewGroup.LayoutParams.self))
    }

    public func remove(childAt index: Int, from container: Widget) {
        let container = container.as(RelativeLayout.self)!
        container.removeViewAt(Int32(index))
    }

    public func swap(childAt firstIndex: Int, withChildAt secondIndex: Int, in container: Widget) {
        let container = container.as(ViewGroup.self)!
        let largerIndex = Int32(max(firstIndex, secondIndex))
        let smallerIndex = Int32(min(firstIndex, secondIndex))
        let view1 = container.getChildAt(smallerIndex)
        let view2 = container.getChildAt(largerIndex)
        container.removeViewAt(largerIndex)
        container.removeViewAt(smallerIndex)
        container.addView(view2, smallerIndex)
        container.addView(view1, largerIndex)
    }

    public func naturalSize(of widget: Widget) -> SIMD2<Int> {
        let measureSpecClass = try! JavaClass<AndroidKit.View.MeasureSpec>(
            environment: Self.env
        )
        widget.measure(
            measureSpecClass.UNSPECIFIED,
            measureSpecClass.UNSPECIFIED
        )
        let width = widget.getMeasuredWidth()
        let height = widget.getMeasuredHeight()
        return SIMD2(Int(width), Int(height))
    }

    public func setSize(of widget: Widget, to size: SIMD2<Int>) {
        let layoutParams = widget.getLayoutParams()!
        layoutParams.width = Int32(size.x)
        layoutParams.height = Int32(size.y)
        widget.setLayoutParams(layoutParams)

        // TODO(stackotter): Use density-adaptive units everywhere
    }

    public func createButton() -> Widget {
        AndroidKit.Button(Self.activity, environment: Self.env)
            .as(AndroidKit.View.self)!
    }

    /// Converts a Swift String to a Java CharSequence.
    private func charSequence(from string: String) -> CharSequence {
        let jstring = JavaString(string, environment: Self.env)
        return jstring.as(CharSequence.self)!
    }

    public func updateButton(
        _ button: Widget,
        label: String,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        // TODO(stackotter): Handle environment.
        let button = button.as(AndroidKit.Button.self)!
        button.setText(charSequence(from: label))
        let listener = ViewOnClickListener(action: action, environment: Self.env)
        button.setOnClickListener(listener.as(AndroidView.View.OnClickListener.self))
    }

    public func createTextField() -> Widget {
        CustomEditText(activity: Self.activity, environment: Self.env)
            .as(AndroidKit.View.self)!
    }

    public func updateTextField(
        _ textField: Widget,
        placeholder: String,
        environment: EnvironmentValues,
        onChange: @escaping (String) -> Void,
        onSubmit: @escaping () -> Void
    ) {
        // TODO(stackotter): Handle environment
        let textField = textField.as(CustomEditText.self)!
        textField.as(AndroidKit.TextView.self)!.setHint(charSequence(from: placeholder))
        textField.setOnChange(
            SwiftAction(environment: Self.env) {
                // Don't take textField as a weak reference, because otherwise it
                // gets dropped immediately (it's not actually held anywhere; it's
                // just a wrapper around a Java class instance). This doesn't cause
                // a reference cycle because textField doesn't hold the SwiftAction,
                // (Java does).
                let content = textField.as(AndroidKit.TextView.self)!.getText().toString()
                onChange(content)
            }
        )
        textField.setOnSubmit(SwiftAction(environment: Self.env, action: onSubmit))
    }

    public func setContent(ofTextField textField: Widget, to content: String) {
        let textField = textField.as(AndroidKit.TextView.self)!
        textField.setText(charSequence(from: content))
    }

    public func getContent(ofTextField textField: Widget) -> String {
        let textField = textField.as(AndroidKit.TextView.self)!
        return textField.getText().toString()
    }

    public func createTextView() -> Widget {
        AndroidKit.TextView(Self.activity, environment: Self.env)
            .as(AndroidKit.View.self)!
    }

    public func updateTextView(
        _ textView: Widget,
        content: String,
        environment: EnvironmentValues
    ) {
        let textView = textView.as(AndroidKit.TextView.self)!
        let content = JavaString(content, environment: Self.env)
        textView.setText(content.as(CharSequence.self))
        // TODO: Handle environment
    }

    public func size(
        of text: String,
        whenDisplayedIn widget: Widget,
        proposedWidth: Int?,
        proposedHeight: Int?,
        environment: EnvironmentValues
    ) -> SIMD2<Int> {
        let widget = createTextView()
        updateTextView(widget, content: text, environment: environment)
        widget.measure(
            proposedWidth.map(Int32.init) ?? Int32.max,
            proposedHeight.map(Int32.init) ?? Int32.max
        )
        let width = widget.getMeasuredWidth()
        let height = widget.getMeasuredHeight()
        return SIMD2(Int(width), Int(height))
    }
}
