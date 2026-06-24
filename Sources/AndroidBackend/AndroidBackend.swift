import Android
import Foundation
import SwiftCrossUI
import AndroidKit
import AndroidGraphics
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

extension EnvironmentValues {
    @Entry public var androidActivity: AndroidKit.Activity! = nil
    @Entry public var jniEnv: UnsafeMutablePointer<JNIEnv?>? = nil
}

// TODO: Implement the rest of `BaseAppBackend` so we can move off of `BaseStubs`

public final class AndroidBackend: BackendFeatures.BaseStubs {
    public final class Window {
        var content: Widget?
    }

    public typealias Widget = AndroidKit.View

    static let stdoutPipe = Pipe()
    static let stderrPipe = Pipe()

    public lazy var deviceClass: DeviceClass =
        switch helpers.getDeviceClass(Self.activity) {
            case 0: .desktop
            case 1: .phone
            case 2: .tablet
            case 3: .tv
            case 4: .watch
            case let x: fatalError("helpers.getDeviceClass returned unexpected value \(x)")
        }

    public let defaultPaddingAmount = 10
    public let supportsMultipleWindows = false
    public let canOverrideWindowColorScheme = false
    public let restoresWindowFrames = false

    static var fileDialogCallback: (([Foundation.URL]) -> Void)?
    static var folderDialogCallback: ((Foundation.URL?) -> Void)?

    /// A reference used to keep the tickler alive.
    var tickler: MainRunLoopTickler?

    /// The JNI environment pointer. Set by ``entrypoint``.
    static var env: UnsafeMutablePointer<JNIEnv?>!
    /// The main activity. Set by ``entrypoint``.
    static var activity: Activity!

    var helpers: AndroidBackendHelpers

    public init() {
        helpers = AndroidBackendHelpers(environment: Self.env)

        let fragmentActivity = Self.activity.as(FragmentActivity.self)!

        let filesCallback = FilesActivityCallback(environment: Self.env)
        let filesAction = SwiftAction(environment: Self.env) {
            let urls = filesCallback.getUrlStrings()
            AndroidBackend.fileDialogCallback?(urls.map {
                guard let url = Foundation.URL(string: $0) else {
                    fatalError("Failed to convert Uri to Foundation.URL: \($0)")
                }
                return url
            })
            AndroidBackend.fileDialogCallback = nil
        }
        filesCallback.setAction(filesAction)

        let folderCallback = FolderActivityCallback(environment: Self.env)
        let folderAction = SwiftAction(environment: Self.env) {
            let url = folderCallback.getUrlString()?.toString()
            AndroidBackend.folderDialogCallback?(url.map {
                guard let url = Foundation.URL(string: $0) else {
                    fatalError("Failed to convert Uri to Foundation.URL: \($0)")
                }
                return url
            })
            AndroidBackend.folderDialogCallback = nil
        }
        folderCallback.setAction(folderAction)

        helpers.registerActivityResults(fragmentActivity, filesCallback, folderCallback)
    }

    public convenience init(delegate: any ActivityDelegate) {
        self.init()

        let delegateObject = SwiftObject(delegate, environment: Self.env)
        let castedActivity = Self.activity.as(FragmentActivity.self)!

        // ActivityListener.init connects it to the Activity, which keeps it alive without Swift
        // needing to keep any references to it.
        _ = ActivityListener(castedActivity, delegateObject, environment: Self.env)

        delegate.onCreate(of: castedActivity, env: Self.env)
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

    public func createWindow(withDefaultSize defaultSize: SIMD2<Int>?, id: String) -> Window {
        // TODO(stackotter): Properly support multiple calls to createWindow
        return Window()
    }

    public func updateWindow(_ window: Window, environment: EnvironmentValues) {
        // TODO(stackotter): Update window theme?
        updateInsets(ofWindow: window)
    }

    public func setSizeLimits(
        ofWindow window: Window,
        minimum: SIMD2<Int>,
        maximum: SIMD2<Int>?
    ) {
        // Doesn't mean anything on Android until we support split screen
    }

    //    public func setCloseHandler(ofWindow window: Window, to action: @escaping () -> Void) {
    //        // TODO(stackotter): Set close handler?
    //    }

    public func setTitle(ofWindow window: Window, to title: String) {
        // TODO(stackotter): Handle navigation titles.
    }

    public func setResizability(ofWindow window: Window, to resizable: Bool) {}

    public func setChild(ofWindow window: Window, to child: Widget) {
        let container = createContainer()
        insert(child, into: container, at: 0)
        Self.activity.setContentView(container)
        window.content = container
        updateInsets(ofWindow: window)
    }

    private func updateInsets(ofWindow window: Window) {
        guard let container = window.content else {
            logger.warning("Attempted to update insets of window without content")
            return
        }

        let matchParent = try! JavaClass<AndroidKit.ViewGroup.LayoutParams>().MATCH_PARENT

        let leftInset = Int(helpers.getSafeAreaLeftInset(Self.activity))
        let topInset = Int(helpers.getSafeAreaTopInset(Self.activity))
        let fullWindowSize = SIMD2(Int(matchParent), Int(matchParent))
        setSize(of: container, to: fullWindowSize)
        setPosition(ofChildAt: 0, in: container, to: SIMD2(leftInset, topInset))

        let safeWindowSize = size(ofWindow: window)
        let child = container.as(CustomContainer.self)!.getChildAt(0)!
        setSize(of: child, to: safeWindowSize)
    }

    public func size(ofWindow window: Window) -> SIMD2<Int> {
        let width = Int(helpers.getSafeWindowWidth(Self.activity))
        let height = Int(helpers.getSafeWindowHeight(Self.activity))
        return SIMD2(Int(width), Int(height))
    }

    public func isWindowProgrammaticallyResizable(_ window: Window) -> Bool {
        false
    }

    public func setSize(ofWindow window: Window, to newSize: SIMD2<Int>) {
        log("warning: Attempted to set size of Android window")
    }

    public func setSizeLimits(
        ofWindow window: Void,
        minimum minimumSize: SIMD2<Int>,
        maximum maximumSize: SIMD2<Int>?
    ) {}

    //    public func setBehaviors(ofWindow window: Void, closable: Bool, minimizable: Bool, resizable: Bool) {}

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

    //    public func setApplicationMenu(
    //        _ submenus: [ResolvedMenu.Submenu],
    //        environment: EnvironmentValues
    //    ) {
    //        // TODO(stackotter): Register app menu items as shortcuts when we support keyboard
    //        //   shortcuts.
    //    }

    //    public func setIncomingURLHandler(to action: @escaping (Foundation.URL) -> Void) {
    //        // TODO(stackotter): Handle incoming URLs
    //    }

    public func runInMainThread(action: @escaping @MainActor () -> Void) {
        Task { @MainActor in
            action()
        }
    }

    public func computeRootEnvironment(defaultEnvironment: EnvironmentValues) -> EnvironmentValues {
        var environment = defaultEnvironment

        environment.androidActivity = Self.activity
        environment.jniEnv = Self.env

        if helpers.isNightMode(Self.activity) {
            environment.colorScheme = .dark
        } else {
            environment.colorScheme = .light
        }

        environment.isCircularScreen = Self.activity
            .getResources()
            .getConfiguration()
            .isScreenRound()

        if let identifier = helpers.getTimeZoneIdentifier()?.toString(),
           let timeZone = Foundation.TimeZone(identifier: identifier)
        {
            environment.timeZone = timeZone
            environment.calendar = getCurrentCalendar(timeZone: timeZone)
        } else {
            environment.calendar = getCurrentCalendar(timeZone: nil)
        }

        environment
            .appStorageProvider = SharedPreferencesAppStorageProvider(activity: Self.activity)

        return environment
    }

    public func setRootEnvironmentChangeHandler(
        to action: @escaping @Sendable @MainActor () -> Void
    ) {
        // TODO(stackotter): Listen for system theme changes
        // and call helpers.clearTextSizeCache()
    }

    public func computeWindowEnvironment(
        window: Window,
        rootEnvironment: EnvironmentValues
    ) -> EnvironmentValues {
        var environment = rootEnvironment
        environment
            .windowScaleFactor = Double(window.content!.getResources().getDisplayMetrics().density)
        return environment
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
        CustomContainer(Self.activity, environment: Self.env)
            .as(AndroidKit.View.self)!
    }

    public func removeAllChildren(of container: Widget) {
        let container = container.as(CustomContainer.self)!
        container.removeAllViews()
    }

    public func insert(_ child: Widget, into container: Widget, at index: Int) {
        let container = container.as(CustomContainer.self)!
        container.addView(child, Int32(index))
    }

    public func setPosition(
        ofChildAt index: Int,
        in container: Widget,
        to position: SIMD2<Int>
    ) {
        let density = container.getResources().getDisplayMetrics().density

        let container = container.as(CustomContainer.self)!
        let child = container.getChildAt(Int32(index))!

        let layoutParams = child.getLayoutParams().as(CustomContainer.LayoutParams.self)!
        layoutParams.setX(Int32(Float(position.x) * density))
        layoutParams.setY(Int32(Float(position.y) * density))

        child.setLayoutParams(layoutParams.as(ViewGroup.LayoutParams.self))
    }

    public func remove(childAt index: Int, from container: Widget) {
        let container = container.as(CustomContainer.self)!
        container.removeViewAt(Int32(index))
    }

    public func swap(childAt firstIndex: Int, withChildAt secondIndex: Int, in container: Widget) {
        let container = container.as(CustomContainer.self)!
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
        let density = widget.getResources().getDisplayMetrics().density

        let measureSpecClass = try! JavaClass<AndroidKit.View.MeasureSpec>(
            environment: Self.env
        )
        widget.measure(
            measureSpecClass.UNSPECIFIED,
            measureSpecClass.UNSPECIFIED
        )
        let width = Float(widget.getMeasuredWidth()) / density
        let height = Float(widget.getMeasuredHeight()) / density
        return SIMD2(Int(width.rounded(.up)), Int(height.rounded(.up)))
    }

    public func setSize(of widget: Widget, to size: SIMD2<Int>) {
        guard let layoutParams = widget.getLayoutParams() else { return }
        let density = widget.getResources().getDisplayMetrics().density
        layoutParams.width = Int32(Float(size.x) * density)
        layoutParams.height = Int32(Float(size.y) * density)
        widget.setLayoutParams(layoutParams)
    }

    public func createButton() -> Widget {
        AndroidKit.Button(Self.activity, environment: Self.env)
    }

    /// Converts a Swift String to a Java CharSequence.
    func charSequence(from string: String) -> CharSequence {
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

        getTextStyle(from: environment).apply(to: button)
    }

    public func createTextView() -> Widget {
        AndroidKit.TextView(Self.activity, environment: Self.env)
    }

    public func updateTextView(
        _ textView: Widget,
        content: String,
        environment: EnvironmentValues
    ) {
        let textView = textView.as(AndroidKit.TextView.self)!
        let content = JavaString(content, environment: Self.env)
        textView.setText(content.as(CharSequence.self))
        getTextStyle(from: environment).apply(to: textView)
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

        // 0x80000000 = View.MeasureSpec.AT_MOST
        // 0x3FFFFFFF = View.MeasureSpec.makeMeasureSpec(Int32.max, View.MeasureSpec.UNSPECIFIED)
        let widthSpec =
            if let proposedWidth {
                Int32(bitPattern: 0x80000000 |
                    UInt32(Double(proposedWidth) * environment.windowScaleFactor) & ~0x40000000)
            } else {
                0x3FFFFFFF as Int32
            }
        let heightSpec =
            if let proposedHeight {
                Int32(Double(proposedHeight) * environment.windowScaleFactor)
            } else {
                0x3FFFFFFF as Int32
            }

        widget.measure(widthSpec, heightSpec)
        let width = Double(widget.getMeasuredWidth()) / environment.windowScaleFactor
        let height = Double(widget.getMeasuredHeight()) / environment.windowScaleFactor
        return SIMD2(Int(width.rounded(.up)), Int(height.rounded(.up)))
    }
}
