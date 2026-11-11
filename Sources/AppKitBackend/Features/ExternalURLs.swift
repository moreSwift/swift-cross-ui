import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.ExternalURLs {
    public func openExternalURL(_ url: URL) throws {
        NSWorkspace.shared.open(url)
    }
}
