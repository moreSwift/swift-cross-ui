import CGtk3
import Gtk3
@_spi(Backends) import SwiftCrossUI

extension Gtk3Backend: BackendFeatures.TapGestures {
    public func createTapGestureTarget(wrapping child: Widget, gesture: TapGesture) -> Widget {
        if gesture != .primary {
            fatalError("Unsupported gesture type \(gesture)")
        }
        let eventBox = Gtk3.EventBox()
        eventBox.setChild(to: child)
        eventBox.aboveChild = true
        return eventBox
    }

    public func updateTapGestureTarget(
        _ tapGestureTarget: Widget,
        gesture: TapGesture,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        if gesture != .primary {
            fatalError("Unsupported gesture type \(gesture)")
        }
        tapGestureTarget.onButtonPress = { _, buttonEvent in
            let eventType = buttonEvent.type
            guard
                environment.isEnabled,
                eventType == GDK_BUTTON_PRESS
                || eventType == GDK_2BUTTON_PRESS
                || eventType == GDK_3BUTTON_PRESS
            else {
                return
            }
            action()
        }
    }
}
