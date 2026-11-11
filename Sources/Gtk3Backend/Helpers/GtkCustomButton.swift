import Gtk3
import CGtk3
import SwiftCrossUI

final class GtkCustomButton: Gtk3.Button {
    // This value is the result of measurements.
    // Runtime computing it is not viable.
    static let buttonPadding = SIMD2<Int>(34, 18)

    var buttonStyle: ButtonStyle.Kind = .bordered {
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
    }

    @MainActor
    func loadCSS(environment: EnvironmentValues) {
        let borderedCSS = Gtk3Backend.controlCSS(for: environment).map { property in
            "\(property.key): \(property.value);"
        }.joined(separator: "\n")

        cssProvider.loadCss(from: """
                button.customButton {
                    min-width: 0px;
                    min-height: 0px;
                    padding: 0px;
                    \(borderedCSS)
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
