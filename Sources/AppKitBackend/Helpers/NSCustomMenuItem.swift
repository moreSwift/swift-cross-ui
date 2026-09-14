import AppKit

final class NSCustomMenuItem: NSMenuItem {    
    var actionCallback: (() -> Void)?
    
    @objc func runAction() {
        actionCallback?()
    }

    var isOn: Bool {
        get { state == .on }
        set { state = newValue ? .on : .off }
    }
}
