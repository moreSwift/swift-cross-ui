@_spi(Backends) import SwiftCrossUI
import WinUI

extension WinUIBackend: BackendFeatures.Paths {
    public typealias Path = GeometryGroupHolder

    public func createPathWidget() -> Widget {
        WinUI.Path()
    }

    public func createPath() -> Path {
        GeometryGroupHolder()
    }

    public func updatePath(
        _ path: Path,
        _ source: SwiftCrossUI.Path,
        bounds: SwiftCrossUI.Path.Rect,
        pointsChanged: Bool,
        environment: EnvironmentValues
    ) {
        path.strokeStyle = source.strokeStyle

        if pointsChanged {
            path.group.children.clear()
            applyActions(source.actions, to: path.group.children)
        }

        path.group.fillRule =
            switch source.fillRule {
                case .evenOdd:
                    .evenOdd
                case .winding:
                    .nonzero
            }
    }

    func requirePathFigure(
        _ collection: WinUI.GeometryCollection,
        lastPoint: Point
    ) -> PathFigure {
        var pathGeometry: PathGeometry
        if collection.size > 0,
           let castedLast = collection.getAt(collection.size - 1) as? PathGeometry
        {
            pathGeometry = castedLast
        } else {
            pathGeometry = PathGeometry()
            collection.append(pathGeometry)
        }

        var figure: PathFigure
        if pathGeometry.figures.size > 0 {
            // Note: the if check and force-unwrap is necessary. You can't do an `if let`
            // here because PathFigureCollection uses unsigned integers for its indices so
            // `size - 1` would underflow (causing a fatalError) if it's empty.
            figure = pathGeometry.figures.getAt(pathGeometry.figures.size - 1)!
        } else {
            figure = PathFigure()
            figure.startPoint = lastPoint
            pathGeometry.figures.append(figure)
        }

        return figure
    }

    func applyActions(_ actions: [SwiftCrossUI.Path.Action], to geometry: WinUI.GeometryCollection)
    {
        var lastPoint = Point(x: 0.0, y: 0.0)

        for action in actions {
            switch action {
                case .moveTo(let point):
                    lastPoint = Point(x: Float(point.x), y: Float(point.y))

                    if geometry.size > 0,
                       let pathGeometry = geometry.getAt(geometry.size - 1) as? PathGeometry,
                       pathGeometry.figures.size > 0
                    {
                        let figure = pathGeometry.figures.getAt(pathGeometry.figures.size - 1)!
                        if figure.segments.size > 0 {
                            let newFigure = PathFigure()
                            newFigure.startPoint = lastPoint
                            pathGeometry.figures.append(newFigure)
                        } else {
                            figure.startPoint = lastPoint
                        }
                    }
                case .lineTo(let point):
                    let wfPoint = Point(x: Float(point.x), y: Float(point.y))
                    defer { lastPoint = wfPoint }

                    let figure = requirePathFigure(geometry, lastPoint: lastPoint)

                    let segment = LineSegment()
                    segment.point = wfPoint
                    figure.segments.append(segment)
                case .quadCurve(let control, let end):
                    let wfControl = Point(x: Float(control.x), y: Float(control.y))
                    let wfEnd = Point(x: Float(end.x), y: Float(end.y))
                    defer { lastPoint = wfEnd }

                    let figure = requirePathFigure(geometry, lastPoint: lastPoint)

                    let segment = QuadraticBezierSegment()
                    segment.point1 = wfControl
                    segment.point2 = wfEnd
                    figure.segments.append(segment)
                case .cubicCurve(let control1, let control2, let end):
                    let wfControl1 = Point(x: Float(control1.x), y: Float(control1.y))
                    let wfControl2 = Point(x: Float(control2.x), y: Float(control2.y))
                    let wfEnd = Point(x: Float(end.x), y: Float(end.y))
                    defer { lastPoint = wfEnd }

                    let figure = requirePathFigure(geometry, lastPoint: lastPoint)

                    let segment = BezierSegment()
                    segment.point1 = wfControl1
                    segment.point2 = wfControl2
                    segment.point3 = wfEnd
                    figure.segments.append(segment)
                case .rectangle(let rect):
                    let rectGeo = RectangleGeometry()
                    rectGeo.rect = Rect(
                        x: Float(rect.x),
                        y: Float(rect.y),
                        width: Float(rect.width),
                        height: Float(rect.height)
                    )
                    geometry.append(rectGeo)
                case .circle(let center, let radius):
                    let ellipse = EllipseGeometry()
                    ellipse.radiusX = radius
                    ellipse.radiusY = radius
                    ellipse.center = Point(x: Float(center.x), y: Float(center.y))
                    geometry.append(ellipse)
                case .arc(
                    let center,
                    let radius,
                    let startAngle,
                    let endAngle,
                    let clockwise
                ):
                    let startPoint = Point(
                        x: Float(center.x + radius * cos(startAngle)),
                        y: Float(center.y + radius * sin(startAngle))
                    )
                    let endPoint = Point(
                        x: Float(center.x + radius * cos(endAngle)),
                        y: Float(center.y + radius * sin(endAngle))
                    )
                    defer { lastPoint = endPoint }

                    let figure = requirePathFigure(geometry, lastPoint: lastPoint)

                    if startPoint != lastPoint {
                        if figure.segments.size > 0 {
                            let connector = LineSegment()
                            connector.point = startPoint
                            figure.segments.append(connector)
                        } else {
                            figure.startPoint = startPoint
                        }
                    }

                    let segment = ArcSegment()

                    if clockwise {
                        if startAngle < endAngle {
                            segment.isLargeArc = (endAngle - startAngle > .pi)
                        } else {
                            segment.isLargeArc = (startAngle - endAngle < .pi)
                        }
                        segment.sweepDirection = .clockwise
                    } else {
                        if startAngle < endAngle {
                            segment.isLargeArc = (endAngle - startAngle < .pi)
                        } else {
                            segment.isLargeArc = (startAngle - endAngle > .pi)
                        }
                        segment.sweepDirection = .counterclockwise
                    }

                    segment.point = endPoint
                    segment.size = Size(width: Float(radius), height: Float(radius))

                    figure.segments.append(segment)
                case .transform(let transform):
                    let matrixTransform = MatrixTransform()
                    matrixTransform.matrix = Matrix(
                        m11: transform.linearTransform.x,
                        m12: transform.linearTransform.z,
                        m21: transform.linearTransform.y,
                        m22: transform.linearTransform.w,
                        offsetX: transform.translation.x,
                        offsetY: transform.translation.y
                    )

                    for case let geo? in geometry {
                        if geo.transform == nil {
                            geo.transform = matrixTransform
                        } else if let group = geo.transform as? TransformGroup {
                            group.children.append(matrixTransform)
                        } else {
                            let group = TransformGroup()
                            group.children.append(geo.transform)
                            group.children.append(matrixTransform)
                            geo.transform = group
                        }
                    }

                    if geometry.size > 0,
                       let pathGeometry = geometry.getAt(geometry.size - 1) as? PathGeometry,
                       pathGeometry.figures.contains(where: { ($0?.segments.size ?? 0) > 0 })
                    {
                        // Start a new PathGeometry so that transforms don't apply going forward
                        geometry.append(PathGeometry())
                    }
                case .subpath(let actions):
                    let subGeo = GeometryGroup()
                    applyActions(actions, to: subGeo.children)
                    geometry.append(subGeo)
            }
        }

        // Cleanup: remove empty paths
        // Having empty paths in the geometry group causes rendering it to silently crash
        for i in (0..<geometry.size).reversed() {
            if let pathGeo = geometry.getAt(i) as? PathGeometry,
               pathGeo.figures.size == 0
            {
                geometry.removeAt(i)
            }
        }
    }

    public func renderPath(
        _ path: Path,
        container: Widget,
        strokeColor: SwiftCrossUI.Color.Resolved,
        fillColor: SwiftCrossUI.Color.Resolved,
        overrideStrokeStyle: StrokeStyle?
    ) {
        let winUiPath = container as! WinUI.Path
        let strokeStyle = overrideStrokeStyle ?? path.strokeStyle!

        winUiPath.fill = WinUI.SolidColorBrush(fillColor.uwpColor)
        winUiPath.stroke = WinUI.SolidColorBrush(strokeColor.uwpColor)
        winUiPath.strokeThickness = strokeStyle.width

        switch strokeStyle.cap {
        case .butt:
            winUiPath.strokeStartLineCap = .flat
            winUiPath.strokeEndLineCap = .flat
        case .round:
            winUiPath.strokeStartLineCap = .round
            winUiPath.strokeEndLineCap = .round
        case .square:
            winUiPath.strokeStartLineCap = .square
            winUiPath.strokeEndLineCap = .square
        }

        switch strokeStyle.join {
        case .miter(let limit):
            winUiPath.strokeMiterLimit = limit
            winUiPath.strokeLineJoin = .miter
        case .round:
            winUiPath.strokeLineJoin = .round
        case .bevel:
            winUiPath.strokeLineJoin = .bevel
        }

        winUiPath.data = path.group
    }
}
