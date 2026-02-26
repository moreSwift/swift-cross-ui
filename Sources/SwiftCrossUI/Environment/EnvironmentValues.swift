import Foundation

/// The environment used when constructing scenes and views. Each scene or view
/// gets to modify the environment before passing it on to its children, which
/// is the basis of many view modifiers.
public struct EnvironmentValues {
    /// A font resolution context derived from the current environment.
    ///
    /// Essentially just a subset of the environment.
    @MainActor
    public var fontResolutionContext: Font.Context {
        Font.Context(
            overlay: fontOverlay,
            deviceClass: backend.deviceClass,
            resolveTextStyle: { backend.resolveTextStyle($0) }
        )
    }

    /// The current font resolved to a form suitable for rendering. Just a
    /// helper method for our own backends. We haven't made this public because
    /// it would be weird to have two pretty equivalent ways of resolving fonts.
    @MainActor
    package var resolvedFont: Font.Resolved {
        font.resolve(in: fontResolutionContext)
    }

    /// The suggested foreground color for backends to use. Backends don't
    /// neccessarily have to obey this when ``Environment/foregroundColor``
    /// is `nil`.
    public var suggestedForegroundColor: Color {
        foregroundColor ?? colorScheme.defaultForegroundColor
    }

    /// Called by view graph nodes when they resize due to an internal state
    /// change and end up changing size. Each view graph node sets its own
    /// handler when passing the environment on to its children, setting up
    /// a bottom-up update chain up which resize events can propagate.
    var onResize: @MainActor (_ newSize: ViewSize) -> Void

    /// The app storage provider to use for `@AppStorage` property wrappers.
    public let appStorageProvider: any AppStorageProvider

    /// Backing storage for extensible subscript
    private var values: [ObjectIdentifier: Any]

    /// An internal environment value used to control whether layout caching is
    /// enabled or not. This is set to true when computing non-final layouts. E.g.
    /// when a stack computes the minimum and maximum sizes of its children, it
    /// should enable layout caching because those updates are guaranteed to be
    /// non-final. The reason that we can't cache on non-final updates is that
    /// the last layout proposal received by each view must be its intended final
    /// proposal.
    var allowLayoutCaching: Bool = false

    /// Backing storage for observable subscript
    private var observableObjects: [ObjectIdentifier: any ObservableObject]

    public subscript<T: EnvironmentKey>(_ key: T.Type) -> T.Value {
        get {
            values[ObjectIdentifier(T.self), default: T.defaultValue] as! T.Value
        }
        set {
            values[ObjectIdentifier(T.self)] = newValue
        }
    }

    public subscript<T: ObservableObject>(observable key: T.Type) -> T? {
        get {
            guard let value = observableObjects[ObjectIdentifier(T.self)] as? T? else {
                let message =
                    "EnvironmentValues type mismatch: value for key '\(T.self).self' doesn't match expected type '\(T.self)'"
                logger.critical("\(message)")
                fatalError(message)
            }
            return value
        }
        set {
            observableObjects[ObjectIdentifier(T.self)] = newValue
        }
    }

    /// Brings the current window forward, not guaranteed to always bring
    /// the window to the top (due to focus stealing prevention).
    @MainActor
    func bringWindowForward() {
        func activate<Backend: AppBackend>(with backend: Backend) {
            backend.activate(window: window as! Backend.Window)
        }
        activate(with: backend)
        logger.info("window activated")
    }

    /// The backend in use. Mustn't change throughout the app's lifecycle.
    let backend: any AppBackend

    /// Presents an 'Open file' dialog fit for selecting a single file. Some
    /// backends only allow selecting either files or directories but not both
    /// in a single dialog. Returns `nil` if the user cancels the operation.
    /// Displays as a modal for the current window, or the entire app if
    /// accessed outside of a scene's view graph (in which case the backend
    /// can decide whether to make it an app modal, a standalone window, or a
    /// window of its choosing).
    @MainActor
    @available(tvOS, unavailable, message: "tvOS does not provide file system access")
    public var chooseFile: PresentSingleFileOpenDialogAction {
        PresentSingleFileOpenDialogAction(
            backend: backend,
            window: MainActorBox(value: window)
        )
    }

    /// Presents a 'Save file' dialog fit for selecting a save destination.
    /// Returns `nil` if the user cancels the operation. Displays as a modal
    /// for the current window, or the entire app if accessed outside of a
    /// scene's view graph (in which case the backend can decide whether to
    /// make it an app modal, a standalone window, or a modal for a window of
    /// its chooosing).
    @MainActor
    public var chooseFileSaveDestination: PresentFileSaveDialogAction {
        PresentFileSaveDialogAction(
            backend: backend,
            window: MainActorBox(value: window)
        )
    }

    /// Presents an alert for the current window, or the entire app if accessed
    /// outside of a scene's view graph (in which case the backend can decide
    /// whether to make it an app modal, a standalone window, or a modal for a
    /// window of its choosing).
    @MainActor
    public var presentAlert: PresentAlertAction {
        PresentAlertAction(environment: self)
    }

    /// Opens a URL with the default application. May present an application
    /// picker if multiple applications are registered for the given URL
    /// protocol.
    @MainActor
    public var openURL: OpenURLAction {
        OpenURLAction(backend: backend)
    }

    /// Opens a window with the specified ID.
    @MainActor
    public var openWindow: OpenWindowAction {
        OpenWindowAction(environment: self)
    }

    /// Closes the enclosing window.
    @MainActor
    public var dismissWindow: DismissWindowAction {
        DismissWindowAction(
            backend: backend,
            window: MainActorBox(value: window)
        )
    }

    /// Reveals a file in the system's file manager. This opens
    /// the file's enclosing directory and highlighting the file.
    ///
    /// `nil` on platforms that don't support revealing files, e.g.
    /// iOS.
    @MainActor
    public var revealFile: RevealFileAction? {
        RevealFileAction(backend: backend)
    }

    /// Whether the backend can have multiple windows open at once. Mobile
    /// backends generally can't.
    @MainActor
    public var supportsMultipleWindows: Bool {
        backend.supportsMultipleWindows
    }

    /// The display styles supported by ``DatePicker``. ``datePickerStyle`` must be one of these.
    public let supportedDatePickerStyles: [DatePickerStyle]

    /// Checks whether a picker style is supported by the current backend.
    @MainActor
    public var isPickerStyleSupported: PickerSupportedAction {
        PickerSupportedAction(backend: backend)
    }

    /// Creates the default environment.
    package init<Backend: AppBackend>(
        backend: Backend,
        appStorageProvider: any AppStorageProvider = DefaultAppStorageProvider()
    ) {
        self.backend = backend
        self.appStorageProvider = appStorageProvider

        onResize = { _ in }
        values = [:]
        observableObjects = [:]

        let supportedDatePickerStyles = backend.supportedDatePickerStyles
        if supportedDatePickerStyles.isEmpty {
            self.supportedDatePickerStyles = [.automatic]
        } else {
            self.supportedDatePickerStyles = supportedDatePickerStyles
        }
    }

    /// Returns a copy of the environment with the specified property set to the
    /// provided new value.
    public func with<T>(_ keyPath: WritableKeyPath<Self, T>, _ newValue: T) -> Self {
        var environment = self
        environment[keyPath: keyPath] = newValue
        return environment
    }
}

extension EnvironmentValues {
    /// The current stack orientation. Inherited by ``ForEach`` and ``Group`` so
    /// that they can be used without affecting layout.
    @Entry public var layoutOrientation: Orientation = .vertical

    /// The current stack alignment. Inherited by ``ForEach`` and ``Group`` so
    /// that they can be used without affecting layout.
    @Entry public var layoutAlignment: StackAlignment = .center

    /// The current stack spacing. Inherited by ``ForEach`` and ``Group`` so
    /// that they can be used without affecting layout.
    @Entry public var layoutSpacing: Int = 10

    /// The current font.
    @Entry public var font: Font = .body

    /// A font overlay storing font modifications. If these conflict with the
    /// font's internal overlay, these win.
    ///
    /// We keep this separate overlay for modifiers because we want modifiers to
    /// be persisted even if the developer sets a custom font further down the
    /// view hierarchy.
    @Entry internal var fontOverlay = Font.Overlay()

    /// How lines should be aligned relative to each other when line wrapped.
    @Entry public var multilineTextAlignment: HorizontalAlignment = .leading

    /// The current color scheme of the current view scope.
    @Entry public var colorScheme: ColorScheme = .light

    /// The foreground color. `nil` means that the default foreground color of
    /// the current color scheme should be used.
    @Entry public var foregroundColor: Color?

    /// Called when a text field gets submitted (usually due to the user
    /// pressing Enter/Return).
    @Entry public var onSubmit: (@MainActor @Sendable () -> Void)?

    /// The scale factor of the current window.
    @Entry public var windowScaleFactor: Double = 1

    /// The type of input that text fields represent.
    ///
    /// This affects autocomplete suggestions, and on devices with no physical keyboard, which
    /// on-screen keyboard to use.
    ///
    /// Do not use this in place of validation, even if you only plan on supporting mobile
    /// devices, as this does not restrict copy-paste and many mobile devices support bluetooth
    /// keyboards.
    @Entry public var textContentType: TextContentType = .text

    /// The way that scrollable content interacts with the software keyboard.
    @Entry public var scrollDismissesKeyboardMode: ScrollDismissesKeyboardMode = .automatic

    /// The style of list to use.
    @Entry package var listStyle: ListStyle = .default

    /// The style of toggle to use.
    @Entry public var toggleStyle: ToggleStyle = .button

    /// Whether the text should be selectable. Set by ``View/textSelectionEnabled(_:)``.
    @Entry public var isTextSelectionEnabled: Bool = false

    /// The resizing behaviour of windows.
    ///
    /// Set by ``Window/windowResizability(_:)->Scene``.
    @Entry internal var windowResizability: WindowResizability = .automatic

    /// The default launch behavior of windows.
    ///
    /// Set by ``Window/defaultLaunchBehavior(_:)->Scene``.
    @Entry internal var defaultLaunchBehavior: SceneLaunchBehavior = .automatic

    /// The default size of windows.
    ///
    /// Defaults to 900x450.
    ///
    /// Set by ``Window/defaultSize(width:height:)->Scene``.
    @Entry internal var defaultWindowSize: SIMD2<Int> = SIMD2(900, 450)

    /// The menu ordering to use.
    @Entry public var menuOrder: MenuOrder = .automatic

    /// Backing store for ``EnvironmentValues/openWindowFunctionsByID``.
    /// Used to resolve "non-sendable type" warnings in Swift 5 and errors in Swift 6 language mode.
    @Entry private var openWindowFunctionsByIDStore = UncheckedSendable(
        wrappedValue: Box<[String: @MainActor () -> Void]>([:]))

    /// A mapping of window IDs to functions that open the corresponding windows.
    internal var openWindowFunctionsByID: Box<[String: @MainActor () -> Void]> {
        get {
            openWindowFunctionsByIDStore.wrappedValue
        }
        set {
            openWindowFunctionsByIDStore.wrappedValue = newValue
        }
    }

    /// Backing store for ``EnvironmentValues/window``.
    /// Used to resolve "non-sendable type" warnings in Swift 5 and errors in Swift 6 language mode.
    @Entry private var windowStore = UncheckedSendable<Any?>(wrappedValue: nil)

    /// The backend's representation of the window that the current view is
    /// in, if any. This is a very internal detail that should never get
    /// exposed to users.
    package var window: Any? {
        get {
            windowStore.wrappedValue
        }
        set {
            windowStore.wrappedValue = newValue
        }
    }

    /// Backing store for ``EnvironmentValues/sheet``.
    /// Used to resolve "non-sendable type" warnings in Swift 5 and errors in Swift 6 language mode.
    @Entry private var sheetStore = UncheckedSendable<Any?>(wrappedValue: nil)

    /// The backend's representation of the sheet that the current view is
    /// in, if any. This is a very internal detail that should never get
    /// exposed to users.
    package var sheet: Any? {
        get {
            sheetStore.wrappedValue
        }
        set {
            sheetStore.wrappedValue = newValue
        }
    }

    /// The current calendar that views should use when handling dates.
    @Entry public var calendar: Calendar = .current

    /// The current time zone that views should use when handling dates.
    @Entry public var timeZone: TimeZone = .current

    /// The display style used by ``Picker``.
    @Entry public var pickerStyle: any PickerStyle = .automatic

    /// The display style used by ``DatePicker``.
    @Entry public var datePickerStyle: DatePickerStyle = .automatic

    /// Whether user interaction is enabled. Set by ``View/disabled(_:)``.
    @Entry public var isEnabled: Bool = true
}

/// A key that can be used to extend the environment with new properties.
public protocol EnvironmentKey<Value> {
    /// The type of value the key can hold.
    associatedtype Value
    /// The default value for the key.
    static var defaultValue: Value { get }
}
