import Foundation
import Gtk
import SwiftCrossUI

class FocusStateManager {
    private var focusData = [ObjectIdentifier: Set<FocusData>]()
    private var lastFocused: ObjectIdentifier? = nil

    func register(_ data: [FocusData], for widget: Gtk.Widget) {
        let id = ObjectIdentifier(widget)
        focusData[id] = Set(data)

        guard id != lastFocused else {
            if widget.containsFocused,
               data.contains(where: \.shouldUnfocus)
            {
                widget.root?.setFocus(to: nil)
            }
            return
        }

        if data.contains(where: \.matches),
           widget.isVisible,
           widget.isFocusable || widget is Gtk.Entry || widget is Gtk.DropDown
        {
            widget.makeKey()
        }
    }

    func handleFocusChange(of identifier: ObjectIdentifier, toState isFocused: Bool) {
        guard let data = focusData[identifier] else { return }
        if isFocused {
            lastFocused = identifier
            data.forEach { binding in
                binding.set()
            }
        } else {
            lastFocused = nil
            data.forEach { binding in
                binding.reset()
            }
        }
    }
}

extension GtkBackend {
    public func registerFocusObservers(
        _ data: [FocusData],
        on widget: Gtk.Widget
    ) {
        // Some widget's focus is managed by descendants.
        // Therefore widget.isFocusable would be false on them.
        //
        // In the case of Calendar there are multiple points inside it that can
        // be focused in addition to itself, so enter and leave is the best
        // approach here as well.
        if widget is Gtk.Entry || widget is Gtk.Calendar || widget is Gtk.DropDown {
            focusManager.register(data, for: widget)
            guard !widget.eventControllers.contains(where: { $0 is EventControllerFocus }) else {
                return
            }

            let focusController = EventControllerFocus()
            focusController.enter = { _ in
                self.focusManager.handleFocusChange(
                    of: ObjectIdentifier(widget),
                    toState: true
                )
            }
            focusController.leave = { _ in
                self.focusManager.handleFocusChange(
                    of: ObjectIdentifier(widget),
                    toState: false
                )
            }
            widget.addEventController(focusController)
            return
        }

        guard widget.isFocusable else { return }

        focusManager.register(data, for: widget)

        if !widget.eventControllers.contains(where: { $0 is EventControllerFocus }) {
            let focusController = EventControllerFocus()
            focusController.notifyIsFocus = { _, _ in
                self.focusManager.handleFocusChange(
                    of: ObjectIdentifier(widget),
                    toState: focusController.isFocus
                )
            }
            widget.addEventController(focusController)
        }
    }

    public func createFocusContainer() -> Gtk.Widget {
        return Fixed()
    }

    public func updateFocusContainer(
        _ widget: Gtk.Widget,
        focusability: Focusability
    ) {
        widget.canFocus = focusability != .disabled
    }

    public func setFocusEffectDisabled(on widget: Gtk.Widget, disabled: Bool) {
        if disabled {
            widget.focusCSS.set(property: CSSProperty(key: "outline", value: "none"))
            return
        }
        widget.focusCSS = CSSBlock(forClass: widget.focusCSS.cssClass)
    }
}
