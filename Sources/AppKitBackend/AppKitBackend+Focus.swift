import AppKit
import SwiftCrossUI

/// Creates a marker container, keeping focus from entering any of the subviews
/// when `FocusabilityContainer/focusability` is `Focusability.disabled`.
final class FocusabilityContainer: NSView, SwiftCrossUI.FocusabilityContainer {
    var focusability: SwiftCrossUI.Focusability = .unmodified
}

extension AppKitBackend {
    public func registerFocusObservers(
        _ data: [WidgetFocusObserver],
        on widget: NSView
    ) {
        guard widget.acceptsFirstResponder else { return }

        focusManager.register(data, for: widget)
    }

    public func createFocusContainer() -> NSView {
        let container = FocusabilityContainer()
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }

    public func setFocus(of widget: NSView, to focus: Focus) {
        if
            focus == .focused,
            !widget.isHidden,
            widget.acceptsFirstResponder,
            // AppKit passes first responder from NSTextField/NSSecureTextField to an
            // inner NSTextView/NSText.
            // This means when it looks to us like the NSTextField is focused,
            // the NSTextView is the actual first responder.
            // Giving focus back to the surrounding field leads to weird input bugs
            // This makes sure first responder is only given to the widget if it's
            // not the inner NSTextView having focus.
            !textFieldsTextViewIsFocused(field: widget)
        {
            widget.window?.makeFirstResponder(widget)
        }

        if
            focus == .unfocused,
            let window = widget.window,
            window.firstResponder == widget || textFieldsTextViewIsFocused(field: widget)
        {
            _ = window.makeFirstResponder(nil)
            return
        }
    }

    private func textFieldsTextViewIsFocused(field: NSView) -> Bool {
        if let field = field as? NSTextField {
            return field.currentEditor() === field.window?.firstResponder
        }
        if let field = field as? NSSecureTextField {
            return field.currentEditor() === field.window?.firstResponder
        }
        return false
    }

    public func updateFocusContainer(
        _ widget: NSView,
        focusability: Focusability
    ) {
        let container = widget as! FocusabilityContainer
        container.focusability = focusability
    }

    public func setFocusEffectDisabled(on widget: NSView, disabled: Bool) {
        widget.focusRingType = disabled ? .none : .default
    }
}

extension NSCustomWindow: FocusChainManager {
    public func closestValidStop(following view: Widget) -> Widget? {
        view.nextValidKeyView
    }

    public func closestValidStop(preceding view: Widget) -> Widget? {
        view.previousValidKeyView
    }

    public func makeKey(_ widget: Widget) {
        makeFirstResponder(widget)
    }

    public func getParent(of widget: Widget) -> Widget? {
        widget.superview
    }
}

extension NSView: FocusChainParticipant {
    public var canBeTabStop: Bool {
        canBecomeKeyView
    }
}
