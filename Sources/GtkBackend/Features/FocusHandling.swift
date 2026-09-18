import SwiftCrossUI
import Gtk
import CGtk

extension GtkBackend: BackendFeatures.FocusHandling, BackendFeatures.FocusDisabling {
    public func setFocus(of widget: Gtk.Widget, to focus: SwiftCrossUI.Focus) {
        if focus == .focused && ObjectIdentifier(widget) != lastFocusedWidget {
            widget.makeKey()
        } else if focus == .unfocused {
            widget.root?.setFocus(to: nil)
        }
    }

    public func registerFocusObservers(
        _ observers: [WidgetFocusObserver],
        on widget: Gtk.Widget
    ) {
        let objectIdentifier = ObjectIdentifier(widget)

        var focusController: EventControllerFocus

        if let controller = widget.eventControllers
            .first(where: { $0 is EventControllerFocus }) as? EventControllerFocus
        {
            focusController = controller
        } else {
            focusController = EventControllerFocus()
            widget.addEventController(focusController)
        }

        // Some widgets have focusable children.
        // For that reason we use enter/leave over notifyIsFocus.
        focusController.enter = { [weak self] _ in
            guard let self else { return }

            self.lastFocusedWidget = objectIdentifier
            observers.forEach { observer in
                observer.didGainFocus()
            }
        }
        focusController.leave = { [weak self] _ in
            guard let self else { return }

            self.lastFocusedWidget = nil
            observers.forEach { observer in
                observer.didLoseFocus()
            }
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
        if widget is GtkCustomButton {
            if disabled {
                gtk_widget_add_css_class(widget.widgetPointer, "focusEffectDisabled")
            } else {
                gtk_widget_remove_css_class(widget.widgetPointer, "focusEffectDisabled")
            }
            return
        }

        let cssProperty = CSSProperty(key: "outline", value: "none")
        if disabled {
            // Entry is one of the many widgets not working with the focus pseudo-class.
            // Currently some Widgets don't support this modifier yet.
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
