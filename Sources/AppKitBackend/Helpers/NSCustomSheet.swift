import AppKit

public final class NSCustomSheet: NSCustomWindow, NSWindowDelegate {
    public var onDismiss: (() -> Void)?

    public var interactiveDismissDisabled: Bool = false

    public var backgroundView: NSView?

    @objc override public func cancelOperation(_ sender: Any?) {
        if !interactiveDismissDisabled {
            sheetParent?.endSheet(self)
            onDismiss?()
        }
    }
}
