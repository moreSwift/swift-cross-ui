@_spi(Backends) import SwiftCrossUI
import WinUI

extension WinUIBackend: BackendFeatures.TextEditors {
    public func createTextEditor() -> Widget {
        let textEditor = TextBox()
        textEditor.textChanged.addHandler { [weak internalState, weak textEditor] _, _ in
            guard
                let internalState,
                let textEditor
                else { return }
            guard !textEditor.shouldBlockNextChangedSignal else {
                textEditor.shouldBlockNextChangedSignal = false
                return
            }
            // Reuse this storage because it's the same widget type as a text field
            internalState.textFieldChangeActions[ObjectIdentifier(textEditor)]?(textEditor.text)
        }
        textEditor.acceptsReturn = true
        textEditor.textWrapping = .wrap

        // Remove padding
        textEditor.padding = Thickness(left: 0, top: 0, right: 0, bottom: 0)

        // Remove background color
        let brush = SolidColorBrush()
        brush.color = UWP.Color(a: 0, r: 0, g: 0, b: 0)
        textEditor.background = brush

        // Remove hover and focus effects
        _ = textEditor.resources.insert("TextControlBackgroundPointerOver", brush)
        _ = textEditor.resources.insert("TextControlBackgroundFocused", brush)
        _ = textEditor.resources.insert("TextControlBorderBrushFocused", brush)

        return textEditor
    }

    public func updateTextEditor(
        _ textEditor: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (String) -> Void
    ) {
        let textEditor = (textEditor as! TextBox)
        internalState.textFieldChangeActions[ObjectIdentifier(textEditor)] = onChange
        environment.apply(to: textEditor)

        updateInputScope(of: textEditor, textContentType: environment.textContentType)
    }

    public func setContent(ofTextEditor textEditor: Widget, to content: String) {
        let textEditor = textEditor as! TextBox
        textEditor.shouldBlockNextChangedSignal = true
        textEditor.text = content
    }

    public func getContent(ofTextEditor textEditor: Widget) -> String {
        (textEditor as! TextBox).text
    }
}
