import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.FocusHandling {
    public func registerFocusObservers(
        _ data: [WidgetFocusObserver],
        on widget: NSView
    ) {
        guard widget.acceptsFirstResponder else { return }

        focusManager.register(data, for: widget)
    }

    public func setFocusEffectDisabled(on widget: NSView, disabled: Bool) {
        widget.focusRingType = disabled ? .none : .default
    }

    public func setFocus(of widget: NSView, to focus: Focus) {
        if
            focus == .focused,
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
        } else if
            focus == .unfocused,
            let window = widget.window,
            window.firstResponder == widget || textFieldsTextViewIsFocused(field: widget)
        {
            _ = window.makeFirstResponder(nil)
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
