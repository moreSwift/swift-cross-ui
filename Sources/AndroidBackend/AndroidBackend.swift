import Android
import Foundation
import SwiftCrossUI
import AndroidKit
import AndroidBackendShim

func log(_ message: String) {
    // TODO: Figure out why this gives linker errors
    // __android_log_write(Int32(ANDROID_LOG_DEBUG.rawValue), "swift", message)
    print(message)
}

/// A valid AndroidBackend shim must call this to begin execution of the app.
/// Once initial setup and rendering is done, this function returns control
/// back to the JVM (by returning).
@MainActor
@_cdecl("dev_swiftcrossui_AndroidBackend_entrypoint")
public func entrypoint(_ env: UnsafeMutablePointer<JNIEnv?>, _ object: jobject) {
    let env = JNIEnvWrapper(env: env)
    AndroidBackend.env = env

    let holder = JavaObjectHolder(object: object, environment: env.env)
    AndroidBackend.activity = Activity(javaHolder: holder)

    main()
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

    let inputPipe = Pipe()

    public let deviceClass = DeviceClass.phone
    public let defaultTableRowContentHeight = 0
    public let defaultTableCellVerticalPadding = 0
    public let defaultPaddingAmount = 10
    public let scrollBarWidth = 0
    public let requiresToggleSwitchSpacer = false
    public let defaultToggleStyle = ToggleStyle.switch
    public let requiresImageUpdateOnScaleFactorChange = false
    public let menuImplementationStyle = MenuImplementationStyle.menuButton
    public let canRevealFiles = false
    public let supportsMultipleWindows = false
    public let supportedPickerStyles: [BackendPickerStyle] = []
    public let canOverrideWindowColorScheme = false
    public nonisolated let supportedDatePickerStyles: [DatePickerStyle] = [.automatic]

    /// The JNI environment. Set by ``entrypoint``.
    static var env: JNIEnvWrapper!
    /// The main activity. Set by ``entrypoint``.
    static var activity: Activity!

    public init() {
        // Source: https://phatbl.at/2019/01/08/intercepting-stdout-in-swift.html
        // TODO: Fix this once we can import __android_log_write again (from Android; gives a linker error atm)
        // inputPipe.fileHandleForReading.readabilityHandler = { fileHandle in
        //     let data = fileHandle.availableData
        //     guard let string = String(data: data, encoding: .utf8) else {
        //         return
        //     }

        //     // TODO: Figure out why this gives linker errors
        //     // __android_log_write(
        //     //     Int32(ANDROID_LOG_DEBUG.rawValue),
        //     //     "Swift.print",
        //     //     string
        //     // )
        // }

        dup2(
            inputPipe.fileHandleForWriting.fileDescriptor,
            FileHandle.standardOutput.fileDescriptor
        )
    }

    public func runMainLoop(
        _ callback: @escaping @MainActor () -> Void
    ) {
        // We just fall through to return control to Java when we're done
        // setting up the initial view hierarchy.
        callback()
    }

    public func createWindow(withDefaultSize defaultSize: SIMD2<Int>?) -> Window {
        // TODO: Find out whether Android has a window abstraction like UIKit does.
    }

    public func updateWindow(_ window: Window, environment: EnvironmentValues) {
        // TODO: Update window theme?
    }

    public func setCloseHandler(ofWindow window: Window, to action: @escaping () -> Void) {
        // TODO: Set close handler?
    }

    public func setTitle(ofWindow window: Window, to title: String) {
        // TODO: Handle navigation titles.
    }

    public func setResizability(ofWindow window: Window, to resizable: Bool) {}

    public func setChild(ofWindow window: Window, to child: Widget) {
        Self.activity.setContentView(child)
    }

    public func size(ofWindow window: Window) -> SIMD2<Int> {
        // let windowMetrics = Self.activity.getWindowManager().getCurrentWindowMetrics()
        // let insets = windowMetrics.getWindowInsets()
        //     .getInsetsIgnoringVisibility(JavaClass<WindowInsets.Type>())

        let activity = Self.activity.javaHolder.object!
        let cls = try! Self.env.getObjectClass(activity)
        let getWidthMethod = try! Self.env.getMethodID(cls, "getWindowWidth", "()I")
        let getHeightMethod = try! Self.env.getMethodID(cls, "getWindowHeight", "()I")
        let width = Self.env.callIntMethod(activity, getWidthMethod, [])
        let height = Self.env.callIntMethod(activity, getHeightMethod, [])
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
    ) {}

    public func show(window: Window) {}

    public func activate(window: Window) {}

    public func setApplicationMenu(
        _ submenus: [ResolvedMenu.Submenu],
        environment: EnvironmentValues
    ) {
        // TODO: Register app menu items as shortcuts when we support keyboard
        //   shortcuts.
    }

    public func setIncomingURLHandler(to action: @escaping (Foundation.URL) -> Void) {
        // TODO: Handle incoming URLs
    }

    public func runInMainThread(action: @escaping @MainActor () -> Void) {
        // TODO: Jump to the right thread
        Task { @MainActor in
            action()
        }
    }

    public func computeRootEnvironment(defaultEnvironment: EnvironmentValues) -> EnvironmentValues {
        // TODO: React to system theme
        defaultEnvironment
    }

    public func setRootEnvironmentChangeHandler(to action: @escaping @Sendable @MainActor () -> Void) {
        // TODO: Listen for system theme changes
    }

    public func computeWindowEnvironment(
        window: Window,
        rootEnvironment: EnvironmentValues
    ) -> EnvironmentValues {
        // TODO: Figure out if we'll ever need window-specific environment
        //   changes. Probably don't unless Android apps can support
        //   multi-windowing when external displays are connected, in which
        //   case we may need to handle per-window pixel density.
        rootEnvironment
    }

    public func setWindowEnvironmentChangeHandler(
        of window: Window,
        to action: @escaping @Sendable @MainActor () -> Void
    ) {
        // TODO: React to per-window environment changes. See
        //   computeWindowEnvironment
    }

    public func show(widget: Widget) {}

    public func createContainer() -> Widget {
        RelativeLayout(Self.activity, environment: Self.env.env)
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
            environment: Self.env.env
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
    }

    public func createButton() -> Widget {
        AndroidKit.Button(Self.activity, environment: Self.env.env)
            .as(AndroidKit.View.self)!
    }

    public func updateButton(
        _ button: Widget,
        label: String,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        let button = button.as(AndroidKit.Button.self)!
        let label = JavaString(label, environment: Self.env.env)
        button.setText(label.as(CharSequence.self))
        // TODO: Handle environment. Set callback.
    }

    public func createTextView() -> Widget {
        AndroidKit.TextView(Self.activity, environment: Self.env.env)
            .as(AndroidKit.View.self)!
    }

    public func updateTextView(
        _ textView: Widget,
        content: String,
        environment: EnvironmentValues
    ) {
        let textView = textView.as(AndroidKit.TextView.self)!
        let content = JavaString(content, environment: Self.env.env)
        textView.setText(content.as(CharSequence.self))
        // TODO: Handle environment
    }

    public func size(
        of text: String,
        whenDisplayedIn textView: Widget,
        proposedFrame: SIMD2<Int>?,
        environment: EnvironmentValues
    ) -> SIMD2<Int> {
        // let widget = createTextView()
        // updateTextView(widget, content: text, environment: environment)
        // setSize(of: widget, to: proposedFrame ?? SIMD2(10000, 10000))
        // let cls = try! Self.env.findClass("android/view/View")
        // let measureMethod = try! Self.env.getMethodID(cls, "measure", "(II)V")
        // let getWidth = try! Self.env.getMethodID(cls, "getMeasuredWidth", "()I")
        // let getHeight = try! Self.env.getMethodID(cls, "getMeasuredHeight", "()I")
        // var zero = jvalue()
        // zero.i = 0
        // Self.env.callVoidMethod(cls, measureMethod, [zero, zero])
        // let width = Self.env.callIntMethod(cls, getWidth, [])
        // let height = Self.env.callIntMethod(cls, getHeight, [])
        // return SIMD2(Int(width), Int(height))
        [100, 100]
    }
}
