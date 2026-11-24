@_spi(Backends) import SwiftCrossUI
import WinUI

extension WinUIBackend: BackendFeatures.ExternalURLs {
    public func openExternalURL(_ url: URL) throws {
        let promise = UWP.Launcher.launchUriAsync(WindowsFoundation.Uri(url.absoluteString))!
        let semaphore = DispatchSemaphore(value: 0)
        promise.completed = { _, status in
            semaphore.signal()

            if status != .completed {
                logger.warning("Failed to open external URL \(url)")
            }
        }

        // Block until the URL has been launched
        semaphore.wait()
    }
}
