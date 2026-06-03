import Gtk
import CGtk
import GtkCHelpers
import SwiftCrossUI

extension GtkBackend {
    public func createSimpleButton() -> Widget {
        return Button()
    }

    public func updateSimpleButton(
        _ button: Widget,
        label: String,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        // TODO: Update button label color using environment
        let button = button as! Gtk.Button
        button.sensitive = environment.isEnabled
        button.label = label
        button.clicked = { _ in action() }
        button.css.clear()
        button.css.set(properties: Self.cssProperties(for: environment, isControl: true))
    }

    public func createButton(wrapping widget: Widget) -> Widget {
        let button = GtkCustomButton()
        gtk_button_set_child(button.widgetPointer.cast(), widget.widgetPointer)

        button.horizontalAlignment = .center
        button.verticalAlignment = .center

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
    }

    public func buttonPadding(in environment: EnvironmentValues) -> SIMD2<Int> {
        switch environment.resolvedButtonStyle.kind {
            case .bordered:
                SIMD2<Int>(
                    Int(GtkCustomButton.horizontalPadding * 2),
                    Int(GtkCustomButton.verticalPadding * 2)
                )
            case .plain, .borderless: SIMD2<Int>(0, 0)
        }
    }

    public func defaultButtonStyle() -> ButtonStyle {
        .bordered
    }
}

fileprivate final class GtkCustomButton: Gtk.Button {
    static let horizontalPadding: Double = 12
    static let verticalPadding: Double = 6

    fileprivate var buttonStyle: ButtonStyle.Kind = .bordered {
        willSet {
            buttonStyle.removeClass(from: self)
        }
        didSet {
            buttonStyle.setClass(on: self)
        }
    }

    init() {
        super.init(gtk_button_new())

        gtk_widget_add_css_class(widgetPointer, "customButton")

        loadCSS()
    }

    private func loadCSS() {
        cssProvider.loadCss(from: """
            button.customButton {
                min-width: 0px;
                min-height: 0px;
                padding: 0px;
            }

            button.customButton.flat:active,
            button.customButton.flat.keyboard-activating {
                opacity: 0.80;
            }

            button.customButton.flat {
                background-color: transparent;
            }

            button.customButton.flat:focus {
                border-radius: 0px;
            }

            button.customButton.flat:disabled {
                opacity: 0.5;
            }
            """)
        // Why 50% disabled opacity was chosen:
        // https://gnome.pages.gitlab.gnome.org/libadwaita/doc/main/css-variables.html#opacity
        // (switch to the variable when we have adwaita)

        // Why 80% for active(pressed) was chosen:
        // A pressed SwiftUI .plain button looks visually the same as
        // a not pressed one at 0.8 opacity.
    }
}

extension ButtonStyle.Kind {
    fileprivate func setClass(on button: GtkCustomButton) {
        if let cssClass {
            gtk_widget_add_css_class(button.widgetPointer, cssClass)
        }
    }

    fileprivate func removeClass(from button: GtkCustomButton) {
        if let cssClass {
            gtk_widget_remove_css_class(button.widgetPointer, cssClass)
        }
    }

    var cssClass: String? {
        switch self {
            case .bordered: nil
            case .plain, .borderless: "flat"
        }
    }
}
