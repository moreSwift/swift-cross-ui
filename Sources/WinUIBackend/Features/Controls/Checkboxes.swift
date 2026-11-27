@_spi(Backends) import SwiftCrossUI
import WinUI

extension WinUIBackend: BackendFeatures.Checkboxes {
    public func createCheckbox() -> Widget {
        let checkbox = CustomCheckBox()

        // This natural size is hardcoded, but it's the actual visible size of
        // the checkbox. WinUI puts a bunch of extra space around checkboxes
        // by default which messes things up.
        let naturalSize = naturalSize(of: checkbox)
        checkbox.minWidth = Double(naturalSize.x)
        checkbox.minHeight = Double(naturalSize.y)

        checkbox.padding = Thickness(left: 0, top: 0, right: 0, bottom: 0)
        checkbox.checked.addHandler { [weak checkbox] _, _ in
            checkbox?.handleToggle()
        }
        checkbox.unchecked.addHandler { [weak checkbox] _, _ in
            checkbox?.handleToggle()
        }
        return checkbox
    }

    public func updateCheckbox(
        _ checkbox: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        let checkbox = checkbox as! CustomCheckBox
        checkbox.padding = Thickness(left: 0, top: 0, right: 0, bottom: 0)
        checkbox.onToggle = onChange
        environment.apply(to: checkbox)
    }

    public func setState(ofCheckbox checkboxWidget: Widget, to state: Bool) {
        let checkboxWidget = checkboxWidget as! CustomCheckBox
        if checkboxWidget.isChecked != state {
            checkboxWidget.isChecked = state
        }
    }
}
