import AppKit
@_spi(Backends) import SwiftCrossUI

final class LinearGradientView: NSView {
    var gradient: LinearGradient?
    var lastEnvironment: EnvironmentValues?

    override var isFlipped: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard
            let gradient,
            let environment = lastEnvironment
        else { return }

        let colors = gradient.gradient.stops.map {
            $0.color.resolve(in: environment).nsColor
        }

        NSBezierPath(rect: bounds).addClip()

        guard let nsGradient = NSGradient(
            colors: colors,
            atLocations: gradient.gradient.stops.map { CGFloat($0.location) },
            colorSpace: .deviceRGB
        ) else {
            logger.error("Failed to construct NSGradient; init returned nil")
            return
        }

        let startPoint = UnitPoint(
            x: Double(bounds.width) * gradient.startPoint.x,
            y: Double(bounds.height) * gradient.startPoint.y
        )

        let endPoint = UnitPoint(
            x: Double(bounds.width) * gradient.endPoint.x,
            y: Double(bounds.height) * gradient.endPoint.y
        )

        let angle = Angle(origin: startPoint, destination: endPoint)

        nsGradient.draw(in: bounds, angle: angle.degrees)
    }

    override func viewDidMoveToWindow() {
        self.wantsLayer = true
        self.layer?.drawsAsynchronously = true
    }
}
