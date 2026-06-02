import AndroidKit
import SwiftCrossUI

// swiftlint:disable force_try
extension AndroidComposeBackend: BackendFeatures.Pickers {
    public var supportedPickerStyles: [BackendPickerStyle] {
        [.menu, .radioGroup, .wheel]
    }

    public func createPicker(style: BackendPickerStyle) -> Widget {
        let id = allocateId()
        let type: String
        switch style {
            case .radioGroup: type = "PickerRadioGroup"
            case .menu:       type = "PickerMenu"
            case .wheel:      type = "PickerWheel"
            default:          fatalError("Unsupported picker style \(style)")
        }
        bridgeCall("createNode \(type) \(id)") {
            try bridge.createNode(id: id, type: type)
        }
        return id
    }

    public func updatePicker(
        _ picker: Widget,
        options: [String],
        environment: EnvironmentValues,
        onChange: @escaping (Int?) -> Void
    ) {
        let joined = options.joined(separator: "\u{001F}") // unit separator
        try? bridge.setProperty(id: picker, key: "options", value: joined)
        try? bridge.setProperty(id: picker, key: "enabled", value: environment.isEnabled ? "true" : "false")
        handlers[picker, default: EventHandlers()].onChange = { payload in
            onChange(Int(payload))
        }
    }

    public func setSelectedOption(ofPicker picker: Widget, to selectedOption: Int?) {
        try? bridge.setProperty(
            id: picker,
            key: "selected",
            value: selectedOption.map(String.init) ?? "-1"
        )
    }
}
