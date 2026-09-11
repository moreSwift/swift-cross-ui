import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.RadialGradients {
    public func createRadialGradientWidget() -> Widget {
        RadialGradientView()
    }

    public func updateRadialGradientWidget(
        _ widget: Widget,
        gradient: RadialGradient,
        withSize size: SIMD2<Int>,
        in environment: EnvironmentValues
    ) {
        let widget = widget as! RadialGradientView
        widget.gradient = gradient
        widget.lastEnvironment = environment
    }
}
