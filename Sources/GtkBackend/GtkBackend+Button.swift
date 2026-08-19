import Gtk
import CGtk
import GtkCHelpers
@_spi(Backends) import SwiftCrossUI

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
            case .bordered: measureBorderedButtonPadding()
            case .plain, .borderless: SIMD2<Int>(0, 0)
        }
    }

    public func defaultButtonStyle() -> ButtonStyle {
        .bordered
    }

    func measureBorderedButtonPadding() -> SIMD2<Int> {
        if let borderedButtonPadding { return borderedButtonPadding }

        // Use root environment for consistency.
        let rootEnvironment = computeRootEnvironment(
            defaultEnvironment: EnvironmentValues(backend: self)
        )

        // The test string needs to be long enough to be bigger than minSize.
        let testString = "Teststring"
        let dummyButton = Button()
        dummyButton.label = testString
        dummyButton.css.clear()
        dummyButton.css.set(properties: Self.cssProperties(for: rootEnvironment, isControl: true))

        let textView = CustomLabel(string: testString)
        textView.css.clear()
        // css needs to be set, otherwise text measures way too big.
        textView.css.set(properties: Self.cssProperties(for: rootEnvironment))
        let textSize = size(
            of: testString,
            whenDisplayedIn: textView,
            proposedWidth: nil,
            proposedHeight: nil,
            environment: rootEnvironment
        )

        let buttonSize = naturalSize(of: dummyButton)

        let result = SIMD2(
            Int(buttonSize.x - textSize.x),
            Int(buttonSize.y - textSize.y)
        )

        borderedButtonPadding = result
        return result
    }
}

fileprivate final class GtkCustomButton: Gtk.Button {
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
    }

    @MainActor
    func loadCSS(environment: EnvironmentValues) {
        let backgroundColor = GtkBackend.controlBackgroundColor(for: environment)
        cssProvider.loadCss(from: """
                button.customButton {
                    min-width: 0px;
                    min-height: 0px;
                    padding: 0px;
                    background: \(CSSProperty.rgba(backgroundColor));
                    border: none;
                    box-shadow: none;
                }

                button.customButton.flat:active,
                button.customButton.flat.keyboard-activating {
                    opacity: 0.80;
                }

                button.customButton.flat {
                    background: transparent;
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
