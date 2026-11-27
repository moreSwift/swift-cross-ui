@_spi(Backends) import SwiftCrossUI
import WinUI
import UWP

extension WinUIBackend: BackendFeatures.HoverGestures {
    public func createHoverTarget(wrapping child: Widget) -> Widget {
        let hoverTarget = HoverGestureTarget()
        insert(child, into: hoverTarget, at: 0)
        hoverTarget.child = child

        // Ensure the hover target covers the full area of the child.
        // Use a transparent background so the visual appearance doesn't change but
        // the hit-testing covers the whole region.
        let brush = SolidColorBrush()
        brush.color = UWP.Color(a: 0, r: 0, g: 0, b: 0)
        hoverTarget.background = brush

        hoverTarget.pointerEntered.addHandler { [weak hoverTarget] _, _ in
            guard let hoverTarget else { return }
            hoverTarget.enterHandler?()
        }
        hoverTarget.pointerExited.addHandler { [weak hoverTarget] _, _ in
            guard let hoverTarget else { return }
            hoverTarget.exitHandler?()
        }
        return hoverTarget
    }

    public func updateHoverTarget(
        _ hoverTarget: Widget,
        environment: EnvironmentValues,
        action: @escaping (Bool) -> Void
    ) {
        let hoverTarget = hoverTarget as! HoverGestureTarget
        hoverTarget.enterHandler = environment.isEnabled ? { action(true) } : {}
        hoverTarget.exitHandler = environment.isEnabled ? { action(false) } : {}
    }
}
