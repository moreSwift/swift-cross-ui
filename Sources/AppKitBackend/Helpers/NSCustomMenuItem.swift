import AppKit

final class NSCustomMenuItem: NSMenuItem {
    /// This property's only purpose is to keep a strong reference to the wrapped
    /// action so that it sticks around for long enough to be useful.
    var actionWrapper: Action?

    var isOn: Bool {
        get { state == .on }
        set { state = newValue ? .on : .off }
    }
}
