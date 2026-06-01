import SwiftCrossUI
import UIKit

final class ButtonWidget: WrapperWidget<UIButton> {
    private let event: UIControl.Event

    var onTap: (() -> Void)? {
        didSet {
            if oldValue == nil {
                child.addTarget(self, action: #selector(buttonTapped), for: event)
            }
        }
    }

    @objc
    func buttonTapped() {
        onTap?()
    }

    init() {
        let type: UIButton.ButtonType
        #if os(tvOS)
            type = .system
            event = .primaryActionTriggered
        #else
            type = .custom
            event = .touchUpInside
        #endif
        super.init(child: UIButton(type: type))
    }
}

final class TextFieldWidget: WrapperWidget<UITextField>, UITextFieldDelegate {
    var onChange: ((String) -> Void)?
    var onSubmit: (() -> Void)?

    @objc
    func textChanged() {
        onChange?(child.text ?? "")
    }

    init() {
        super.init(child: UITextField())

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textChanged),
            name: UITextField.textDidChangeNotification,
            object: child
        )
        child.delegate = self
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        onSubmit?()
        return false
    }
}

final class TextEditorWidget: WrapperWidget<UITextView>, UITextViewDelegate {
    var onChange: ((String) -> Void)?

    init() {
        super.init(child: UITextView())
        child.delegate = self
    }

    func textViewDidChange(_: UITextView) {
        onChange?(child.text ?? "")
    }
}

#if os(tvOS)
    final class SwitchWidget: WrapperWidget<UISegmentedControl> {
        var onChange: ((Bool) -> Void)?

        @objc
        func switchFlipped() {
            onChange?(child.selectedSegmentIndex == 1)
        }

        init() {
            // TODO: localization?
            super.init(
                child: UISegmentedControl(items: [
                    "OFF" as NSString,
                    "ON" as NSString,
                ]))

            child.addTarget(self, action: #selector(switchFlipped), for: .valueChanged)
        }

        func setOn(_ on: Bool) {
            child.selectedSegmentIndex = on ? 1 : 0
        }
    }
#else
    final class SwitchWidget: WrapperWidget<UISwitch> {
        var onChange: ((Bool) -> Void)?

        @objc
        func switchFlipped() {
            onChange?(child.isOn)
        }

        init() {
            super.init(child: UISwitch())

            // On iOS 14 and later, UISwitch can be either a switch or a checkbox (and I believe
            // it's a checkbox by default on Mac Catalyst). We have no control over this on
            // iOS 13, but when possible, prefer a switch.
            if #available(iOS 14, macCatalyst 14, *) {
                child.preferredStyle = .sliding
            }

            child.addTarget(self, action: #selector(switchFlipped), for: .valueChanged)
        }

        func setOn(_ on: Bool) {
            child.setOn(on, animated: true)
        }
    }
#endif

final class TappableWidget: ContainerWidget {
    private var tapGestureRecognizer: UITapGestureRecognizer?
    private var longPressGestureRecognizer: UILongPressGestureRecognizer?

    var onTap: (() -> Void)? {
        didSet {
            if onTap != nil && tapGestureRecognizer == nil {
                let gestureRecognizer = UITapGestureRecognizer(
                    target: self, action: #selector(viewTouched))
                child.view.addGestureRecognizer(gestureRecognizer)
                self.tapGestureRecognizer = gestureRecognizer
            } else if onTap == nil, let tapGestureRecognizer {
                child.view.removeGestureRecognizer(tapGestureRecognizer)
                self.tapGestureRecognizer = nil
            }
        }
    }

    var onLongPress: (() -> Void)? {
        didSet {
            if onLongPress != nil && longPressGestureRecognizer == nil {
                let gestureRecognizer = UILongPressGestureRecognizer(
                    target: self, action: #selector(viewLongPressed(sender:)))
                child.view.addGestureRecognizer(gestureRecognizer)
                self.longPressGestureRecognizer = gestureRecognizer
            } else if onLongPress == nil, let longPressGestureRecognizer {
                child.view.removeGestureRecognizer(longPressGestureRecognizer)
                self.onLongPress = nil
            }
        }
    }

    @objc
    func viewTouched() {
        onTap?()
    }

    @objc
    func viewLongPressed(sender: UILongPressGestureRecognizer) {
        // GTK emits the event once as soon as the gesture is recognized.
        // UIKit emits it twice, once when it's recognized and once when you lift your finger.
        // For consistency, ignore the second event.
        if sender.state != .ended {
            onLongPress?()
        }
    }
}

@available(tvOS, unavailable)
@available(iOS 13, *)
final class HoverableWidget: ContainerWidget {
    private var hoverGestureRecognizer: UIHoverGestureRecognizer?

    var hoverChangesHandler: ((Bool) -> Void)? {
        didSet {
            if hoverChangesHandler != nil && hoverGestureRecognizer == nil {
                let gestureRecognizer = UIHoverGestureRecognizer(
                    target: self,
                    action: #selector(hoveringChanged(_:)))
                child.view.addGestureRecognizer(gestureRecognizer)
                self.hoverGestureRecognizer = gestureRecognizer
            } else if hoverChangesHandler == nil, let hoverGestureRecognizer {
                child.view.removeGestureRecognizer(hoverGestureRecognizer)
                self.hoverGestureRecognizer = nil
            }
        }
    }

    @objc
    func hoveringChanged(_ recognizer: UIHoverGestureRecognizer) {
        switch recognizer.state {
            case .began: hoverChangesHandler?(true)
            case .ended: hoverChangesHandler?(false)
            default: break
        }
    }
}
@available(tvOS, unavailable)
final class SliderWidget: WrapperWidget<UISlider> {
    var onChange: ((Double) -> Void)?

    private var _decimalPlaces = 17
    var decimalPlaces: Int {
        get { _decimalPlaces }
        set {
            _decimalPlaces = max(0, min(newValue, 17))
        }
    }

    @objc
    func sliderMoved() {
        onChange?(
            (Double(child.value) * pow(10.0, Double(decimalPlaces)))
                .rounded(.toNearestOrEven)
                / pow(10.0, Double(decimalPlaces))
        )
    }

    init() {
        super.init(child: UISlider())
        child.addTarget(self, action: #selector(sliderMoved), for: .valueChanged)
    }
}

extension UIKitBackend {
    public func createButton() -> Widget {
        ButtonWidget()
    }

    func setButtonTitle(
        _ buttonWidget: ButtonWidget,
        _ label: String,
        environment: EnvironmentValues
    ) {
        // tvOS's buttons change foreground color when focused. If we set an
        // attributed string for `.normal` we also have to set another for
        // `.focused` with a colour that's readable on a white background.
        // However, with that approach the label's color animates too slowly
        // and all round looks quite sloppy. Therefore, it's safest to just
        // ignore foreground color for buttons on tvOS until we have a better
        // solution.
        let foregroundColor: UIColor
        foregroundColor = .blue
        
        //MARK: Test fix
        /*if #available(iOS 13, *) {
            foregroundColor = .link
        } else if #available(iOS 7, *) {
            // fallback color for older iOS versions
            foregroundColor = UIColor.systemBlue
        } else {
            foregroundColor = UIColor.blue
        }*/
        
        #if os(tvOS)
            buttonWidget.child.setTitle(label, for: .normal)
        #else
            buttonWidget.child.setAttributedTitle(
                UIKitBackend.attributedString(
                    text: label,
                    environment: environment,
                    defaultForegroundColor: foregroundColor
                ),
                for: .normal
            )
        #endif
    }

    public func updateButton(
        _ button: Widget,
        label: String,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        let buttonWidget = button as! ButtonWidget

        setButtonTitle(buttonWidget, label, environment: environment)

        buttonWidget.onTap = action
        buttonWidget.child.isEnabled = environment.isEnabled
    }

    public func createTextField() -> Widget {
        TextFieldWidget()
    }

    public func updateTextField(
        _ textField: Widget,
        placeholder: String,
        environment: EnvironmentValues,
        onChange: @escaping (String) -> Void,
        onSubmit: @escaping () -> Void
    ) {
        let textFieldWidget = textField as! TextFieldWidget

        textFieldWidget.child.isEnabled = environment.isEnabled
        textFieldWidget.child.placeholder = placeholder
        textFieldWidget.child.font = environment.resolvedFont.uiFont
        textFieldWidget.child.textColor = UIColor(color: environment.suggestedForegroundColor)
        textFieldWidget.onChange = onChange
        textFieldWidget.onSubmit = onSubmit

        let keyboardType: UIKeyboardType
        let contentType: UITextContentType?

        if #available(iOS 10, *) {
            (keyboardType, contentType) = splitTextContentType(environment.textContentType)
        } else {
            keyboardType = .default
            contentType = nil
        }

        textFieldWidget.child.keyboardType = keyboardType
        if #available(iOS 10, *) {
            textFieldWidget.child.textContentType = contentType
        }

        #if os(iOS)
            if let updateToolbar = environment.updateToolbar {
                let toolbar =
                    (textFieldWidget.child.inputAccessoryView as? KeyboardToolbar)
                    ?? KeyboardToolbar()
                updateToolbar(toolbar)
                textFieldWidget.child.inputAccessoryView = toolbar
            } else {
                textFieldWidget.child.inputAccessoryView = nil
            }
        #endif
    }

    public func setContent(ofTextField textField: Widget, to content: String) {
        let textFieldWidget = textField as! TextFieldWidget
        textFieldWidget.child.text = content
    }

    public func getContent(ofTextField textField: Widget) -> String {
        let textFieldWidget = textField as! TextFieldWidget
        return textFieldWidget.child.text ?? ""
    }

    public func createTextEditor() -> Widget {
        let widget = TextEditorWidget()
        widget.child.backgroundColor = .clear
        widget.child.textContainer.lineFragmentPadding = 0
        widget.child.textContainerInset = .zero
        return widget
    }

    public func updateTextEditor(
        _ textEditor: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (String) -> Void
    ) {
        let textEditorWidget = textEditor as! TextEditorWidget

        textEditorWidget.child.isEditable = environment.isEnabled
        textEditorWidget.child.font = environment.resolvedFont.uiFont
        textEditorWidget.child.textColor = UIColor(color: environment.suggestedForegroundColor)
        textEditorWidget.onChange = onChange
        
        
        let keyboardType: UIKeyboardType
        let contentType: UITextContentType?

        if #available(iOS 10, *) {
            (keyboardType, contentType) = splitTextContentType(environment.textContentType)
        } else {
            keyboardType = .default
            contentType = nil
        }

        textEditorWidget.child.keyboardType = keyboardType
        if #available(iOS 10, *) {
            textEditorWidget.child.textContentType = contentType
        }
        

        #if os(iOS)
            if let updateToolbar = environment.updateToolbar {
                let toolbar =
                    (textEditorWidget.child.inputAccessoryView as? KeyboardToolbar)
                    ?? KeyboardToolbar()
                updateToolbar(toolbar)
                textEditorWidget.child.inputAccessoryView = toolbar
            } else {
                textEditorWidget.child.inputAccessoryView = nil
            }

            textEditorWidget.child.alwaysBounceVertical =
                environment.scrollDismissesKeyboardMode != .never
        #endif
    }

    public func setContent(ofTextEditor textEditor: Widget, to content: String) {
        let textEditorWidget = textEditor as! TextEditorWidget
        textEditorWidget.child.text = content
    }

    public func getContent(ofTextEditor textEditor: Widget) -> String {
        let textEditorWidget = textEditor as! TextEditorWidget
        return textEditorWidget.child.text ?? ""
    }

    // Splits a SwiftCrossUI TextContentType into a UIKit keyboard type and
    // text content type.
    @available(iOS 10, *)
    private func splitTextContentType(
        _ textContentType: TextContentType
    ) -> (UIKeyboardType, UITextContentType?) {
        switch textContentType {
            case .text:
                return (.default, nil)
            case .digits(ascii: false):
                return (.numberPad, nil)
            case .digits(ascii: true):
                return (.asciiCapableNumberPad, nil)
            case .url:
                return (.URL, .URL)
            case .phoneNumber:
                return (.phonePad, .telephoneNumber)
            case .name:
                return (.namePhonePad, .name)
            case .decimal(signed: false):
                return (.decimalPad, nil)
            case .decimal(signed: true):
                return (.numbersAndPunctuation, nil)
            case .emailAddress:
                return (.emailAddress, .emailAddress)
        }
    }

    public func createSwitch() -> Widget {
        SwitchWidget()
    }

    public func updateSwitch(
        _ switchWidget: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        let wrapper = switchWidget as! SwitchWidget
        wrapper.onChange = onChange
        wrapper.child.isEnabled = environment.isEnabled
    }

    public func setState(ofSwitch switchWidget: Widget, to state: Bool) {
        let wrapper = switchWidget as! SwitchWidget
        wrapper.setOn(state)
    }

    public func createTapGestureTarget(wrapping child: Widget, gesture _: TapGesture) -> Widget {
        TappableWidget(child: child)
    }

    public func updateTapGestureTarget(
        _ tapGestureTarget: Widget,
        gesture: TapGesture,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        let wrapper = tapGestureTarget as! TappableWidget
        switch gesture.kind {
            case .primary:
                wrapper.onTap = environment.isEnabled ? action : {}
                wrapper.onLongPress = nil
            case .secondary, .longPress:
                wrapper.onTap = nil
                wrapper.onLongPress = environment.isEnabled ? action : {}
        }
    }
    
    @available(iOS 13, *)
    public func createHoverTarget(wrapping child: Widget) -> Widget {
        HoverableWidget(child: child)
    }
    
    @available(iOS 13, *)
    public func updateHoverTarget(
        _ hoverTarget: any WidgetProtocol,
        environment: EnvironmentValues,
        action: @escaping (Bool) -> Void
    ) {
        let wrapper = hoverTarget as! HoverableWidget
        wrapper.hoverChangesHandler = action
    }

    #if os(iOS) || os(visionOS) || targetEnvironment(macCatalyst)
        public func createSlider() -> Widget {
            SliderWidget()
        }

        public func updateSlider(
            _ slider: Widget,
            minimum: Double,
            maximum: Double,
            decimalPlaces: Int,
            environment: EnvironmentValues,
            onChange: @escaping (Double) -> Void
        ) {
            let sliderWidget = slider as! SliderWidget
            sliderWidget.child.minimumValue = Float(minimum)
            sliderWidget.child.maximumValue = Float(maximum)
            sliderWidget.child.isEnabled = environment.isEnabled
            sliderWidget.onChange = onChange
            sliderWidget.decimalPlaces = decimalPlaces
        }

        public func setValue(ofSlider slider: Widget, to value: Double) {
            let sliderWidget = slider as! SliderWidget
            sliderWidget.child.setValue(Float(value), animated: true)
        }
    #endif
}
