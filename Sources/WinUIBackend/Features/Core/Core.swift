@_spi(Backends) import SwiftCrossUI
import WinUI
import UWP
import WinSDK
import Foundation

extension WinUIBackend: BackendFeatures.Core {
    public var deviceClass: DeviceClass { .desktop }

    public convenience init() {
        self.init(urlSchemes: nil)
    }

    public static func earlySetup() {
        do {
            try Self.attachToParentConsole()
        } catch {
            // We essentially just ignore if this fails because it's just a QoL
            // debugging feature, and if it fails then any warning we print likely
            // won't get seen anyway. But I don't trust my Windows knowledge enough
            // to assert that it's impossible to view logs on failure, so let's
            // print a warning anyway.
            logger.warning(
                "failed to attach to parent console",
                metadata: ["error": "\(error)"]
            )
        }
    }

    public func runMainLoop(_ callback: @escaping @MainActor () -> Void) {
        do {
            try Self.attachToParentConsole()
        } catch {
            // We essentially just ignore if this fails because it's just a QoL
            // debugging feature, and if it fails then any warning we print likely
            // won't get seen anyway. But I don't trust my Windows knowledge enough
            // to assert that it's impossible to view logs on failure, so let's
            // print a warning anyway.
            logger.warning(
                "failed to attach to parent console",
                metadata: ["error": "\(error)"]
            )
        }

        // Ensure that the app's windows adapt to DPI changes at runtime
        SetThreadDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2)

        WinUIApplication.callback.withLock { launchCallback in
            launchCallback = { application, instance in
                // Toggle Switch has annoying default 'internal margins' (not Control
                // margins that we can set directly) that we can luckily get rid of by
                // overriding the relevant resource values.
                _ = application.resources.insert("ToggleSwitchPreContentMargin", 0.0 as Double)
                _ = application.resources.insert("ToggleSwitchPostContentMargin", 0.0 as Double)

                // Handle theme changes
                UWP.UISettings().colorValuesChanged.addHandler { _, _ in
                    Task { @MainActor in
                        self.rootEnvironmentChangeHandler?()
                    }
                }

                // TODO: Read in previously hardcoded values from the application's
                // resources dictionary for future-proofing. Example code for getting
                // property values;
                //   let iinspectable =
                //       application.resources.lookup("ToggleSwitchPreContentMargin")!
                //       as! WindowsFoundation.IInspectable
                //   let pv: __ABI_Windows_Foundation.IPropertyValue = try! iinspectable.QueryInterface()
                //   let value = try! pv.GetDoubleImpl()

                self.measurementTextBlock = (self.createTextView() as! TextBlock)

                instance.activated.addHandler { (_, args: AppActivationArguments?) in
                    guard let args else {
                        logger.warning("Received activation with no activation arguments?")
                        return
                    }
                    self.processActivationArguments(args)
                }

                callback()
            }
        }
        WinUIApplication.main()
    }

    public func runInMainThread(action: @escaping @MainActor () -> Void) {
        _ = try! dispatcherQueue!.tryEnqueue(.normal) {
            MainActor.assumeIsolated(action)
        }
    }
 
    public func computeRootEnvironment(
        defaultEnvironment: EnvironmentValues
    ) -> EnvironmentValues {
        // Source: https://learn.microsoft.com/en-us/windows/apps/desktop/modernize/ui/apply-windows-themes#know-when-dark-mode-is-enabled
        let backgroundColor = try! UWP.UISettings().getColorValue(.background)

        let green = Int(backgroundColor.g)
        let red = Int(backgroundColor.r)
        let blue = Int(backgroundColor.b)
        let isLight = 5 * green + 2 * red + blue > 8 * 128

        let locale = Foundation.Locale.windowsCurrent

        return defaultEnvironment
            .with(\.colorScheme, isLight ? .light : .dark)
            .with(\.appPhase, windows.contains(where: \.isActive) ? .active : .inactive)
            .with(\.locale, locale)
            .with(\.calendar, locale.calendar)
    }

    public func setRootEnvironmentChangeHandler(
        to action: @escaping @Sendable @MainActor () -> Void
    ) {
        self.rootEnvironmentChangeHandler = action
    }
}
