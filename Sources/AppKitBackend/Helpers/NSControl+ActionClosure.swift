import AppKit

// Source: https://gist.github.com/sindresorhus/3580ce9426fff8fafb1677341fca4815
extension NSControl {
    typealias ActionClosure = ((NSControl) -> Void)
    typealias EditClosure = ((NSTextField) -> Void)

    @MainActor
    struct AssociatedKeys {
        static let onActionClosure = ObjectAssociation<ActionClosure>()
        static let onEditClosure = ObjectAssociation<EditClosure>()
    }

    @objc
    func callClosure(_ sender: NSControl) {
        onAction?(sender)
    }

    var onAction: ActionClosure? {
        get {
            return AssociatedKeys.onActionClosure[self]
        }
        set {
            AssociatedKeys.onActionClosure[self] = newValue
            action = #selector(callClosure)
            target = self
        }
    }
}
