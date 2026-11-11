import AppKit

class NSObservableTextView: NSTextView, NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        onEdit?(self)
    }

    var onEdit: ((NSTextView) -> Void)?
}
