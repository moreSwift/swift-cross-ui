import AppKit

// TODO: Update all controls to use this style of action passing, seems way nicer
//   than the existing associated keys based approach. And probably more efficient too.
// Source: https://stackoverflow.com/a/36983811
final class Action: NSObject {
    var action: () -> Void

    init(_ action: @escaping () -> Void) {
        self.action = action
        super.init()
    }

    @objc func run() {
        action()
    }
}
