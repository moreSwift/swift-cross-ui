@_spi(Backends) import SwiftCrossUI

extension DummyBackend: BackendFeatures.WindowClosing {
    public func close(window: Window) {
        window.closeHandler?()
    }

    public func setCloseHandler(ofWindow window: Window, to action: @escaping () -> Void) {
        window.closeHandler = action
    }
}
