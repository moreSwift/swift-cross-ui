import AppKit
@_spi(Backends) import SwiftCrossUI

final class RadialGradientView: NSView {
    var gradient: RadialGradient?
    var lastEnvironment: EnvironmentValues?

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

        let center = CGPoint(
            x: bounds.width * gradient.center.x,
            y: bounds.height * (1 - gradient.center.y)
        )

        nsGradient.draw(
            fromCenter: center,
            radius: gradient.startRadius,
            toCenter: center,
            radius: gradient.endRadius,
            options: [.drawsBeforeStartingLocation, .drawsAfterEndingLocation]
        )
    }

    override func viewDidMoveToWindow() {
        self.wantsLayer = true
        self.layer?.drawsAsynchronously = true
    }
}
