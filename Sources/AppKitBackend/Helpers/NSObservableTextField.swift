import AppKit

class NSObservableTextField: NSTextField {
    override func textDidChange(_ notification: Notification) {
        onEdit?(self)
    }

    @objc func runOnSubmitAction() {
        _onSubmitAction()
    }

    var onEdit: ((NSTextField) -> Void)?
    var _onSubmitAction = {}
    var onSubmit: () -> Void {
        get {
            _onSubmitAction
        }
        set {
            _onSubmitAction = newValue
            action = #selector(runOnSubmitAction)
            target = self
        }
    }
}
