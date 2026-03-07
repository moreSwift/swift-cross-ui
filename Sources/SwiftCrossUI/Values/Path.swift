import Foundation // for sin and cos

public enum StrokeCap: Sendable {
    /// The stroke ends square exactly at the last point.
    case butt
    /// The stroke ends with a semicircle.
    case round
    /// The stroke ends square half of the stroke width past the last point.
    case square
}

public enum StrokeJoin: Sendable {
    /// Corners are sharp, unless they are longer than `limit` times half the stroke width,
    /// in which case they are beveled.
    case miter(limit: Double)
    /// Corners are rounded.
    case round
    /// Corners are beveled.
    case bevel
}

public struct StrokeStyle: Sendable {
    public var width: Double
    public var cap: StrokeCap
    public var join: StrokeJoin

    public init(width: Double, cap: StrokeCap = .butt, join: StrokeJoin = .miter(limit: 10.0)) {
        self.width = width
        self.cap = cap
        self.join = join
    }
}

/// An enum describing how a path is shaded.
public enum FillRule: Sendable {
    /// A region is shaded if it is enclosed an odd number of times.
    case evenOdd
    /// A region is shaded if it is enclosed at all.
    ///
    /// This is also known as the "non-zero" rule.
    case winding
}

/// A type representing an affine transformation on a 2-D point.
///
/// Performing an affine transform consists of multiplying the matrix ``linearTransform``
/// by the point as a column vector, then adding ``translation``.
public struct AffineTransform: Equatable, Sendable, CustomDebugStringConvertible {
    /// The linear transformation. This is a 2x2 matrix stored in row-major order.
    ///
    /// The four properties (`x`, `y`, `z`, `w`) correspond to the 2x2 matrix as follows:
    /// ```
    /// [ x  y ]
    /// [ z  w ]
    /// ```
    /// - Remark: The matrices in some graphics frameworks, such as WinUI's `Matrix` and
    /// CoreGraphics' `CGAffineTransform`, take the transpose of this matrix. The reason for
    /// this difference is left- vs right-multiplication; the values are identical.
    public var linearTransform: SIMD4<Double>
    /// The translation applied after the linear transformation.
    public var translation: SIMD2<Double>

    public init(linearTransform: SIMD4<Double>, translation: SIMD2<Double>) {
        self.linearTransform = linearTransform
        self.translation = translation
    }

    public static func translation(x: Double, y: Double) -> AffineTransform {
        AffineTransform(
            linearTransform: SIMD4(x: 1.0, y: 0.0, z: 0.0, w: 1.0),
            translation: SIMD2(x: x, y: y)
        )
    }

    public static func scaling(by factor: Double) -> AffineTransform {
        AffineTransform(
            linearTransform: SIMD4(x: factor, y: 0.0, z: 0.0, w: factor),
            translation: .zero
        )
    }

    public static func rotation(radians: Double, center: SIMD2<Double>) -> AffineTransform {
        let sine = sin(radians)
        let cosine = cos(radians)
        return AffineTransform(
            linearTransform: SIMD4(x: cosine, y: -sine, z: sine, w: cosine),
            translation: SIMD2(
                x: -center.x * cosine + center.y * sine + center.x,
                y: -center.x * sine - center.y * cosine + center.y
            )
        )
    }

    public static func rotation(degrees: Double, center: SIMD2<Double>) -> AffineTransform {
        rotation(radians: degrees * (.pi / 180.0), center: center)
    }

    public static let identity = AffineTransform(
        linearTransform: SIMD4(x: 1.0, y: 0.0, z: 0.0, w: 1.0),
        translation: .zero
    )

    public func inverted() -> AffineTransform? {
        let determinant =
            linearTransform.x * linearTransform.w - linearTransform.y * linearTransform.z
        if determinant == 0.0 {
            return nil
        }

        return AffineTransform(
            linearTransform: SIMD4(
                x: linearTransform.w,
                y: -linearTransform.y,
                z: -linearTransform.z,
                w: linearTransform.x
            ) / determinant,
            translation: SIMD2(
                x: (linearTransform.y * translation.y - linearTransform.w * translation.x),
                y: (linearTransform.z * translation.x - linearTransform.x * translation.y)
            ) / determinant
        )
    }

    public func followedBy(_ other: AffineTransform) -> AffineTransform {
        // Composing two transformations is equivalent to forming the 3x3 matrix shown by
        // `debugDescription`, then multiplying `other * self` (the left matrix is applied
        // after the right matrix).
        return AffineTransform(
            linearTransform: SIMD4(
                x: other.linearTransform.x * linearTransform.x + other.linearTransform.y
                    * linearTransform.z,
                y: other.linearTransform.x * linearTransform.y + other.linearTransform.y
                    * linearTransform.w,
                z: other.linearTransform.z * linearTransform.x + other.linearTransform.w
                    * linearTransform.z,
                w: other.linearTransform.z * linearTransform.y + other.linearTransform.w
                    * linearTransform.w
            ),
            translation: SIMD2(
                x: other.linearTransform.x * translation.x + other.linearTransform.y * translation.y
                    + other.translation.x,
                y: other.linearTransform.z * translation.x + other.linearTransform.w * translation.y
                    + other.translation.y
            )
        )
    }

    public var debugDescription: String {
        let numberFormat = "%.5g"
        let a = String(format: numberFormat, linearTransform.x)
        let b = String(format: numberFormat, linearTransform.y)
        let c = String(format: numberFormat, linearTransform.z)
        let d = String(format: numberFormat, linearTransform.w)
        let tx = String(format: numberFormat, translation.x)
        let ty = String(format: numberFormat, translation.y)
        let zero = String(format: numberFormat, 0.0)
        let one = String(format: numberFormat, 1.0)

        let maxLength = [a, b, c, d, tx, ty, zero, one].map(\.count).max()!

        func pad(_ s: String) -> String {
            String(repeating: " ", count: maxLength - s.count) + s
        }

        return """
            [ \(pad(a)) \(pad(b)) \(pad(tx)) ]
            [ \(pad(c)) \(pad(d)) \(pad(ty)) ]
            [ \(pad(zero)) \(pad(zero)) \(pad(one)) ]
            """
    }
}

public struct Path: Sendable {
    /// A rectangle in 2D space.
    ///
    /// This type is inspired by `CGRect`.
    public struct Rect: Equatable, Sendable {
        /// The rectangle's origin (its top-leading corner), as an x/y vector.
        public var origin: SIMD2<Double>
        /// The rectangle's size, as a width/height vector.
        public var size: SIMD2<Double>

        /// Creates a ``Path/Rect`` instance.
        ///
        /// - Parameters:
        ///   - origin: The rectangle's origin (its top-leading corner), as an
        ///     x/y vector.
        ///   - size: The rectangle's size, as a width/height vector.
        public init(origin: SIMD2<Double>, size: SIMD2<Double>) {
            self.origin = origin
            self.size = size
        }

        /// The X position of the rectangle's leading edge.
        public var x: Double { origin.x }
        /// The Y position of the rectangle's top edge.
        public var y: Double { origin.y }
        /// The rectangle's width.
        public var width: Double { size.x }
        /// The rectangle's height.
        public var height: Double { size.y }

        /// The position of the rectangle's center.
        public var center: SIMD2<Double> { size * 0.5 + origin }
        /// The X position of the rectangle's trailing edge.
        public var maxX: Double { size.x + origin.x }
        /// The Y position of the rectangle's bottom edge.
        public var maxY: Double { size.y + origin.y }

        /// Creates a ``Path/Rect`` instance.
        ///
        /// - Parameters:
        ///   - x: The X position of the rectangle's leading edge.
        ///   - y: The Y position of the rectangle's top edge.
        ///   - width: The rectangle's width.
        ///   - height: The rectangle's height.
        public init(x: Double, y: Double, width: Double, height: Double) {
            origin = SIMD2(x: x, y: y)
            size = SIMD2(x: width, y: height)
        }
    }

    /// The types of actions that can be performed on a path.
    ///
    /// The first action's starting point is (0, 0).
    public enum Action: Equatable, Sendable {
        /// Moves to the specified point without drawing anything.
        case moveTo(SIMD2<Double>)
        /// Draws a line from the path's current point to the specified point.
        case lineTo(SIMD2<Double>)
        /// Draws an order-2 curve from the path's current point, bending
        /// towards `control`, and ending at `endPoint`.
        ///
        /// After this, the path's current point will be `endPoint`.
        case quadCurve(control: SIMD2<Double>, end: SIMD2<Double>)
        /// Draws an order-3 curve starting at the path's current point, bending
        /// towards `control1` and `control2`, and ending at `endPoint`.
        ///
        /// After this, the path's current point will be `endPoint`.
        case cubicCurve(
            control1: SIMD2<Double>,
            control2: SIMD2<Double>,
            end: SIMD2<Double>
        )
        /// Draws a rectangle.
        case rectangle(Rect)
        /// Draws a circle with the specified `center` and `radius`.
        case circle(center: SIMD2<Double>, radius: Double)
        /// Draws an arc segment with the specified `center` and `radius`,
        /// starting at `startAngle` and ending at `endAngle`.
        ///
        /// `startAngle` and `endAngle` are measured in radians clockwise from
        /// the trailing direction, and must be between 0 and 2π, inclusive.
        ///
        /// If `clockwise` is `true`, the arc is drawn in a clockwise direction;
        /// otherwise, it is drawn counterclockwise.
        case arc(
            center: SIMD2<Double>,
            radius: Double,
            startAngle: Double,
            endAngle: Double,
            clockwise: Bool
        )
        /// Applies a transform to the currently drawn path.
        case transform(AffineTransform)
        /// Performs each action in order.
        ///
        /// ``transform(_:)`` actions inside of a `subpath` do not affect
        /// the outer path.
        case subpath([Action])
    }

    /// A list of every action that has been performed on this path.
    ///
    /// This property is meant for backends implementing paths. If the backend
    /// has a similar path type built-in (such as `UIBezierPath` or
    /// `GskPathBuilder`), constructing the path should consist of looping over
    /// this array and calling the method that corresponds to each action.
    public private(set) var actions: [Action] = []
    /// The fill rule for this path.
    public private(set) var fillRule: FillRule = .evenOdd
    /// The stroke style for this path.
    public private(set) var strokeStyle = StrokeStyle(width: 1.0)

    /// Creates an empty ``Path`` instance.
    public init() {}

    /// Move the path's current point to the given point.
    ///
    /// This does not draw a line segment. For that, see ``addLine(to:)``.
    ///
    /// If ``addLine(to:)``, ``addQuadCurve(control:to:)``,
    /// ``addCubicCurve(control1:control2:to:)``, or
    /// ``addArc(center:radius:startAngle:endAngle:clockwise:)`` is called on an
    /// empty path without calling this method first, the start point is
    /// implicitly (0, 0).
    ///
    /// - Parameter point: The point to move to.
    /// - Returns: The updated path.
    public consuming func move(to point: SIMD2<Double>) -> Path {
        actions.append(.moveTo(point))
        return self
    }

    /// Add a line segment from the current point to the given point.
    ///
    /// After this, the path's current point will be the endpoint of this line
    /// segment.
    ///
    /// - Parameter point: The point to draw the line to.
    /// - Returns: The updated path.
    public consuming func addLine(to point: SIMD2<Double>) -> Path {
        actions.append(.lineTo(point))
        return self
    }

    /// Add a quadratic Bézier curve to the path.
    ///
    /// This creates an order-2 curve starting at the path's current point,
    /// bending towards `control`, and ending at `endPoint`. After this, the
    /// path's current point will be `endPoint`.
    ///
    /// - Parameters:
    ///   - control: The control point.
    ///   - endPoint: The end point.
    /// - Returns: The updated path.
    public consuming func addQuadCurve(
        control: SIMD2<Double>,
        to endPoint: SIMD2<Double>
    ) -> Path {
        actions.append(.quadCurve(control: control, end: endPoint))
        return self
    }

    /// Add a cubic Bézier curve to the path.
    ///
    /// This creates an order-3 curve starting at the path's current point,
    /// bending towards `control1` and `control2`, and ending at `endPoint`.
    /// After this, the path's current point will be `endPoint`.
    ///
    /// - Parameters:
    ///   - control1: The first control point.
    ///   - control2: The second control point.
    ///   - endPoint: The end point.
    /// - Returns: The updated path.
    public consuming func addCubicCurve(
        control1: SIMD2<Double>,
        control2: SIMD2<Double>,
        to endPoint: SIMD2<Double>
    ) -> Path {
        actions.append(.cubicCurve(control1: control1, control2: control2, end: endPoint))
        return self
    }

    /// Adds a rectangle to the path.
    ///
    /// - Parameter rect: The rectangle to add.
    /// - Returns: The updated path.
    public consuming func addRectangle(_ rect: Rect) -> Path {
        actions.append(.rectangle(rect))
        return self
    }

    /// Adds a circle to the path.
    ///
    /// - Parameters:
    ///   - center: The circle's center.
    ///   - radius: The circle's radius.
    /// - Returns: The updated path.
    public consuming func addCircle(center: SIMD2<Double>, radius: Double) -> Path {
        actions.append(.circle(center: center, radius: radius))
        return self
    }

    /// Add an arc segment to the path.
    ///
    /// After this, the path's current point will be the endpoint implied by
    /// `center`, `radius`, and `endAngle`.
    ///
    /// - Parameters:
    ///   - center: The location of the center of the circle.
    ///   - radius: The radius of the circle.
    ///   - startAngle: The angle of the start of the arc, measured in radians
    ///     clockwise from the trailing direction. Must be between 0 and 2π,
    ///     inclusive.
    ///   - endAngle: The angle of the end of the arc, measured in radians
    ///     clockwise from the trailing direction. Must be between 0 and 2π,
    ///     inclusive.
    ///   - clockwise: `true` if the arc is to be drawn clockwise, `false` if
    ///     the arc is to be drawn counter-clockwise. Used to determine which of
    ///     the two possible arcs to draw between the given start and end
    ///     angles.
    /// - Returns: The updated path.
    public consuming func addArc(
        center: SIMD2<Double>,
        radius: Double,
        startAngle: Double,
        endAngle: Double,
        clockwise: Bool
    ) -> Path {
        assert((0.0...(2.0 * .pi)).contains(startAngle) && (0.0...(2.0 * .pi)).contains(endAngle))
        actions.append(
            .arc(
                center: center,
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: clockwise
            )
        )
        return self
    }

    /// Apply the given transform to the segments in the path so far.
    ///
    /// While this may adjust the path's current point, it does not otherwise
    /// affect segments that are added to the path after this method call.
    ///
    /// - Parameter transform: The transform to apply.
    /// - Returns: The updated path.
    public consuming func applyTransform(_ transform: AffineTransform) -> Path {
        actions.append(.transform(transform))
        return self
    }

    /// Add the entirety of another path as part of this path.
    ///
    /// This can be necessary to section off transforms, as transforms applied
    /// to `subpath` will not affect this path.
    ///
    /// The fill rule and preferred stroke style of the subpath are ignored.
    ///
    /// - Parameter subpath: The subpath to add.
    /// - Returns: The updated path.
    public consuming func addSubpath(_ subpath: Path) -> Path {
        actions.append(.subpath(subpath.actions))
        return self
    }

    /// Set the default stroke style for the path.
    ///
    /// This is not necessarily respected; it can be overridden by
    /// ``Shape/stroke(_:style:)``, and is lost when the path is passed to
    /// ``addSubpath(_:)``.
    ///
    /// - Parameter style: The stroke style to set.
    /// - Returns: The updated path.
    public consuming func stroke(style: StrokeStyle) -> Path {
        strokeStyle = style
        return self
    }

    /// Set the fill rule for the path.
    ///
    /// - Parameter rule: The fill rule to set.
    /// - Returns: The updated path.
    public consuming func fillRule(_ rule: FillRule) -> Path {
        fillRule = rule
        return self
    }
}

extension Path {
    /// Conditionally modifies a path.
    ///
    /// - Parameters:
    ///   - condition: The condition to check.
    ///   - ifTrue: The action to perform if `condition` is `true`. Receives
    ///     a copy of the path.
    ///   - ifFalse: The action to perform if `condition` is `false`. Receives
    ///     a copy of the path. Defaults to leaving the path unchanged.
    /// - Returns: The updated path.
    @inlinable
    public consuming func `if`(
        _ condition: Bool,
        then ifTrue: (consuming Path) throws -> Path,
        else ifFalse: (consuming Path) throws -> Path = { $0 }
    ) rethrows -> Path {
        if condition {
            try ifTrue(self)
        } else {
            try ifFalse(self)
        }
    }
}
