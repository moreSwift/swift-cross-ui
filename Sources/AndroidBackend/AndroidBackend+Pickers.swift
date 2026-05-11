import AndroidKit
import SwiftCrossUI

// swiftlint:disable force_try
extension AndroidBackend: BackendFeatures.Pickers {
    public var supportedPickerStyles: [BackendPickerStyle] {
        [.menu, .radioGroup, .wheel]
    }

    public func createPicker(style: BackendPickerStyle) -> Widget {
        switch style {
            case .radioGroup:
                return CustomRadioGroup(
                    Self.activity,
                    environment: Self.env
                ).as(AndroidKit.View.self)!
            case .menu:
                return CustomSpinner(
                    Self.activity,
                    environment: Self.env
                ).as(AndroidKit.View.self)!
            case .wheel:
                return CustomNumberPicker(
                    Self.activity,
                    environment: Self.env
                ).as(AndroidKit.View.self)!
            default:
                // TODO(bbrk24): Implement .segmented using MaterialButtonToggleGroup
                fatalError("Unsupported picker style \(style)")
        }
    }

    public func updatePicker(
        _ picker: Widget,
        options: [String],
        environment: EnvironmentValues,
        onChange: @escaping (Int?) -> Void
    ) {
        if let picker = picker.as(CustomRadioGroup.self) {
            let action = SwiftAction(environment: Self.env) {
                let selectedOption = picker.getSelectedOption()
                onChange(selectedOption < 0 ? nil : Int(selectedOption))
            }
            let textStyle = getTextStyle(from: environment)
            picker.update(
                action,
                options,
                environment.isEnabled,
                color: textStyle.color,
                fontSize: textStyle.fontSize,
                lineHeight: textStyle.lineHeightPixels,
                textStyle.typeface
            )
        } else if let picker = picker.as(CustomSpinner.self) {
            let action = SwiftAction(environment: Self.env) {
                let selectedOption = picker.getSelectedItemPosition()
                let invalidPosition: Int32 = try! JavaClass<AndroidKit.AdapterView>()
                    .INVALID_POSITION

                onChange(selectedOption == invalidPosition ? nil : Int(selectedOption))
            }
            picker.update(action, options, environment.isEnabled)
        } else if let picker = picker.as(CustomNumberPicker.self) {
            let action = SwiftAction(environment: Self.env) {
                let selectedOption = picker.getValue()
                onChange(selectedOption == 0 ? nil : Int(selectedOption - 1))
            }
            picker.update(action, options, environment.isEnabled)
        } else {
            fatalError("Unexpected picker class")
        }
    }

    public func setSelectedOption(ofPicker picker: Widget, to selectedOption: Int?) {
        if let picker = picker.as(CustomRadioGroup.self) {
            picker.selectOption(Int32(selectedOption ?? -1))
        } else if let picker = picker.as(CustomSpinner.self) {
            if let selectedOption {
                picker.selectOption(Int32(selectedOption))
            } else {
                let invalidPosition: Int32 = try! JavaClass<AndroidKit.AdapterView>()
                    .INVALID_POSITION

                picker.selectOption(invalidPosition)
            }
        } else if let picker = picker.as(AndroidKit.NumberPicker.self) {
            if let selectedOption {
                picker.setValue(Int32(selectedOption + 1))
            } else {
                picker.setValue(0)
            }
        } else {
            fatalError("Unexpected picker class")
        }
    }
}
