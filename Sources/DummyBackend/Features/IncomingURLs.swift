@_spi(Backends) import SwiftCrossUI
import Foundation

extension DummyBackend: BackendFeatures.IncomingURLs {
    public func setIncomingURLHandler(to action: @escaping (URL) -> Void) {
        incomingURLHandler = action
    }
}
