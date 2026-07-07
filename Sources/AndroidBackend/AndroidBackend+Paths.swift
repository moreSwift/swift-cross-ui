import AndroidKit
import AndroidGraphics
@_spi(Backends) import SwiftCrossUI

// swiftlint:disable force_try
extension AndroidBackend: BackendFeatures.Paths {
    public struct Path {
        var path: AndroidGraphics.Path
        var fillPaint: AndroidKit.Paint
        var strokePaint: AndroidKit.Paint

        init(env: JNIEnvironment?) {
            path = AndroidGraphics.Path(environment: env)

            let styleClass = try! JavaClass<AndroidKit.Paint.Style>()

            fillPaint = AndroidKit.Paint(environment: env)
            fillPaint.setStyle(styleClass.FILL)

            strokePaint = AndroidKit.Paint(environment: env)
            strokePaint.setStyle(styleClass.STROKE)
        }
    }

    public func createPathWidget() -> Widget {
        PathView(Self.activity, environment: Self.env)
            .as(AndroidKit.View.self)!
    }

    public func createPath() -> Path {
        Path(env: Self.env)
    }

    public func updatePath(
        _ path: Path,
        _ source: SwiftCrossUI.Path,
        bounds: SwiftCrossUI.Path.Rect,
        pointsChanged: Bool,
        environment: EnvironmentValues
    ) {
        apply(strokeStyle: source.strokeStyle, density: environment.windowScaleFactor, to: path)

        let fillTypeClass = try! JavaClass<AndroidGraphics.Path.FillType>()

        switch source.fillRule {
            case .evenOdd:
                path.path.setFillType(fillTypeClass.EVEN_ODD)
            case .winding:
                path.path.setFillType(fillTypeClass.WINDING)
        }

        if pointsChanged {
            path.path.reset()
            apply(actions: source.actions, environment: environment, to: path.path)
        }
    }

    public func renderPath(
        _ path: Path,
        container: Widget,
        strokeColor: SwiftCrossUI.Color.Resolved,
        fillColor: SwiftCrossUI.Color.Resolved,
        overrideStrokeStyle: StrokeStyle?
    ) {
        if let overrideStrokeStyle {
            apply(
                strokeStyle: overrideStrokeStyle,
                density: Double(container.getResources().getDisplayMetrics().density),
                to: path
            )
        }

        path.strokePaint.setColor(strokeColor.asColorInt())
        path.fillPaint.setColor(fillColor.asColorInt())

        container.as(PathView.self)!.set(
            path: path.path,
            fillPaint: path.fillPaint,
            strokePaint: path.strokePaint
        )
    }

    private func apply(
        strokeStyle: StrokeStyle,
        density: Double,
        to path: Path
    ) {
        path.strokePaint.setStrokeWidth(Float(strokeStyle.width * density))

        let capClass = try! JavaClass<AndroidKit.Paint.Cap>()
        switch strokeStyle.cap {
            case .butt:
                path.strokePaint.setStrokeCap(capClass.BUTT)
            case .round:
                path.strokePaint.setStrokeCap(capClass.ROUND)
            case .square:
                path.strokePaint.setStrokeCap(capClass.SQUARE)
        }

        let joinClass = try! JavaClass<AndroidKit.Paint.Join>()
        // Even though fillPaint doesn't render a line, the stroke join can still affect the shape
        // of the fill.
        switch strokeStyle.join {
            case .miter(let limit):
                path.strokePaint.setStrokeJoin(joinClass.MITER)
                path.strokePaint.setStrokeMiter(Float(limit))

                path.fillPaint.setStrokeJoin(joinClass.MITER)
                path.fillPaint.setStrokeMiter(Float(limit))
            case .bevel:
                path.strokePaint.setStrokeJoin(joinClass.BEVEL)
                path.fillPaint.setStrokeJoin(joinClass.BEVEL)
            case .round:
                path.strokePaint.setStrokeJoin(joinClass.ROUND)
                path.fillPaint.setStrokeJoin(joinClass.ROUND)
        }
    }

    private func apply(
        actions: [SwiftCrossUI.Path.Action],
        environment: EnvironmentValues,
        to path: AndroidGraphics.Path
    ) {
        let density = environment.windowScaleFactor
        lazy var directionClass = try! JavaClass<AndroidGraphics.Path.Direction>()

        for action in actions {
            switch action {
                case .moveTo(let point):
                    path.moveTo(Float(point.x * density), Float(point.y * density))
                case .lineTo(let point):
                    path.lineTo(Float(point.x * density), Float(point.y * density))
                case .quadCurve(let control, let end):
                    path.quadTo(
                        Float(control.x * density),
                        Float(control.y * density),
                        Float(end.x * density),
                        Float(end.y * density)
                    )
                case .cubicCurve(let control1, let control2, let end):
                    path.cubicTo(
                        Float(control1.x * density),
                        Float(control1.y * density),
                        Float(control2.x * density),
                        Float(control2.y * density),
                        Float(end.x * density),
                        Float(end.y * density)
                    )
                case .rectangle(let rect):
                    path.addRect(
                        Float(rect.x * density),
                        Float(rect.y * density),
                        Float(rect.maxX * density),
                        Float(rect.maxY * density),
                        directionClass.CW
                    )
                case .circle(let center, let radius):
                    path.addCircle(
                        Float(center.x * density),
                        Float(center.y * density),
                        Float(radius * density),
                        directionClass.CW
                    )
                case .arc(let center, let radius, let startAngle, let endAngle, let clockwise):
                    var sweepAngle: Double
                    if clockwise {
                        if startAngle < endAngle {
                            sweepAngle = endAngle - startAngle
                        } else {
                            sweepAngle = 2 * .pi + endAngle - startAngle
                        }
                    } else {
                        if startAngle < endAngle {
                            sweepAngle = endAngle - startAngle - 2 * .pi
                        } else {
                            sweepAngle = endAngle - startAngle
                        }
                    }

                    path.addArc(
                        Float((center.x - radius) * density),
                        Float((center.y - radius) * density),
                        Float((center.x + radius) * density),
                        Float((center.y + radius) * density),
                        Float(startAngle * 180 / .pi),
                        Float(sweepAngle * 180 / .pi)
                    )
                case .transform(let transform):
                    let matrix = AndroidKit.Matrix(environment: Self.env)
                    matrix.setValues([
                        Float(transform.linearTransform.x),
                        Float(transform.linearTransform.y),
                        Float(transform.translation.x * density),
                        Float(transform.linearTransform.z),
                        Float(transform.linearTransform.w),
                        Float(transform.translation.y * density),
                        0,
                        0,
                        1
                    ])
                    path.transform(matrix)
                case .subpath(let actions):
                    let subPath = AndroidGraphics.Path(environment: Self.env)
                    apply(actions: actions, environment: environment, to: subPath)
                    path.addPath(subPath)
            }
        }
    }
}
