import Foundation

/// A geometric angle whose value you access in either radians or degrees.
public struct Angle: Hashable, Sendable {
    /// An angle in degrees
    public var degrees: Double {
        get {
            radians / Self.conversionFactor
        }
        set {
            radians = newValue * Self.conversionFactor
        }
    }

    /// An angle in radians
    public var radians: Double

    /// Creates an angle from a double value in degrees.
    public init(degrees: Double) {
        self.radians = degrees * Self.conversionFactor
    }

    /// Creates an angle from a double value in radians.
    public init(radians: Double) {
        self.radians = radians
    }

    /// Creates an angle based on the direction between two unit points.
    /// - Parameters:
    ///   - origin: The starting point of the vector.
    ///   - destination: The end point used to calculate the angle from the origin.
    public init(origin: UnitPoint, destination: UnitPoint) {
        let deltaX = destination.x - origin.x
        let deltaY = destination.y - origin.y

        self.init(radians: atan2(deltaY, deltaX))
    }

    /// The factor for converting an angle in degrees to the same angle in radians.
    private static let conversionFactor = Double.pi / 180

    /// Adds two angles together.
    public static func + (lhs: Self, rhs: Self) -> Self {
        Angle(radians: lhs.radians + rhs.radians)
    }

    /// Subtracts two angles.
    public static func - (lhs: Self, rhs: Self) -> Self {
        Angle(radians: lhs.radians - rhs.radians)
    }
}

extension Angle {
    /// The zero angle (0 degrees).
    public static let zero = Angle(degrees: 0)

    /// Creates an angle from a double value in radians.
    public static func radians(_ radians: Double) -> Angle {
        Angle(radians: radians)
    }

    /// Creates an angle from a double value in degrees.
    public static func degrees(_ degrees: Double) -> Angle {
        Angle(degrees: degrees)
    }
}
