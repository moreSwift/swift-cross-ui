import SwiftCrossUI
import UIKit

extension UIKitBackend {
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

    public func createAngularGradientWidget() -> Widget {
        GradientView()
    }

    public func updateAngularGradientWidget(
        _ widget: Widget,
        gradient: AngularGradient,
        withSize size: SIMD2<Int>,
        in environment: EnvironmentValues
    ) {
        let widget = widget as! GradientView
        widget.gradientLayer.angularGradientLayer(
            for: gradient,
            with: environment,
            frame: size
        )
    }
}

final class LinearGradientView: BaseViewWidget {
    var gradient: LinearGradient?
    var lastEnvironment: EnvironmentValues?

    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)
        guard
            let gradient,
            let environment = lastEnvironment,
            let context = UIGraphicsGetCurrentContext()
        else { return }

        let stops = gradient.gradient.stops
        let colors = stops.map {
            $0.color.resolve(in: environment).cgColor
        }
        let locations = stops.map { CGFloat($0.location) }

        guard
            let cgGradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: locations
            )
        else { return }

        context.saveGState()
        context.addRect(bounds)
        context.clip()

        let startPoint = CGPoint(
            x: Double(bounds.width) * gradient.startPoint.x,
            y: Double(bounds.height) * gradient.startPoint.y
        )

        let endPoint = CGPoint(
            x: Double(bounds.width) * gradient.endPoint.x,
            y: Double(bounds.height) * gradient.endPoint.y
        )

        context.drawLinearGradient(
            cgGradient,
            start: startPoint,
            end: endPoint,
            options: [.drawsAfterEndLocation]
        )

        context.restoreGState()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        self.layer.drawsAsynchronously = true
    }
}

final class RadialGradientView: BaseViewWidget {
    var gradient: RadialGradient?
    var lastEnvironment: EnvironmentValues?

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard
            let gradient,
            let environment = lastEnvironment,
            let context = UIGraphicsGetCurrentContext()
        else { return }

        let stops = gradient.gradient.stops
        let colors = stops.map {
            $0.color.resolve(in: environment).cgColor
        }
        let locations = stops.map { CGFloat($0.location) }

        guard
            let cgGradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: locations
            )
        else { return }

        let center = CGPoint(
            x: bounds.width * gradient.center.x,
            y: bounds.height * gradient.center.y
        )

        context.saveGState()
        context.addRect(bounds)
        context.clip()

        context.drawRadialGradient(
            cgGradient,
            startCenter: center,
            startRadius: gradient.startRadius,
            endCenter: center,
            endRadius: gradient.endRadius,
            options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
        )

        context.restoreGState()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        self.layer.drawsAsynchronously = true
    }
}

class GradientView: BaseViewWidget {
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    var gradientLayer: CAGradientLayer {
        return self.layer as! CAGradientLayer
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        gradientLayer.drawsAsynchronously = true
    }
}

extension CAGradientLayer {
    @MainActor
    func angularGradientLayer(
        for gradient: AngularGradient,
        with environment: EnvironmentValues,
        frame: SIMD2<Int>
    ) {
        self.type = .conic

        let adjustedStops = gradient.adjustedStops

        self.locations = adjustedStops.map {
            NSNumber(floatLiteral: $0.location)
        }

        self.colors = adjustedStops.map {
            $0.color.resolve(in: environment).cgColor
        }

        self.startPoint = gradient.center.cgPoint
        self.endPoint = (Angle(degrees: 360) - gradient.startAngle).cgPoint
    }
}

extension UnitPoint {
    var cgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }
}

extension Angle {
    var cgPoint: CGPoint {
        let x = 0.5 + cos(radians) * 0.5
        let y = 0.5 + sin(radians) * 0.5

        return CGPoint(x: x, y: 1 - y)
    }
}
