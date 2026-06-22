import Gtk3
import CGtk3
import SwiftCrossUI

extension Gtk3Backend {
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
        let button = button as! Gtk3.Button
        button.sensitive = environment.isEnabled
        button.label = label
        button.clicked = { _ in action() }
        button.css.clear()
        button.css.set(
            properties: Self.cssProperties(for: environment, isControl: true)
        )
    }

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
        button.css.set(properties: Self.cssProperties(for: environment, isControl: true))
    }

    public func buttonPadding(in environment: EnvironmentValues) -> SIMD2<Int> {
        switch environment.resolvedButtonStyle.kind {
            case .bordered: measureBorderedButtonPadding(environment: environment)
            case .plain, .borderless: SIMD2<Int>(0, 0)
        }
    }

    public func defaultButtonStyle() -> ButtonStyle {
        .bordered
    }
    
    func measureBorderedButtonPadding(environment: EnvironmentValues) -> SIMD2<Int> {
        if let borderedButtonPadding { return borderedButtonPadding }
        
        // The test string needs to be long enough to be bigger than minSize
        let testString = "Teststring"
        let dummyButton = Button()
        dummyButton.label = testString
        
        let field = CustomLabel(string: testString)
        let textSize = size(
            of: testString,
            whenDisplayedIn: field,
            proposedWidth: nil,
            proposedHeight: nil,
            environment: environment
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

fileprivate final class GtkCustomButton: Gtk3.Button {
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

        let context = gtk_widget_get_style_context(widgetPointer)
        gtk_style_context_add_class(context, "customButton")

        loadCSS()
    }

    private func loadCSS() {
        cssProvider.loadCss(from: """
                button.customButton {
                    min-width: 0px;
                    min-height: 0px;
                    padding: 0px;
                }

                button.customButton.flat:active {
                    opacity: 0.8;
                }

                button.customButton.flat {
                    background-image: none;
                    background-color: transparent;
                    border-color: transparent;
                    box-shadow: none;
                }

                button.customButton.flat:focus {
                    -gtk-outline-radius: 0px;
                    outline-offset: 0px;
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
            let context = gtk_widget_get_style_context(button.widgetPointer)
            gtk_style_context_add_class(context, cssClass)
        }
    }

    fileprivate func removeClass(from button: GtkCustomButton) {
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
