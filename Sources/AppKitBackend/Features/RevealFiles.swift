import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.RevealFiles {
    public func revealFile(_ url: URL) throws {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
}
