import SwiftCrossUI

struct CustomNativeButton {
    var label: String
}

#if canImport(GtkBackend)
    import GtkBackend
    import Gtk

    extension CustomNativeButton: GtkWidgetRepresentable {
        func makeGtkWidget(context: Context) -> Gtk.Button {
            Gtk.Button()
        }

        func updateGtkWidget(
            _ button: Gtk.Button,
            context: Context
        ) {
            button.label = label
            button.expandHorizontally = true
            button.useExpandHorizontally = true
            button.css.clear()
            button.css.set(properties: [.backgroundColor(.init(1, 0, 1, 1))])
        }
    }
#endif

#if canImport(Gtk3Backend)
    import Gtk3Backend
    import Gtk3

    extension CustomNativeButton: Gtk3WidgetRepresentable {
        func makeGtk3Widget(context: Context) -> Gtk3.Button {
            Gtk3.Button()
        }

        func updateGtk3Widget(
            _ button: Gtk3.Button,
            context: Context
        ) {
            button.label = label
            button.expandHorizontally = true
            button.useExpandHorizontally = true
            button.css.clear()
            button.css.set(properties: [.backgroundColor(.init(1, 0, 1, 1))])
        }
    }
#endif

#if canImport(AppKitBackend)
    import AppKitBackend
    import AppKit

    extension CustomNativeButton: NSViewRepresentable {
        func makeNSView(context: Context) -> NSButton {
            NSButton()
        }

        func updateNSView(
            _ button: NSButton,
            context: Context
        ) {
            button.title = label
            button.bezelColor = .magenta
        }
    }
#endif

#if canImport(UIKitBackend)
    import UIKitBackend
    import UIKit

    extension CustomNativeButton: UIViewRepresentable {
        func makeUIView(context: Context) -> UIButton {
            UIButton()
        }

        func updateUIView(
            _ button: UIButton,
            context: Context
        ) {
            button.setTitle(label, for: .normal)
            if #available(iOS 15.0, tvOS 15.0, *) {
                button.configuration = .bordered()
            }
        }
    }

    class CustomViewController: UIViewController {
        var button = UIButton()

        override func loadView() {
            if #available(iOS 15.0, tvOS 15.0, *) {
                button.configuration = .bordered()
            }
            view = button
        }
    }

    struct CustomNativeViewControllerButton: UIViewControllerRepresentable {
        var label: String

        func makeUIViewController(context: Context) -> CustomViewController {
            CustomViewController()
        }

        func updateUIViewController(
            _ controller: CustomViewController,
            context: Context
        ) {
            controller.button.setTitle(label, for: .normal)
        }
    }
#endif

#if canImport(WinUIBackend)
    import WinUIBackend
    import WinUI
    import UWP

    extension CustomNativeButton: WinUIElementRepresentable {
        func makeWinUIElement(
            context: Context
        ) -> WinUI.Button {
            WinUI.Button()
        }

        func updateWinUIElement(
            _ button: WinUI.Button,
            context: Context
        ) {
            let block = TextBlock()
            block.text = label
            button.content = block
            let brush = WinUI.SolidColorBrush()
            brush.color = UWP.Color(a: 255, r: 255, g: 0, b: 255)
            button.background = brush
        }
    }
#endif

#if canImport(AndroidBackend)
    import AndroidBackend
    import AndroidKit
    import SwiftJava

    extension CustomNativeButton: AndroidViewRepresentable {
        func makeAndroidView(context: Self.Context) -> AndroidKit.Button {
            AndroidKit.Button(
                context.environment.androidActivity,
                environment: context.environment.jniEnv
            )
        }

        func updateAndroidView(_ view: AndroidKit.Button, context: Self.Context) {
            view.setText(
                JavaString(label, environment: context.environment.jniEnv)
                    .as(CharSequence.self)
            )
            view.setBackgroundColor(Int32(bitPattern: 0xffff00ff))
        }
    }
#endif
