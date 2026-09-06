import CGtk
import Gtk
@_spi(Backends) import SwiftCrossUI
import Foundation

extension GtkBackend {
    public func createLinearGradientWidget() -> Widget {
        DrawingArea()
    }

    public func updateLinearGradientWidget(
        _ widget: Widget,
        gradient: LinearGradient,
        withSize size: SIMD2<Int>,
        in environment: EnvironmentValues
    ) {
        let drawingArea = widget as! DrawingArea

        let startPoint = UnitPoint(
            x: Double(size.x) * gradient.startPoint.x,
            y: Double(size.y) * gradient.startPoint.y
        )

        let endPoint = UnitPoint(
            x: Double(size.x) * gradient.endPoint.x,
            y: Double(size.y) * gradient.endPoint.y
        )

        let stops = gradient.gradient.stops

        let colors = stops.map {
            $0.color.resolve(in: environment)
        }

        drawingArea.setDrawFunc { [weak self] cairo, _, _ in
            guard let self else { return }

            let pattern = cairo_pattern_create_linear(
                startPoint.x,
                startPoint.y,
                endPoint.x,
                endPoint.y
            )

            for (index, stop) in stops.enumerated() {
                let color = colors[index]
                cairo_pattern_add_color_stop_rgba(
                    pattern,
                    stop.location,
                    Double(color.red),
                    Double(color.green),
                    Double(color.blue),
                    Double(color.opacity)
                )
            }

            cairo_set_source(cairo, pattern)
            cairo_rectangle(cairo, 0, 0, Double(size.x), Double(size.y))
            cairo_fill(cairo)
            cairo_pattern_destroy(pattern)
        }
    }

    public func createRadialGradientWidget() -> Widget {
        DrawingArea()
    }

    public func updateRadialGradientWidget(
        _ widget: Widget,
        gradient: RadialGradient,
        withSize size: SIMD2<Int>,
        in environment: EnvironmentValues
    ) {
        let drawingArea = widget as! DrawingArea

        let stops = gradient.startRadius < gradient.endRadius
            ? gradient.gradient.stops
            : invertedStops(stops: gradient.gradient.stops)

        let centerX = gradient.center.x * Double(size.x)
        let centerY = gradient.center.y * Double(size.y)

        let startRadius = min(gradient.startRadius, gradient.endRadius)
        let endRadius = max(gradient.startRadius, gradient.endRadius)

        let colors = stops.map {
            $0.color.resolve(in: environment)
        }

        drawingArea.setDrawFunc { [weak self] cairo, _, _ in
            guard let self else { return }

            let pattern = cairo_pattern_create_radial(
                centerX,
                centerY,
                startRadius,
                centerX,
                centerY,
                endRadius
            )

            for (index, stop) in stops.enumerated() {
                let color = colors[index]
                cairo_pattern_add_color_stop_rgba(
                    pattern,
                    stop.location,
                    Double(color.red),
                    Double(color.green),
                    Double(color.blue),
                    Double(color.opacity)
                )
            }

            cairo_set_source(cairo, pattern)
            cairo_rectangle(cairo, 0, 0, Double(size.x), Double(size.y))
            cairo_fill(cairo)
            cairo_pattern_destroy(pattern)
        }
    }

    private func invertedStops(stops: [Gradient.Stop]) -> [Gradient.Stop] {
        return stops.reversed().map { stop in
            Gradient.Stop(
                color: stop.color,
                location: 1.0 - stop.location
            )
        }
    }
}
