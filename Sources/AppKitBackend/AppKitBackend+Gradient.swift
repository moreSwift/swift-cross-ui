import AppKit
import SwiftCrossUI

extension AppKitBackend {
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

    public func createRadialGradientWidget() -> NSView {
        RadialGradientView()
    }

    public func updateRadialGradientWidget(
        _ widget: NSView,
        gradient: RadialGradient,
        withSize size: SIMD2<Int>,
        in environment: EnvironmentValues
    ) {
        let widget = widget as! RadialGradientView
        widget.gradient = gradient
        widget.lastEnvironment = environment
    }

    public func createAngularGradientWidget() -> NSView {
        GradientView()
    }

    public func updateAngularGradientWidget(
        _ widget: NSView,
        gradient: AngularGradient,
        withSize size: SIMD2<Int>,
        in environment: EnvironmentValues
    ) {
        let widget = widget as! GradientView
        widget.setGradientLayer(
            to: CAGradientLayer.angularGradientLayer(
                for: gradient,
                with: environment,
                frame: size
            )
        )
    }
}

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

class GradientView: NSView {
    override var isFlipped: Bool { true }
    
    func setGradientLayer(to layer: CAGradientLayer) {
        self.layer = layer
        layer.drawsAsynchronously = true
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        self.wantsLayer = true
    }
}

extension CAGradientLayer {
    @MainActor
    static func angularGradientLayer(
        for gradient: AngularGradient,
        with environment: EnvironmentValues,
        frame: SIMD2<Int>
    ) -> Self {
        let layer = Self()
        layer.type = .conic

        let adjustedStops = gradient.adjustedStops

        layer.locations = adjustedStops.map { stop in
            NSNumber(value: stop.location)
        }

        layer.colors = adjustedStops.map { stop in
            stop.color.resolve(in: environment).cgColor
        }

        layer.startPoint = gradient.center.cgPoint
        layer.endPoint = (Angle(degrees: 360) - gradient.startAngle).unitCirclePoint

        return layer
    }
}

extension Angle {
    /// The coordinate on a unit circle within the 0 to 1 range that would be
    /// crossed by a line shooting out from the center at the Angle
    var unitCirclePoint: CGPoint {
        let x = 0.5 + cos(radians) * 0.5
        let y = 0.5 + sin(radians) * 0.5

        return CGPoint(x: x, y: 1 - y)
    }
}

extension Color.Resolved {
    var cgColor: CGColor {
        CGColor(
            red: CGFloat(red),
            green: CGFloat(green),
            blue: CGFloat(blue),
            alpha: CGFloat(opacity)
        )
    }
}

extension UnitPoint {
    var cgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }
}
