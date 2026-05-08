import CGtk
import Gtk
import SwiftCrossUI

extension GtkBackend {
    public func createLinearGradientWidget() -> Widget {
        Box()
    }

    public func updateLinearGradientWidget(
        _ widget: Widget,
        gradient: LinearGradient,
        withSize size: SIMD2<Int>,
        in environment: EnvironmentValues
    ) {
        let widget = widget as! Box

        let startPoint = UnitPoint(
            x: Double(size.x) * gradient.startPoint.x,
            y: Double(size.y) * gradient.startPoint.y
        )

        let endPoint = UnitPoint(
            x: Double(size.x) * gradient.endPoint.x,
            y: Double(size.y) * gradient.endPoint.y
        )

        let angle = Angle(origin: startPoint, destination: endPoint)

        let stops = cssStops(stops: gradient.gradient.stops, environment: environment)
            .joined(separator: ", ")
        
        let radians = (angle + Angle(degrees: 90)).radians
        
        widget.css.set(
            property: .init(
                key: "background",
                value: """
                    linear-gradient(\(radians)rad, \(stops))
                    """
            )
        )
    }

    public func createRadialGradientWidget() -> Widget {
        Box()
    }

    public func updateRadialGradientWidget(
        _ widget: Widget,
        gradient: RadialGradient,
        withSize size: SIMD2<Int>,
        in environment: EnvironmentValues
    ) {
        let widget = widget as! Box
        let stops = gradient.startRadius < gradient.endRadius
            ? gradient.gradient.stops
            : invertedStops(stops: gradient.gradient.stops)
        let cssStops = cssStops(stops: stops, environment: environment)
            .joined(separator: ", ")
        
        let centerXPercent = gradient.center.x * 100
        let centerYPercent = gradient.center.y * 100
        
        widget.css.set(
            property: .init(
                key: "background",
                value: """
                    radial-gradient(\
                    circle at \(centerXPercent)% \(centerYPercent)%, \
                    \(cssStops)\
                    )
                    """
            )
        )
    }
    
    private func invertedStops(stops: [Gradient.Stop]) -> [Gradient.Stop] {
        return stops.reversed().map { stop in
            Gradient.Stop(
                color: stop.color,
                location: 1.0 - stop.location
            )
        }
    }

    private func cssStops(stops: [Gradient.Stop], environment: EnvironmentValues) -> [String] {
        return stops.map { stop in
            let resolved = stop.color.resolve(in: environment)
            let red = resolved.red * 255
            let green = resolved.green * 255
            let blue = resolved.blue * 255
            let location = stop.location * 100
            
            return
                """
                rgba(\(red), \(green), \(blue), \
                \(resolved.opacity)) \(location)%
                """
        }
    }
}
