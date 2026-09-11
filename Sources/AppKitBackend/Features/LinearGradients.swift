import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.LinearGradients {
    public func createLinearGradientWidget() -> Widget {
        LinearGradientView()
    }

    public func updateLinearGradientWidget(
        _ widget: Widget,
        gradient: LinearGradient,
        withSize size: SIMD2<Int>,
        in environment: EnvironmentValues
    ) {
        let widget = widget as! LinearGradientView
        widget.gradient = gradient
        widget.lastEnvironment = environment
    }
}
