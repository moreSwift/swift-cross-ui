@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.ButtonStyles {
    public func defaultButtonStyle() -> any ButtonStyle { BorderedButtonStyle() }
}
