@_spi(Backends) import SwiftCrossUI
import WindowsFoundation
import WinUI
import UWP 

extension WinUIBackend: BackendFeatures.RadialGradients {
    public func createRadialGradientWidget() -> Widget {
        WinUI.Rectangle()
    }

    public func updateRadialGradientWidget(
        _ widget: Widget,
        gradient: RadialGradient,
        withSize size: SIMD2<Int>,
        in environment: EnvironmentValues
    ) {
        let widget = widget as! WinUI.Rectangle

        let brush = RadialGradientBrush()

        for stop in gradient.adjustedStops {
            let color = stop.color.resolve(in: environment)
            let winUIstop = GradientStop()
            winUIstop.color = UWP.Color(
                a: UInt8(color.opacity * 255),
                r: UInt8(color.red * 255),
                g: UInt8(color.green * 255),
                b: UInt8(color.blue * 255)
            )
            winUIstop.offset = stop.location

            brush.gradientStops.append(winUIstop)
        }

        brush.gradientOrigin = gradient.center.point
        brush.center = gradient.center.point

        brush.radiusX = max(gradient.endRadius, gradient.startRadius) / Double(size.x)
        brush.radiusY = max(gradient.endRadius, gradient.startRadius) / Double(size.y)

        widget.fill = brush
    }
}
