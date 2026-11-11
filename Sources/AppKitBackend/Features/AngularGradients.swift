import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.AngularGradients {
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
        widget.setGradientLayer(
            to: CAGradientLayer.angularGradientLayer(
                for: gradient,
                with: environment,
                frame: size
            )
        )
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
