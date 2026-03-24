import Foundation

@MainActor
public protocol AppBackend_Controls:
    AppBackend_Button,
    AppBackend_Toggle,
    AppBackend_Switch,
    AppBackend_Checkbox,
    AppBackend_Slider,
    AppBackend_TextField,
    AppBackend_TextEditor,
    AppBackend_Picker,
    AppBackend_DatePicker,
    AppBackend_ProgressSpinner,
    AppBackend_ProgressBar
{}

@MainActor
public protocol AppBackend_Button: AppBackend_Widgets {
    /// Creates a labelled button with an action triggered on click/tap.
    ///
    /// Predominantly used by ``Button``.
    ///
    /// - Returns: A button.
    func createButton() -> Widget

    /// Sets a button's label and action.
    ///
    /// - Parameters:
    ///   - button: The button to update.
    ///   - label: The button's label.
    ///   - environment: The current environment.
    ///   - action: The action to perform when the button is clicked/tapped.
    ///     This replaces any existing actions.
    func updateButton(
        _ button: Widget,
        label: String,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    )
}

@MainActor
public protocol AppBackend_Toggle: AppBackend_Widgets {
    /// Creates a labelled toggle that is either on or off.
    ///
    /// - Returns: A toggle.
    func createToggle() -> Widget
    
    /// Sets the label and change handler of a toggle.
    ///
    /// - Parameters:
    ///   - toggle: The toggle to update.
    ///   - label: The toggle's label.
    ///   - environment: The current environment.
    ///   - onChange: The action to perform when the button is toggled on or
    ///     off. This replaces any existing change handlers.
    func updateToggle(
        _ toggle: Widget,
        label: String,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    )

    /// Sets the state of a toggle.
    ///
    /// - Parameters:
    ///   - toggle: The toggle to set the state of.
    ///   - state: The new state.
    func setState(ofToggle toggle: Widget, to state: Bool)
}

@MainActor
public protocol AppBackend_Switch: AppBackend_Widgets {
    /// If `true`, a toggle in the ``ToggleStyle/switch`` style grows to fill
    /// its parent container.
    var requiresToggleSwitchSpacer: Bool { get }
    
    /// Creates a switch that is either on or off.
    ///
    /// - Returns: A switch.
    func createSwitch() -> Widget

    /// Sets the change handler of a switch.
    ///
    /// - Parameters:
    ///   - switchWidget: The switch to update.
    ///   - environment: The current environment.
    ///   - onChange: The action to perform when the switch is toggled on or
    ///     off. This replaces any existing change handlers.
    func updateSwitch(
        _ switchWidget: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    )

    /// Sets the state of a switch.
    ///
    /// - Parameters:
    ///   - switchWidget: The switch to set the state of.
    ///   - state: The new state.
    func setState(ofSwitch switchWidget: Widget, to state: Bool)
}

@MainActor
public protocol AppBackend_Checkbox: AppBackend_Widgets {
    /// Creates a checkbox that is either on or off.
    ///
    /// - Returns: A checkbox.
    func createCheckbox() -> Widget

    /// Sets the change handler of a checkbox.
    ///
    /// - Parameters:
    ///   - checkboxWidget: The checkbox to update.
    ///   - environment: The current environment.
    ///   - onChange: The action to perform when the checkbox is toggled on or
    ///     off. This replaces any existing change handlers.
    func updateCheckbox(
        _ checkboxWidget: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    )

    /// Sets the state of a checkbox.
    ///
    /// - Parameters:
    ///   - checkboxWidget: The checkbox to set the state of.
    ///   - state: The new state.
    func setState(ofCheckbox checkboxWidget: Widget, to state: Bool)
}

@MainActor
public protocol AppBackend_Slider: AppBackend_Widgets {
    /// Creates a slider for choosing a numerical value from a range. Predominantly used
    /// by ``Slider``.
    func createSlider() -> Widget

    /// Sets the minimum and maximum selectable value of a slider, the number of
    /// decimal places displayed by the slider, and the slider's change handler.
    ///
    /// - Parameters:
    ///   - slider: The slider to update.
    ///   - minimum: The minimum selectable value of the slider (inclusive).
    ///   - maximum: The maximum selectable value of the slider (inclusive).
    ///   - decimalPlaces: The number of decimal places displayed by the slider.
    ///   - environment: The current environment.
    ///   - onChange: The action to perform when the slider's value changes.
    ///     This replaces any existing change handlers.
    func updateSlider(
        _ slider: Widget,
        minimum: Double,
        maximum: Double,
        decimalPlaces: Int,
        environment: EnvironmentValues,
        onChange: @escaping (Double) -> Void
    )

    /// Sets the selected value of a slider.
    ///
    /// - Parameters:
    ///   - slider: The slider to set the value of.
    ///   - value: The new value.
    func setValue(ofSlider slider: Widget, to value: Double)
}

@MainActor
public protocol AppBackend_TextField: AppBackend_Widgets {
    /// Creates an editable text field with a placeholder label and change
    /// handler.
    ///
    /// Predominantly used by ``TextField``.
    ///
    /// - Returns: A text field.
    func createTextField() -> Widget

    /// Sets the placeholder label and change handler of an editable text field.
    ///
    /// - Parameters:
    ///   - textField: The text field to update.
    ///   - placeholder: The text field's placeholder label.
    ///   - environment: The current environment.
    ///   - onChange: The action to perform when the text field's content
    ///     changes. This replaces any existing change handlers, and is called
    ///     whenever the displayed value changes.
    ///   - onSubmit: The action to perform when the user hits Enter/Return,
    ///     or whatever the backend decides counts as submission of the field.
    func updateTextField(
        _ textField: Widget,
        placeholder: String,
        environment: EnvironmentValues,
        onChange: @escaping (String) -> Void,
        onSubmit: @escaping () -> Void
    )

    /// Sets the value of an editable text field.
    ///
    /// - Parameters:
    ///   - textField: The text field to set the content of.
    ///   - content: The new content.
    func setContent(ofTextField textField: Widget, to content: String)
    
    /// Gets the value of an editable text field.
    ///
    /// - Parameter textField: The text field to get the content of.
    /// - Returns: `textField`'s content.
    func getContent(ofTextField textField: Widget) -> String
}

@MainActor
public protocol AppBackend_TextEditor: AppBackend_Widgets {
    /// Creates an editable multi-line text editor.
    ///
    /// Predominantly used by ``TextEditor``.
    ///
    /// - Returns: A text editor.
    func createTextEditor() -> Widget

    /// Sets the placeholder label and change handler of an editable multi-line
    /// text editor.
    ///
    /// The backend shouldn't wait until the user finishes typing to call the
    /// change handler; it should allow live access to the value.
    ///
    /// - Parameters:
    ///   - textEditor: The text editor to update.
    ///   - environment: The current environment.
    ///   - onChange: The action to perform when the text editor's content
    ///     changes. This replaces any existing change handlers, and is called
    ///     whenever the displayed value changes.
    func updateTextEditor(
        _ textEditor: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (String) -> Void
    )

    /// Sets the value of an editable multi-line text editor.
    ///
    /// - Parameters:
    ///   - textEditor: The text editor to set the content of.
    ///   - content: The new content.
    func setContent(ofTextEditor textEditor: Widget, to content: String)

    /// Gets the value of an editable multi-line text editor.
    ///
    /// - Parameter textEditor: The text editor to get the content of.
    /// - Returns: `textEditor`'s content.
    func getContent(ofTextEditor textEditor: Widget) -> String
}

@MainActor
public protocol AppBackend_Picker: AppBackend_Widgets {
    /// The supported picker styles.
    var supportedPickerStyles: [BackendPickerStyle] { get }

    /// The picker style used by ``PickerStyle/automatic``.
    var defaultPickerStyle: BackendPickerStyle { get }

    /// Creates a picker for selecting from a finite set of options (e.g. a radio button group,
    /// a drop-down, a picker wheel).
    ///
    /// Predominantly used by ``Picker``.
    ///
    /// - Parameter style: The picker's style.
    /// - Returns: A picker.
    func createPicker(style: BackendPickerStyle) -> Widget

    /// Sets the options for a picker to display, along with a change handler for when its
    /// selected option changes.
    ///
    /// The change handler
    ///
    /// - Parameters:
    ///   - picker: The picker to update.
    ///   - options: The picker's options.
    ///   - environment: The current environment.
    ///   - onChange: The action to perform when the selected option changes.
    ///     This handler replaces any existing change handlers and is called
    ///     whenever a selection is made, even if the same option is picked
    ///     again.
    func updatePicker(
        _ picker: Widget,
        options: [String],
        environment: EnvironmentValues,
        onChange: @escaping (Int?) -> Void
    )
    
    /// Sets the index of the selected option of a picker.
    ///
    /// - Parameters:
    ///   - picker: The picker.
    ///   - selectedOption: The index of the option to select. If `nil`, all
    ///     options should be deselected.
    func setSelectedOption(ofPicker picker: Widget, to selectedOption: Int?)
}

@MainActor
public protocol AppBackend_DatePicker: AppBackend_Widgets {
    /// The supported date picker styles.
    ///
    /// Must include ``DatePickerStyle/automatic`` if date pickers are supported at all.
    nonisolated var supportedDatePickerStyles: [DatePickerStyle] { get }

    func createDatePicker() -> Widget

    func updateDatePicker(
        _ datePicker: Widget,
        environment: EnvironmentValues,
        date: Date,
        range: ClosedRange<Date>,
        components: DatePickerComponents,
        onChange: @escaping (Date) -> Void
    )
}

@MainActor
public protocol AppBackend_ProgressSpinner: AppBackend_Widgets {
    /// Creates an indeterminate progress spinner.
    ///
    /// - Returns: A progress spinner.
    func createProgressSpinner() -> Widget

    /// Sets the size of a progress spinner.
    ///
    /// This method exists because AppKitBackend requires special handling to resize progress spinners.
    ///
    /// The default implementation forwards to ``AppBackend_Widgets/setSize(of:to:)``.
    func setSize(
        ofProgressSpinner widget: Widget,
        to size: SIMD2<Int>
    )
}

@MainActor
public protocol AppBackend_ProgressBar: AppBackend_Widgets {
    /// Creates a progress bar.
    ///
    /// - Returns: A progress bar.
    func createProgressBar() -> Widget

    /// Updates a progress bar to reflect the given progress (between 0 and 1),
    /// and the current view environment.
    ///
    /// - Parameters:
    ///   - widget: The progress bar to update.
    ///   - progressFraction: The current progress. If `nil`, then the bar
    ///     should show an indeterminate animation if possible.
    ///   - environment: The current environment.
    func updateProgressBar(
        _ widget: Widget,
        progressFraction: Double?,
        environment: EnvironmentValues
    )
}

// MARK: Default Implementations

extension AppBackend_Picker {
    public var defaultPickerStyle: BackendPickerStyle {
        supportedPickerStyles.first ?? .menu
    }
}

extension AppBackend_ProgressSpinner {
    public func setSize(
        ofProgressSpinner widget: Widget,
        to size: SIMD2<Int>
    ) {
        setSize(of: widget, to: size)
    }
}
