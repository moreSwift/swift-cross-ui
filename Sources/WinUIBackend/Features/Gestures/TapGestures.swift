@_spi(Backends) import SwiftCrossUI
import WinUI
import UWP

extension WinUIBackend: BackendFeatures.TapGestures {
    public func createTapGestureTarget(wrapping child: Widget, gesture: TapGesture) -> Widget {
        if gesture != .primary {
            fatalError("Unsupported gesture type \(gesture)")
        }
        let tapGestureTarget = TapGestureTarget()
        insert(child, into: tapGestureTarget, at: 0)
        tapGestureTarget.child = child

        // Set a background so that the click target's entire area gets hit
        // tested. The background we set is transparent so that it doesn't
        // change the visual appearance of the view.
        let brush = SolidColorBrush()
        brush.color = UWP.Color(a: 0, r: 0, g: 0, b: 0)
        tapGestureTarget.background = brush

        tapGestureTarget.pointerPressed.addHandler { [weak tapGestureTarget] _, _ in
            guard let tapGestureTarget else { return }
            tapGestureTarget.clickHandler?()
        }
        return tapGestureTarget
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
        let tapGestureTarget = tapGestureTarget as! TapGestureTarget
        tapGestureTarget.clickHandler = environment.isEnabled ? action : {}
    }
}
