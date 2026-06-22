import AppKit
import SwiftCrossUI

// MARK: - Focusability
/// Creates a marker container, keeping focus from entering any of the subviews
/// when ``FocusabilityContainer/focusability`` is ``Focusability/.disabled``
final class FocusabilityContainer: NSView, SwiftCrossUI.FocusabilityContainer {
    private(set) var focusability: SwiftCrossUI.Focusability = .unmodified

    func setFocusability(_ newValue: SwiftCrossUI.Focusability) -> Bool {
        defer { self.focusability = newValue }

        guard
            self.focusability != newValue,
            let window = window as? NSCustomWindow
        else { return false }

        return true
    }

    override var canBecomeKeyView: Bool {
        false
    }

    override var acceptsFirstResponder: Bool {
        false
    }

    override var focusRingType: NSFocusRingType {
        get {
            .exterior
        }
        set {}
    }

    override func drawFocusRingMask() {
        // Get child's frame in parent coordinates
        let childRect = subviews[0].frame
        NSBezierPath(rect: childRect).fill()
    }

    override var focusRingMaskBounds: NSRect {
        subviews[0].frame
    }

    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        return result
    }
}

extension AppKitBackend {
    public func registerFocusObservers(
        _ data: [FocusData],
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

    public func updateFocusContainer(
        _ widget: NSView,
        focusability: Focusability
    ) {
        let container = widget as! FocusabilityContainer
        _ = container.setFocusability(focusability)
    }

    public func setFocusEffectDisabled(on widget: NSView, disabled: Bool) {
        widget.focusRingType = disabled ? .none : .default
    }
}

// MARK: - FocusState

class FocusStateManager: NSObject {
    private var focusData = [ObjectIdentifier: Set<FocusData>]()
    private var lastFocused: NSResponder? = nil
    var shouldSkip: Bool = false

    func register(_ data: [FocusData], for widget: NSView) {
        focusData[ObjectIdentifier(widget)] = Set(data)

        if let window = widget.window,
           window.firstResponder == widget,
           data.contains(where: \.shouldUnfocus)
        {
            window.makeFirstResponder(nil)
        }

        if data.contains(where: \.matches),
           !widget.isHidden,
           widget.acceptsFirstResponder,
           // AppKit passes first responder from NSTextField/NSSecureTextField to an
           // inner NSTextView/NSText.
           // This means when it looks to us like the NSTextField is focused,
           // the NSTextView is the actual first responder.
           // Giving focus back to the surrounding field leads to weird input bugs
           // This makes sure first responder is only given to the widget if its
           // not the inner NSTextView having focus.
           !textFieldsTextViewIsFocused(field: widget)
        {
            widget.window?.makeFirstResponder(widget)
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

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard let window = object as? NSCustomWindow else { return }

        if let responder = window.firstResponder,
           !(responder is NSCustomWindow)
        {
            if responder is NSObservableTextField || responder is NSObservableSecureTextField {
                shouldSkip = true
                self.lastFocused = responder
            } else if !shouldSkip {
                if let lastFocused {
                    handleFocusChange(of: ObjectIdentifier(lastFocused), toState: false)
                }
                self.lastFocused = responder
            } else if shouldSkip {
                shouldSkip = false
                return
            }
            let identifier = ObjectIdentifier(responder)
            handleFocusChange(of: identifier, toState: true)
        } else if let lastFocused {
            handleFocusChange(of: ObjectIdentifier(lastFocused), toState: false)
            self.lastFocused = nil
        }
    }

    private func handleFocusChange(of identifier: ObjectIdentifier, toState isFocused: Bool) {
        guard let data = focusData[identifier] else {
            return
        }
        if isFocused {
            data.forEach { binding in
                binding.set()
            }
        } else {
            data.forEach { binding in
                binding.reset()
            }
        }
    }
}
