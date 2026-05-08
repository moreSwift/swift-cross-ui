import SwiftCrossUI
import WinUI
import WindowsFoundation
import UWP

extension WinUIBackend {
    public func createLinearGradientWidget() -> Widget {
        WinUI.Rectangle()
    }

    public func updateLinearGradientWidget(
        _ widget: Widget,
        gradient: LinearGradient,
        withSize size: SIMD2<Int>,
        in environment: EnvironmentValues
    ) {
        let widget = widget as! WinUI.Rectangle
        
        let collection = GradientStopCollection()
        
        for stop in gradient.gradient.stops {
            let color = stop.color.resolve(in: environment)
            let winUIstop = GradientStop()
            winUIstop.color = UWP.Color(
                a: UInt8(color.opacity * 255),
                r: UInt8(color.red * 255),
                g: UInt8(color.green * 255),
                b: UInt8(color.blue * 255)
            )
            winUIstop.offset = stop.location
            
            collection.append(winUIstop)
        }
        
        let brush = LinearGradientBrush()
        brush.startPoint = gradient.startPoint.point
        brush.endPoint = gradient.endPoint.point
        brush.gradientStops = collection
        
        widget.fill = brush
    }

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
        
        brush.radiusX = max(gradient.endRadius, gradient.startRadius)  / Double(size.x)
        brush.radiusY = max(gradient.endRadius, gradient.startRadius) / Double(size.y)
        
        widget.fill = brush
    }
}

extension UnitPoint {
    var point: WindowsFoundation.Point {
        Point(
            x: Float(x),
            y: Float(y)
        )
    }
}
