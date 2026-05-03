/// A rounded rectangle.
///
/// This is not necessarily four line segments and four circular arcs. If
/// possible, this shape uses smoother curves to make the transition between the
/// edges and corners less abrupt.
public struct RoundedRectangle {
    public var cornerRadius: Double

    /// Creates a ``RoundedRectangle`` instance.
    ///
    /// - Precondition: `cornerRadius` must be finite and positive.
    ///
    /// - Parameter cornerRadius: The corner radius for this rounded rectangle.
    public init(cornerRadius: Double) {
        assert(
            cornerRadius >= 0.0 && cornerRadius.isFinite,
            "Corner radius must be a positive finite value")
        self.cornerRadius = cornerRadius
    }

    /// This shape tries to mimic an order 5 superellipse, extending the sides with line segments.
    /// Since paths don't support quintic curves, I'm using an approximation consisting of
    /// two cubic curves and a line segment. This constant is the list of control points for
    /// the cubic curves. See https://www.desmos.com/calculator/chwx3ddx6u .
    ///
    /// Preconditions:
    ///   - points.0 is the same as if a line segment and a circular arc were used
    ///   - points.6.y == 0.0
    fileprivate static let points = (
        SIMD2(0.292893218813, 0.292893218813),
        SIMD2(0.517, 0.0687864376269),
        SIMD2(0.87, 0.0337),
        SIMD2(1.13130356636, 0.0139677719414),
        SIMD2(1.1973, 0.0089),
        SIMD2(1.5038, 0.0002),
        SIMD2(1.7, 0.0)
    )

    /// This corresponds to r_{min} in the above Desmos link. This is the minimum ratio of
    /// cornerRadius to half the side length at which the superellipse is not applicable. Above this,
    /// line segments and circular arcs are used.
    fileprivate static let rMin = 0.441968022436
}

extension RoundedRectangle: Shape {
    public func path(in bounds: Path.Rect) -> Path {
        // just to avoid `RoundedRectangle.` qualifiers
        let rMin = RoundedRectangle.rMin
        let points = RoundedRectangle.points

        let effectiveRadius = min(cornerRadius, bounds.width / 2.0, bounds.height / 2.0)
        let xRatio = effectiveRadius / (bounds.width / 2.0)
        let yRatio = effectiveRadius / (bounds.height / 2.0)

        // MARK: Early exits
        // These code paths are guaranteed to not use the approximations of the quintic curves.

        // Optimization: just a circle
        if bounds.width == bounds.height && bounds.width <= cornerRadius * 2.0 {
            return Circle().path(in: bounds)
        }

        // Optimization: just a rectangle
        if effectiveRadius == 0.0 {
            return Rectangle().path(in: bounds)
        }

        // Optimization: corner radius is too large to use quintic curves
        if xRatio >= rMin && yRatio >= rMin {
            return Path()
                .move(to: SIMD2(x: bounds.x + effectiveRadius, y: bounds.y))
                .addLine(to: SIMD2(x: bounds.maxX - effectiveRadius, y: bounds.y))
                .addArc(
                    center: SIMD2(x: bounds.maxX - effectiveRadius, y: bounds.y + effectiveRadius),
                    radius: effectiveRadius,
                    startAngle: .pi * 1.5,
                    endAngle: 0.0,
                    clockwise: true
                )
                .addLine(to: SIMD2(x: bounds.maxX, y: bounds.maxY - effectiveRadius))
                .addArc(
                    center: SIMD2(
                        x: bounds.maxX - effectiveRadius, y: bounds.maxY - effectiveRadius),
                    radius: effectiveRadius,
                    startAngle: 0.0,
                    endAngle: .pi * 0.5,
                    clockwise: true
                )
                .addLine(to: SIMD2(x: bounds.x + effectiveRadius, y: bounds.maxY))
                .addArc(
                    center: SIMD2(x: bounds.x + effectiveRadius, y: bounds.maxY - effectiveRadius),
                    radius: effectiveRadius,
                    startAngle: .pi * 0.5,
                    endAngle: .pi,
                    clockwise: true
                )
                .addLine(to: SIMD2(x: bounds.x, y: bounds.y + effectiveRadius))
                .addArc(
                    center: SIMD2(x: bounds.x + effectiveRadius, y: bounds.y + effectiveRadius),
                    radius: effectiveRadius,
                    startAngle: .pi,
                    endAngle: .pi * 1.5,
                    clockwise: true
                )
        }

        return Path()
            // MARK: Top edge, right side
            .move(to: SIMD2(x: bounds.center.x, y: bounds.y))
            .if(xRatio >= rMin) {
                $0
                    .addLine(to: SIMD2(x: bounds.maxX - effectiveRadius, y: bounds.y))
                    .addArc(
                        center: SIMD2(
                            x: bounds.maxX - effectiveRadius, y: bounds.y + effectiveRadius),
                        radius: effectiveRadius,
                        startAngle: .pi * 1.5,
                        endAngle: .pi * 1.75,
                        clockwise: true
                    )
            } else: {
                $0
                    .addLine(
                        to: SIMD2(
                            x: bounds.maxX - points.6.x * effectiveRadius,
                            y: bounds.y + points.6.y * effectiveRadius
                        )
                    )
                    .addCubicCurve(
                        control1: SIMD2(
                            x: bounds.maxX - points.5.x * effectiveRadius,
                            y: bounds.y + points.5.y * effectiveRadius
                        ),
                        control2: SIMD2(
                            x: bounds.maxX - points.4.x * effectiveRadius,
                            y: bounds.y + points.4.y * effectiveRadius
                        ),
                        to: SIMD2(
                            x: bounds.maxX - points.3.x * effectiveRadius,
                            y: bounds.y + points.3.y * effectiveRadius
                        )
                    )
                    .addCubicCurve(
                        control1: SIMD2(
                            x: bounds.maxX - points.2.x * effectiveRadius,
                            y: bounds.y + points.2.y * effectiveRadius
                        ),
                        control2: SIMD2(
                            x: bounds.maxX - points.1.x * effectiveRadius,
                            y: bounds.y + points.1.y * effectiveRadius
                        ),
                        to: SIMD2(
                            x: bounds.maxX - points.0.x * effectiveRadius,
                            y: bounds.y + points.0.y * effectiveRadius
                        )
                    )
            }
            // MARK: Right edge
            .if(yRatio >= rMin) {
                $0
                    .addArc(
                        center: SIMD2(
                            x: bounds.maxX - effectiveRadius, y: bounds.y + effectiveRadius),
                        radius: effectiveRadius,
                        startAngle: .pi * 1.75,
                        endAngle: 0.0,
                        clockwise: true
                    )
                    .addLine(to: SIMD2(x: bounds.maxX, y: bounds.maxY - effectiveRadius))
                    .addArc(
                        center: SIMD2(
                            x: bounds.maxX - effectiveRadius, y: bounds.maxY - effectiveRadius),
                        radius: effectiveRadius,
                        startAngle: 0.0,
                        endAngle: .pi * 0.25,
                        clockwise: true
                    )
            } else: {
                $0
                    .addCubicCurve(
                        control1: SIMD2(
                            x: bounds.maxX - points.1.y * effectiveRadius,
                            y: bounds.y + points.1.x * effectiveRadius
                        ),
                        control2: SIMD2(
                            x: bounds.maxX - points.2.y * effectiveRadius,
                            y: bounds.y + points.2.x * effectiveRadius
                        ),
                        to: SIMD2(
                            x: bounds.maxX - points.3.y * effectiveRadius,
                            y: bounds.y + points.3.x * effectiveRadius
                        )
                    )
                    .addCubicCurve(
                        control1: SIMD2(
                            x: bounds.maxX - points.4.y * effectiveRadius,
                            y: bounds.y + points.4.x * effectiveRadius
                        ),
                        control2: SIMD2(
                            x: bounds.maxX - points.5.y * effectiveRadius,
                            y: bounds.y + points.5.x * effectiveRadius
                        ),
                        to: SIMD2(
                            x: bounds.maxX - points.6.y * effectiveRadius,
                            y: bounds.y + points.6.x * effectiveRadius
                        )
                    )
                    .addLine(
                        to: SIMD2(
                            x: bounds.maxX - points.6.y * effectiveRadius,
                            y: bounds.maxY - points.6.x * effectiveRadius
                        )
                    )
                    .addCubicCurve(
                        control1: SIMD2(
                            x: bounds.maxX - points.5.y * effectiveRadius,
                            y: bounds.maxY - points.5.x * effectiveRadius
                        ),
                        control2: SIMD2(
                            x: bounds.maxX - points.4.y * effectiveRadius,
                            y: bounds.maxY - points.4.x * effectiveRadius
                        ),
                        to: SIMD2(
                            x: bounds.maxX - points.3.y * effectiveRadius,
                            y: bounds.maxY - points.3.x * effectiveRadius
                        )
                    )
                    .addCubicCurve(
                        control1: SIMD2(
                            x: bounds.maxX - points.2.y * effectiveRadius,
                            y: bounds.maxY - points.2.x * effectiveRadius
                        ),
                        control2: SIMD2(
                            x: bounds.maxX - points.1.y * effectiveRadius,
                            y: bounds.maxY - points.1.x * effectiveRadius
                        ),
                        to: SIMD2(
                            x: bounds.maxX - points.0.y * effectiveRadius,
                            y: bounds.maxY - points.0.x * effectiveRadius
                        )
                    )
            }
            // MARK: Bottom edge
            .if(xRatio >= rMin) {
                $0
                    .addArc(
                        center: SIMD2(
                            x: bounds.maxX - effectiveRadius, y: bounds.maxY - effectiveRadius),
                        radius: effectiveRadius,
                        startAngle: .pi * 0.25,
                        endAngle: .pi * 0.5,
                        clockwise: true
                    )
                    .addLine(to: SIMD2(x: bounds.x + effectiveRadius, y: bounds.maxY))
                    .addArc(
                        center: SIMD2(
                            x: bounds.x + effectiveRadius, y: bounds.maxY - effectiveRadius),
                        radius: effectiveRadius,
                        startAngle: .pi * 0.5,
                        endAngle: .pi * 0.75,
                        clockwise: true
                    )
            } else: {
                $0
                    .addCubicCurve(
                        control1: SIMD2(
                            x: bounds.maxX - points.1.x * effectiveRadius,
                            y: bounds.maxY - points.1.y * effectiveRadius
                        ),
                        control2: SIMD2(
                            x: bounds.maxX - points.2.x * effectiveRadius,
                            y: bounds.maxY - points.2.y * effectiveRadius
                        ),
                        to: SIMD2(
                            x: bounds.maxX - points.3.x * effectiveRadius,
                            y: bounds.maxY - points.3.y * effectiveRadius
                        )
                    )
                    .addCubicCurve(
                        control1: SIMD2(
                            x: bounds.maxX - points.4.x * effectiveRadius,
                            y: bounds.maxY - points.4.y * effectiveRadius
                        ),
                        control2: SIMD2(
                            x: bounds.maxX - points.5.x * effectiveRadius,
                            y: bounds.maxY - points.5.y * effectiveRadius
                        ),
                        to: SIMD2(
                            x: bounds.maxX - points.6.x * effectiveRadius,
                            y: bounds.maxY - points.6.y * effectiveRadius
                        )
                    )
                    .addLine(
                        to: SIMD2(
                            x: bounds.x + points.6.x * effectiveRadius,
                            y: bounds.maxY - points.6.y * effectiveRadius
                        )
                    )
                    .addCubicCurve(
                        control1: SIMD2(
                            x: bounds.x + points.5.x * effectiveRadius,
                            y: bounds.maxY - points.5.y * effectiveRadius
                        ),
                        control2: SIMD2(
                            x: bounds.x + points.4.x * effectiveRadius,
                            y: bounds.maxY - points.4.y * effectiveRadius
                        ),
                        to: SIMD2(
                            x: bounds.x + points.3.x * effectiveRadius,
                            y: bounds.maxY - points.3.y * effectiveRadius
                        )
                    )
                    .addCubicCurve(
                        control1: SIMD2(
                            x: bounds.x + points.2.x * effectiveRadius,
                            y: bounds.maxY - points.2.y * effectiveRadius
                        ),
                        control2: SIMD2(
                            x: bounds.x + points.1.x * effectiveRadius,
                            y: bounds.maxY - points.1.y * effectiveRadius
                        ),
                        to: SIMD2(
                            x: bounds.x + points.0.x * effectiveRadius,
                            y: bounds.maxY - points.0.y * effectiveRadius
                        )
                    )
            }
            // MARK: Left edge
            .if(yRatio >= rMin) {
                $0
                    .addArc(
                        center: SIMD2(
                            x: bounds.x + effectiveRadius, y: bounds.maxY - effectiveRadius),
                        radius: effectiveRadius,
                        startAngle: .pi * 0.75,
                        endAngle: .pi,
                        clockwise: true
                    )
                    .addLine(to: SIMD2(x: bounds.x, y: bounds.y + effectiveRadius))
                    .addArc(
                        center: SIMD2(x: bounds.x + effectiveRadius, y: bounds.y + effectiveRadius),
                        radius: effectiveRadius,
                        startAngle: .pi,
                        endAngle: .pi * 1.25,
                        clockwise: true
                    )
            } else: {
                $0
                    .addCubicCurve(
                        control1: SIMD2(
                            x: bounds.x + points.1.y * effectiveRadius,
                            y: bounds.maxY - points.1.x * effectiveRadius
                        ),
                        control2: SIMD2(
                            x: bounds.x + points.2.y * effectiveRadius,
                            y: bounds.maxY - points.2.x * effectiveRadius
                        ),
                        to: SIMD2(
                            x: bounds.x + points.3.y * effectiveRadius,
                            y: bounds.maxY - points.3.x * effectiveRadius
                        )
                    )
                    .addCubicCurve(
                        control1: SIMD2(
                            x: bounds.x + points.4.y * effectiveRadius,
                            y: bounds.maxY - points.4.x * effectiveRadius
                        ),
                        control2: SIMD2(
                            x: bounds.x + points.5.y * effectiveRadius,
                            y: bounds.maxY - points.5.x * effectiveRadius
                        ),
                        to: SIMD2(
                            x: bounds.x + points.6.y * effectiveRadius,
                            y: bounds.maxY - points.6.x * effectiveRadius
                        )
                    )
                    .addLine(
                        to: SIMD2(
                            x: bounds.x + points.6.y * effectiveRadius,
                            y: bounds.y + points.6.x * effectiveRadius
                        )
                    )
                    .addCubicCurve(
                        control1: SIMD2(
                            x: bounds.x + points.5.y * effectiveRadius,
                            y: bounds.y + points.5.x * effectiveRadius
                        ),
                        control2: SIMD2(
                            x: bounds.x + points.4.y * effectiveRadius,
                            y: bounds.y + points.4.x * effectiveRadius
                        ),
                        to: SIMD2(
                            x: bounds.x + points.3.y * effectiveRadius,
                            y: bounds.y + points.3.x * effectiveRadius
                        )
                    )
                    .addCubicCurve(
                        control1: SIMD2(
                            x: bounds.x + points.2.y * effectiveRadius,
                            y: bounds.y + points.2.x * effectiveRadius
                        ),
                        control2: SIMD2(
                            x: bounds.x + points.1.y * effectiveRadius,
                            y: bounds.y + points.1.x * effectiveRadius
                        ),
                        to: SIMD2(
                            x: bounds.x + points.0.y * effectiveRadius,
                            y: bounds.y + points.0.x * effectiveRadius
                        )
                    )
            }
            // MARK: Top edge, left side
            .if(xRatio >= rMin) {
                $0
                    .addArc(
                        center: SIMD2(x: bounds.x + effectiveRadius, y: bounds.y + effectiveRadius),
                        radius: effectiveRadius,
                        startAngle: .pi * 1.25,
                        endAngle: .pi * 1.5,
                        clockwise: true
                    )
            } else: {
                $0
                    .addCubicCurve(
                        control1: SIMD2(
                            x: bounds.x + points.1.x * effectiveRadius,
                            y: bounds.y + points.1.y * effectiveRadius
                        ),
                        control2: SIMD2(
                            x: bounds.x + points.2.x * effectiveRadius,
                            y: bounds.y + points.2.y * effectiveRadius
                        ),
                        to: SIMD2(
                            x: bounds.x + points.3.x * effectiveRadius,
                            y: bounds.y + points.3.y * effectiveRadius
                        )
                    )
                    .addCubicCurve(
                        control1: SIMD2(
                            x: bounds.x + points.4.x * effectiveRadius,
                            y: bounds.y + points.4.y * effectiveRadius
                        ),
                        control2: SIMD2(
                            x: bounds.x + points.5.x * effectiveRadius,
                            y: bounds.y + points.5.y * effectiveRadius
                        ),
                        to: SIMD2(
                            x: bounds.x + points.6.x * effectiveRadius,
                            y: bounds.y + points.6.y * effectiveRadius
                        )
                    )
            }
            .addLine(to: SIMD2(x: bounds.center.x, y: bounds.y))
    }
}

// MARK: InsettableShape
extension RoundedRectangle: InsettableShape {
    public func inset(by amount: Double) -> some InsettableShape {
        InsetShapeImpl(initialCornerRadius: cornerRadius, insetAmount: amount)
    }

    struct InsetShapeImpl {
        var initialCornerRadius: Double
        var insetAmount: Double
    }
}

extension RoundedRectangle.InsetShapeImpl: InsettableShape {
    private var actualCornerRadius: Double { max(0, initialCornerRadius - insetAmount) }

    func path(in bounds: Path.Rect) -> Path {
        RoundedRectangle(cornerRadius: actualCornerRadius)
            .path(
                in: .init(
                    x: bounds.x + insetAmount,
                    y: bounds.y + insetAmount,
                    width: bounds.width - 2 * insetAmount,
                    height: bounds.height - 2 * insetAmount
                )
            )
    }

    func size(fitting proposal: ProposedViewSize) -> ViewSize {
        let proposedWidth = proposal.width ?? 10
        let proposedHeight = proposal.height ?? 10

        return ViewSize(max(proposedWidth, insetAmount * 2), max(proposedHeight, insetAmount * 2))
    }

    func inset(by amount: Double) -> Self {
        Self(initialCornerRadius: initialCornerRadius, insetAmount: insetAmount + amount)
    }
}
