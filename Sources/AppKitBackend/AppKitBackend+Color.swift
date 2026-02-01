import AppKit
import SwiftCrossUI

extension AppKitBackend {
    // NB: We deliberately use the default implementation of `resolveAdaptiveColor(_:in:)`,
    // since that uses the adaptive colors from AppKit/UIKit.
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
