import CGtk
import Gtk
@_spi(Backends) import SwiftCrossUI

extension GtkBackend: BackendFeatures.TextEditors {
    public func createTextEditor() -> Widget {
        let textEditor = Gtk.TextView()
        textEditor.wrapMode = .wordCharacter
        return textEditor
    }

    public func updateTextEditor(
        _ textEditor: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (String) -> Void
    ) {
        let textEditor = textEditor as! Gtk.TextView
        textEditor.buffer.changed = { buffer in
            onChange(buffer.text)
        }

        var css = textEditor.css
        css.set(properties: Self.cssProperties(for: environment, isControl: false), clear: true)
        css.set(property: CSSProperty(key: "background", value: "none"))
        textEditor.css = css
    }

    public func setContent(ofTextEditor textEditor: Widget, to content: String) {
        let textEditor = textEditor as! Gtk.TextView

        textEditor.buffer.withBlockedSignal(named: "changed") {
            textEditor.buffer.text = content
        }
    }

    public func getContent(ofTextEditor textEditor: Widget) -> String {
        let textEditor = textEditor as! Gtk.TextView
        return textEditor.buffer.text
    }
}
