import AppKit
import SwiftCrossUI

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

extension ColorScheme {
    var nsAppearance: NSAppearance? {
        switch self {
            case .light:
                return NSAppearance(named: .aqua)
            case .dark:
                return NSAppearance(named: .darkAqua)
        }
    }
}

extension Color.Resolved {
    var nsColor: NSColor {
        NSColor(
            calibratedRed: CGFloat(red),
            green: CGFloat(green),
            blue: CGFloat(blue),
            alpha: CGFloat(opacity)
        )
    }
}
