import CGtk3
import Gtk3
@_spi(Backends) import SwiftCrossUI

extension Gtk3Backend: BackendFeatures.ViewLabelButtons {
    public func createButton(wrapping widget: Widget) -> Widget {
        let button = GtkCustomButton()
        gtk_container_add(button.widgetPointer.cast(), widget.widgetPointer)

        widget.horizontalAlignment = .center
        widget.verticalAlignment = .center

        return button
    }

    public func updateButton(
        _ button: Widget,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        let button = button as! GtkCustomButton
        button.clicked = { _ in action() }
        button.buttonStyle = environment.resolvedButtonStyle.kind
        button.sensitive = environment.isEnabled
        button.loadCSS(environment: environment)
    }

    public func buttonPadding(in environment: EnvironmentValues) -> SIMD2<Int> {
        switch environment.resolvedButtonStyle.kind {
            case .bordered: GtkCustomButton.buttonPadding
            case .plain, .borderless: SIMD2<Int>(0, 0)
        }
    }

    public func defaultButtonStyle() -> ButtonStyle {
        .bordered
    }
}

extension ButtonStyle.Kind {
    func setClass(on button: GtkCustomButton) {
        if let cssClass {
            let context = gtk_widget_get_style_context(button.widgetPointer)
            gtk_style_context_add_class(context, cssClass)
        }
    }

    func removeClass(from button: GtkCustomButton) {
        if let cssClass {
            let context = gtk_widget_get_style_context(button.widgetPointer)
            gtk_style_context_remove_class(context, cssClass)
        }
    }

    var cssClass: String? {
        switch self {
            case .bordered: nil
            case .plain, .borderless: "flat"
        }
    }
}
