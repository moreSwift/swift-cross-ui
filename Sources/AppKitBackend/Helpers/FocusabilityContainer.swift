import AppKit
import SwiftCrossUI

/// Creates a marker container, keeping focus from entering any of the subviews
/// when `FocusabilityContainer/focusability` is `Focusability.disabled`.
final class FocusabilityContainer: NSView, SwiftCrossUI.FocusabilityContainer {
    var focusability: SwiftCrossUI.Focusability = .unmodified
}
