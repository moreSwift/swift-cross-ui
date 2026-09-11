import AppKit

// This class is needed, because you cannot set
// isUserInteractionEnabled on a regular NSButton.
final class NSButtonBackground: NSButton {
    override func hitTest(_ point: NSPoint) -> NSView? {
        return nil
    }

    override var canBecomeKeyView: Bool { false }

    override func drawFocusRingMask() {
        guard let cell else { return }
        var bounds = bounds
        if #unavailable(macOS 26) {
            // For some reason the focus ring drawing appears is offset
            // by the width of the focusring prior to macOS 26.
            // As far as I know the focus ring width is always 3.
            bounds.origin.x -= 3
            bounds.origin.y -= 3
        }
        cell.drawFocusRingMask(withFrame: bounds, in: self)
    }
}
