@_spi(Backends) import SwiftCrossUI

extension DummyBackend: BackendFeatures.Pickers {
    public var supportedPickerStyles: [BackendPickerStyle] {
        [
            .menu,
            .radioGroup,
            .segmented,
            .wheel
        ]
    }

    public func createPicker(style: BackendPickerStyle) -> Widget {
        Picker(style: style)
    }

    public func updatePicker(
        _ picker: Widget,
        options: [String],
        environment: EnvironmentValues,
        onChange: @escaping (Int?) -> Void
    ) {
        let picker = picker as! Picker
        picker.options = options
        picker.onChange = onChange
        picker.enabled = environment.isEnabled
    }

    public func setSelectedOption(
        ofPicker picker: Widget,
        to selectedOption: Int?
    ) {
        (picker as! Picker).selectedIndex = selectedOption
    }
}
