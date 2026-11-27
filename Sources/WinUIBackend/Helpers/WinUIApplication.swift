import WinUI
import WinAppSDK
import Mutex
import Foundation

// swiftlint:disable force_try
class WinUIApplication: SwiftApplication, @unchecked Sendable {
    static let callback = Mutex<(@MainActor (WinUIApplication, AppInstance) -> Void)?>(nil)
    static let urlSchemes = Mutex<[String]>([])

    override func onLaunched(_ args: WinUI.LaunchActivatedEventArgs) {
        // Register the schemes on each launch. Windows ignores duplicate URL
        // scheme registrations so this is safe.
        let schemes = Self.urlSchemes.withLock { $0 }
        var processName = ProcessInfo.processInfo.processName
        if processName.hasSuffix(".exe") {
            processName = String(processName.dropLast(".exe".count))
        }
        for scheme in schemes {
            ActivationRegistrationManager.registerForProtocolActivation(
                scheme,
                "",
                processName,
                ""
            )
        }

        // Adapted from https://learn.microsoft.com/en-us/windows/apps/windows-app-sdk/applifecycle/applifecycle-single-instance
        let args = try! AppInstance.getCurrent().getActivatedEventArgs()!
        let keyInstance = AppInstance.findOrRegisterForKey(processName)!
        guard keyInstance.isCurrent else {
            Self.redirectActivation(args, to: keyInstance)
        }

        Self.callback.withLock { callback in
            // We can't explicitly hop to the main actor because we haven't set up
            // our WinUI MainActor fix yet.
            MainActor.assumeIsolated {
                callback?(self, keyInstance)
            }
        }
    }

    // Adapted from https://learn.microsoft.com/en-us/windows/apps/windows-app-sdk/applifecycle/applifecycle-single-instance
    static func redirectActivation(
        _ args: AppActivationArguments,
        to keyInstance: AppInstance
    ) -> Never {
        let semaphore = DispatchSemaphore(value: 0)
        let promise = try! keyInstance.redirectActivationToAsync(args)!
        promise.completed = { _, _ in
            semaphore.signal()
        }

        semaphore.wait()

        // Bring key instance to the foreground
        do {
            try InstancingHelpers.activateProcess(withId: Int(keyInstance.processId))
        } catch {
            print(
                """
                Failed to bring key instance (pid=\(keyInstance.processId)) to \
                foreground: \(error.localizedDescription)
                """
            )
        }
        Foundation.exit(0)
    }
}
