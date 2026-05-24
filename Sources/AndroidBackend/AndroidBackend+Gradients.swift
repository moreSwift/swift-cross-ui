import SwiftCrossUI
import AndroidKit
import AndroidGraphics

// swiftlint:disable force_try
extension AndroidBackend: BackendFeatures.Gradients {
    public func createLinearGradientWidget() -> Widget {
        GradientWidget(Self.activity, environment: Self.env)
            .as(AndroidKit.View.self)!
    }

    public func updateLinearGradientWidget(
        _ widget: Widget,
        gradient: SwiftCrossUI.LinearGradient,
        withSize size: SIMD2<Int>,
        in environment: EnvironmentValues
    ) {
        let tileClass = try! JavaClass<AndroidGraphics.Shader.TileMode>()
        let colorClass = try! JavaClass<AndroidGraphics.Color>()

        let count = gradient.gradient.stops.count
        let stops = gradient.gradient.stops.map { Float($0.location) }
        let colors = gradient.gradient.stops.map { stop in
            stop.color.resolve(in: environment).asColorInt()
        }
        
        let density = Float(environment.windowScaleFactor)

        let width = Float(size.x)
        let height = Float(size.y)
        let pxWidth = width * density
        let pxHeight = height * density

        let gradient = AndroidGraphics.LinearGradient(
            Float(gradient.startPoint.x) * pxWidth,
            Float(gradient.startPoint.y) * pxHeight,
            Float(gradient.endPoint.x) * pxWidth,
            Float(gradient.endPoint.y) * pxHeight,
            colors,
            stops,
            tileClass.CLAMP,
            environment: Self.env
        )
        
        widget.as(GradientWidget.self)!.set(
            shader: gradient,
            width: pxWidth,
            height: pxHeight
        )
    }

    public func createRadialGradientWidget() -> Widget {
        GradientWidget(Self.activity, environment: Self.env)
            .as(AndroidKit.View.self)!
    }

    public func updateRadialGradientWidget(
        _ widget: Widget,
        gradient: SwiftCrossUI.RadialGradient,
        withSize size: SIMD2<Int>,
        in environment: EnvironmentValues
    ) {
        let tileClass = try! JavaClass<AndroidGraphics.Shader.TileMode>()
        let colorClass = try! JavaClass<AndroidGraphics.Color>()

        let count = gradient.gradient.stops.count
        let stops = gradient.gradient.stops.map { Float($0.location) }
        let colors = gradient.gradient.stops.map { stop in
            stop.color.resolve(in: environment).asColorInt()
        }
        
        let density = Float(environment.windowScaleFactor)

        let width = Float(size.x)
        let height = Float(size.y)
        let pxWidth = width * density
        let pxHeight = height * density

        let centerX = Float(gradient.center.x) * pxWidth
        let centerY = Float(gradient.center.y) * pxHeight

        let gradient = CustomRadialGradient(
            centerX,
            centerY,
            Float(max(gradient.endRadius, gradient.startRadius, 1)) * density,
            colors,
            stops,
            tileClass.CLAMP,
            environment: Self.env
        )

        widget.as(GradientWidget.self)!.set(
            shader: gradient,
            width: pxWidth,
            height: pxHeight
        )
    }

    public func createAngularGradientWidget() -> Widget {
        GradientWidget(Self.activity, environment: Self.env)
            .as(AndroidKit.View.self)!
    }

    public func updateAngularGradientWidget(
        _ widget: Widget,
        gradient: SwiftCrossUI.AngularGradient,
        withSize size: SIMD2<Int>,
        in environment: EnvironmentValues
    ) {
        let tileClass = try! JavaClass<AndroidGraphics.Shader.TileMode>()
        let colorClass = try! JavaClass<AndroidGraphics.Color>()

        let count = gradient.gradient.stops.count
        let stops = gradient.gradient.stops.map { Float($0.location) }
        let colors = gradient.gradient.stops.map { stop in
            stop.color.resolve(in: environment).asColorInt()
        }
        
        let density = Float(environment.windowScaleFactor)

        let width = Float(size.x)
        let height = Float(size.y)
        let pxWidth = width * density
        let pxHeight = height * density

        let centerX = Float(gradient.center.x) * pxWidth
        let centerY = Float(gradient.center.y) * pxHeight

        let startAngleDegrees = Float(gradient.startAngle.degrees)

        let gradient = AndroidGraphics.SweepGradient(
            centerX,
            centerY,
            colors,
            stops,
            environment: Self.env
        )

        let scaleX: Float = 1.0
        let scaleY = Float(size.y) / Float(size.x)

        let gradientWidget = widget.as(GradientWidget.self)!
        
        gradientWidget.set(
            shader: gradient,
            width: pxWidth,
            height: pxHeight
        )
        
        gradientWidget.setMatrix(
            centerX: centerX,
            centerY: centerY,
            rotationAngle: startAngleDegrees,
            scaleX: scaleX,
            scaleY: scaleY
        )
    }
}
