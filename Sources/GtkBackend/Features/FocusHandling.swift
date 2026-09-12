import SwiftCrossUI
import Gtk
import CGtk

@MainActor
class FocusStateManager {
    private var focusObservers = [ObjectIdentifier: [WidgetFocusObserver]]()
    private var lastFocused: ObjectIdentifier? = nil

    func register(_ observers: [WidgetFocusObserver], for widget: Gtk.Widget) {
        focusObservers[ObjectIdentifier(widget)] = observers
    }

    func handleFocusChange(of identifier: ObjectIdentifier, toState isFocused: Bool) {
        guard let observers = focusObservers[identifier] else { return }
        if isFocused {
            lastFocused = identifier
            observers.forEach { observer in
                observer.didGainFocus()
            }
        } else {
            lastFocused = nil
            observers.forEach { observer in
                observer.didLoseFocus()
            }
        }
    }

    func setFocus(of widget: Gtk.Widget, to focus: SwiftCrossUI.Focus) {
        guard ObjectIdentifier(widget) != lastFocused else {
            if focus == .unfocused {
                widget.root?.setFocus(to: nil)
            }
            return
        }

        if focus == .focused {
            widget.makeKey()
        }
    }
}

extension GtkBackend: BackendFeatures.FocusHandling, BackendFeatures.FocusDisabling {
    public func setFocus(of widget: Gtk.Widget, to focus: SwiftCrossUI.Focus) {
        focusManager.setFocus(of: widget, to: focus)
    }

    public func registerFocusObservers(
        _ observers: [WidgetFocusObserver],
        on widget: Gtk.Widget
    ) {
        let objectIdentifier = ObjectIdentifier(widget)
        // Some widgets focus is managed by descendants.
        //
        // In the case of Calendar there are multiple points inside it that can
        // be focused in addition to itself, so enter and leave is the best
        // approach here as well.
        if widget is Gtk.Entry || widget is Gtk.Calendar || widget is Gtk.DropDown {
            focusManager.register(observers, for: widget)
            guard !widget.eventControllers.contains(where: { $0 is EventControllerFocus }) else {
                return
            }

            let focusController = EventControllerFocus()
            focusController.enter = { _ in
                self.focusManager.handleFocusChange(
                    of: objectIdentifier,
                    toState: true
                )
            }
            focusController.leave = { _ in
                self.focusManager.handleFocusChange(
                    of: objectIdentifier,
                    toState: false
                )
            }
            widget.addEventController(focusController)
            return
        }

        focusManager.register(observers, for: widget)

        if !widget.eventControllers.contains(where: { $0 is EventControllerFocus }) {
            let focusController = EventControllerFocus()
            focusController.notifyIsFocus = { _, _ in
                self.focusManager.handleFocusChange(
                    of: objectIdentifier,
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
        guard !(widget is GtkCustomButton) else {
            if disabled {
                gtk_widget_add_css_class(widget.widgetPointer, "focusEffectDisabled")
            } else {
                gtk_widget_remove_css_class(widget.widgetPointer, "focusEffectDisabled")
            }
            return
        }
        let cssProperty = CSSProperty(key: "outline", value: "none")
        if disabled {
            if widget is Entry {
                widget.focusWithinCSS.set(property: cssProperty)
            }
            widget.focusCSS.set(property: cssProperty)
            return
        }
        widget.focusCSS = CSSBlock(forClass: widget.focusCSS.cssClass)
        widget.focusWithinCSS = CSSBlock(forClass: widget.focusWithinCSS.cssClass)
    }
}
