@_spi(Backends) import SwiftCrossUI

extension DummyBackend: BackendFeatures.WindowBehaviors {
    public func setBehaviors(
        ofWindow window: Window,
        closable: Bool,
        minimizable: Bool,
        resizable: Bool
    ) {
        window.closable = closable
        window.minimizable = minimizable
        window.resizable = resizable
    }
}
