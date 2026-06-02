import AndroidKit
import SwiftCrossUI

extension AndroidComposeBackend:
    BackendFeatures.ToggleButtons,
    BackendFeatures.Checkboxes,
    BackendFeatures.Switches
{
    public var requiresToggleSwitchSpacer: Bool { false }

    public func createToggle() -> Widget {
        let id = allocateId()
        bridgeCall("createNode ToggleButton \(id)") {
            try bridge.createNode(id: id, type: "ToggleButton")
        }
        return id
    }

    public func createCheckbox() -> Widget {
        let id = allocateId()
        bridgeCall("createNode Checkbox \(id)") {
            try bridge.createNode(id: id, type: "Checkbox")
        }
        return id
    }

    public func createSwitch() -> Widget {
        let id = allocateId()
        bridgeCall("createNode Switch \(id)") {
            try bridge.createNode(id: id, type: "Switch")
        }
        return id
    }

    public func updateToggle(
        _ toggle: Widget,
        label: String,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        try? bridge.setProperty(id: toggle, key: "label", value: label)
        try? bridge.setProperty(id: toggle, key: "enabled", value: environment.isEnabled ? "true" : "false")
        handlers[toggle, default: EventHandlers()].onToggle = onChange
    }

    public func updateCheckbox(
        _ checkboxWidget: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        try? bridge.setProperty(id: checkboxWidget, key: "enabled", value: environment.isEnabled ? "true" : "false")
        handlers[checkboxWidget, default: EventHandlers()].onToggle = onChange
    }

    public func updateSwitch(
        _ switchWidget: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        try? bridge.setProperty(id: switchWidget, key: "enabled", value: environment.isEnabled ? "true" : "false")
        handlers[switchWidget, default: EventHandlers()].onToggle = onChange
    }

    public func setState(ofToggle toggle: Widget, to state: Bool) {
        try? bridge.setProperty(id: toggle, key: "value", value: state ? "true" : "false")
    }

    public func setState(ofCheckbox checkboxWidget: Widget, to state: Bool) {
        try? bridge.setProperty(id: checkboxWidget, key: "value", value: state ? "true" : "false")
    }

    public func setState(ofSwitch switchWidget: Widget, to state: Bool) {
        try? bridge.setProperty(id: switchWidget, key: "value", value: state ? "true" : "false")
    }
}
