import WinUI

class CustomCheckBox: WinUI.CheckBox {
    var onToggle: ((Bool) -> Void)?

    func handleToggle() {
        if isChecked == nil {
            logger.warning("checkbox in limbo")
        }
        onToggle?(isChecked ?? false)
    }
}
