import SwiftCrossUI
import UIKit

public final class UIKitBackend: AppBackend {
    static var onBecomeActive: (() -> Void)?
    static var onReceiveURL: ((URL) -> Void)?
    static var queuedURLs: [URL] = []

    /// The first window to get created.
    static var mainWindow: UIWindow?
    static var hasReturnedAWindow = false

    public let scrollBarWidth = 0
    public let defaultPaddingAmount = 15
    public let requiresToggleSwitchSpacer = true
    public let menuImplementationStyle = MenuImplementationStyle.menuButton

    // TODO: When tables are supported, update these
    public let defaultTableRowContentHeight = -1
    public let defaultTableCellVerticalPadding = -1

    public let requiresImageUpdateOnScaleFactorChange = false

    public let canRevealFiles = false

    public var deviceClass: DeviceClass {
        switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                .phone
            case .pad:
                .tablet
            case .tv:
                .tv
            case .mac:
                .desktop
            case .unspecified, .carPlay:
                // Seems like the safest fallback for now given that we don't
                // explicitly support these devices.
                .tablet
            @unknown default:
                .tablet
        }
    }

    var onTraitCollectionChange: (() -> Void)?

    private let appDelegateClass: ApplicationDelegate.Type

    public init() {
        self.appDelegateClass = ApplicationDelegate.self
    }

    public init(appDelegateClass: ApplicationDelegate.Type) {
        self.appDelegateClass = appDelegateClass
    }

    public func runMainLoop(
        _ callback: @escaping @MainActor () -> Void
    ) {
        Self.onReceiveURL = { url in
            Self.queuedURLs.append(url)
        }
        Self.onBecomeActive = callback
        UIApplicationMain(
            CommandLine.argc,
            CommandLine.unsafeArgv,
            NSStringFromClass(UIApplication.self),
            NSStringFromClass(appDelegateClass)
        )
    }

    public func setIncomingURLHandler(to action: @escaping (URL) -> Void) {
        // If the app wasn't already open, URLs can arrive before the view graph
        // gets a chance to register a handler. To fix this we store any early
        // URLs and replay them when the register gets added.
        runInMainThread {
            for url in Self.queuedURLs {
                action(url)
            }
            Self.queuedURLs = []
        }

        Self.onReceiveURL = action
    }
    
    
    // MARK: TODO - Fixup this to be compatible with iOS 6, somehow
    public func computeRootEnvironment(defaultEnvironment: EnvironmentValues) -> EnvironmentValues {
        var environment = defaultEnvironment

        environment.toggleStyle = .switch
        
        
        if #available(iOS 13.0, *) {
            switch UITraitCollection.current.userInterfaceStyle {
            case .light:
                environment.colorScheme = .light
            case .dark:
                environment.colorScheme = .dark
            default:
                break
            }
        } else {
            //Default to light on all other platforms
            environment.colorScheme = .light
        }

        return environment
    }

    public func setRootEnvironmentChangeHandler(to action: @escaping () -> Void) {
        onTraitCollectionChange = action
    }

    public func computeWindowEnvironment(
        window: Window,
        rootEnvironment: EnvironmentValues
    ) -> EnvironmentValues {
        // TODO: Record window scale factor in here
        rootEnvironment
    }

    public func setWindowEnvironmentChangeHandler(
        of window: Window,
        to action: @escaping () -> Void
    ) {
        // TODO: Notify when window scale factor changes
    }

    public func runInMainThread(action: @escaping @MainActor () -> Void) {
        DispatchQueue.main.async(execute: action)
    }

    public func show(widget: Widget) {
    }
    
    @available(iOS 13, *)
    public func openExternalURL(_ url: URL) throws {
        UIApplication.shared.open(url)
    }
}

extension App {
    public typealias Backend = UIKitBackend

    public var backend: UIKitBackend {
        UIKitBackend()
    }
}

/// The root class for application delegates of SwiftCrossUI apps.
///
/// In order to use a custom application delegate, pass your class to ``UIKitBackend/init(appDelegateClass:)``:
///
/// ```swift
/// import SwiftCrossUI
/// import UIKitBackend
///
/// class MyAppDelegate: ApplicationDelegate {
///     // UIApplicationDelegate methods here
/// }
///
/// @main
/// struct SwiftCrossUI_TestApp: App {
///     var backend: UIKitBackend {
///         UIKitBackend(appDelegateClass: MyAppDelegate.self)
///     }
///
///     var body: some Scene {
///         WindowGroup {
///             // View code here
///         }
///     }
/// }
/// ```
open class ApplicationDelegate: UIResponder, UIApplicationDelegate {
    public var window: UIWindow? {
        get {
            UIKitBackend.mainWindow
        }
        set {
            UIKitBackend.mainWindow = newValue
        }
    }

    var menu: [ResolvedMenu.Submenu] = []

    public required override init() {
        super.init()
    }

    /// Tells the delegate that the app has become active.
    ///
    /// - Important: If you override this method in a subclass, you must call
    /// `super.applicationDidBecomeActive(application)` as the first step of your
    /// implementation.
    open func applicationDidBecomeActive(_ application: UIApplication) {
        UIKitBackend.onBecomeActive?()

        // We only want to notify the first time. Otherwise the app's view
        // graph gets regenerated every time the app gets foregrounded,
        // causing very strange results.
        UIKitBackend.onBecomeActive = nil
    }

    /// Tells the delegate that the launch process is almost done and the app is almost ready
    /// to run.
    ///
    /// If you override this method in a subclass, you should call
    /// `super.application(application, didFinishLaunchingWithOptions: launchOptions)`
    /// at some point in your implementation. You do not necessarily have to return the same
    /// value as this `super` call.
    open func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if let onReceiveURL = UIKitBackend.onReceiveURL,
            let url = launchOptions?[.url] as? URL
        {
            onReceiveURL(url)
        }

        return true
    }

    /// Asks the delegate to open a resource specified by a URL, and provides a dictionary of launch options.
    ///
    /// If you override this method in a subclass, you should call
    /// `super.application(app, open: url, options: options` at some point in your
    /// implementation. You do not necessarily have to return the same value as this `super`
    /// call.
    open func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        if let onReceiveURL = UIKitBackend.onReceiveURL {
            onReceiveURL(url)
        }

        return true
    }

    /// Map a menu's label to its identifier.
    ///
    /// The commands API only gives control over the label of each menu. Override this method if
    /// you also need to control the menus' identifiers.
    ///
    /// This method is only used on Mac Catalyst.
    @available(iOS 13, *)
    open func mapMenuIdentifier(_ label: String) -> UIMenu.Identifier {
        switch label {
            case "File": .file
            case "Edit": .edit
            case "View": .view
            case "Window": .window
            case "Help": .help
            default:
                if let bundleId = Bundle.main.bundleIdentifier {
                    .init(rawValue: "\(bundleId).\(label)")
                } else {
                    .init(rawValue: label)
                }
        }
    }

    /// Asks the receiving responder to add and remove items from a menu system.
    ///
    /// When targeting Mac Catalyst, you should call `super.buildMenu(with: builder)` at some
    /// point in your implementation. If you do not, then calls to
    /// ``SwiftCrossUI/Scene/commands(_:)`` will have no effect.
    @available(iOS 13, *)
    open override func buildMenu(with builder: any UIMenuBuilder) {
        guard #available(tvOS 14, *),
            builder.system == .main
        else { return }

        for submenu in menu {
            let menuIdentifier = mapMenuIdentifier(submenu.label)
            let menu = UIKitBackend.buildMenu(
                content: submenu.content, label: submenu.label, identifier: menuIdentifier)

            if builder.menu(for: menuIdentifier) == nil {
                builder.insertChild(menu, atEndOfMenu: .root)
            } else {
                builder.replace(menu: menuIdentifier, with: menu)
            }
        }
    }
}

/// The root class for scene delegates of SwiftCrossUI apps.
///
/// SwiftCrossUI apps do not have to be scene-based. If you are writing a scene-based app,
/// derive your scene delegate from this class.
@available(iOS 13, *)
open class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    public var window: UIWindow? {
        willSet {
            UIKitBackend.mainWindow = newValue
        }
    }

    /// Tells the delegate about the addition of a scene to the app.
    ///
    /// - Important: If you override this method in a subclass, you must call
    /// `super.scene(scene, willConnectTo: session, options: connectionOptions)`
    /// at some point in your implementation.
    open func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        UIKitBackend.onBecomeActive?()

        // We only want to notify the first time. Otherwise the app's view
        // graph gets regenerated every time the app gets foregrounded,
        // causing very strange results.
        UIKitBackend.onBecomeActive = nil

        if let onReceiveURL = UIKitBackend.onReceiveURL,
            let url = connectionOptions.userActivities.first?.webpageURL
        {
            onReceiveURL(url)
        }
    }

    open func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if let onReceiveURL = UIKitBackend.onReceiveURL,
            let url = userActivity.webpageURL
        {
            onReceiveURL(url)
        }
    }
}
