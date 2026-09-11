import AppKit

class NSObservableSecureTextField: NSSecureTextField {
    override func textDidChange(_ notification: Notification) {
        onEdit?(self)
    }

    var onEdit: ((NSSecureTextField) -> Void)?
    var _onSubmitAction = Action({})
    var onSubmit: () -> Void {
        get {
            _onSubmitAction.action
        }
        set {
            _onSubmitAction.action = newValue
            action = #selector(_onSubmitAction.run)
            target = _onSubmitAction
        }
    }
}
