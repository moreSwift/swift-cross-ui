import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.IncomingURLs {
    public func setIncomingURLHandler(to action: @escaping (URL) -> Void) {
        appDelegate.onOpenURLs = { urls in
            for url in urls {
                action(url)
            }
        }
    }
}
