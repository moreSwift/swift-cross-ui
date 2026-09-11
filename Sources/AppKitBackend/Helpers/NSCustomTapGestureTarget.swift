import AppKit

final class NSCustomTapGestureTarget: NSView {
    var leftClickHandler: (() -> Void)? {
        didSet {
            if leftClickHandler != nil && leftClickRecognizer == nil {
                let gestureRecognizer = NSClickGestureRecognizer(
                    target: self,
                    action: #selector(leftClick)
                )
                addGestureRecognizer(gestureRecognizer)
                leftClickRecognizer = gestureRecognizer
            } else if leftClickHandler == nil, let leftClickRecognizer {
                removeGestureRecognizer(leftClickRecognizer)
                self.leftClickRecognizer = nil
            }
        }
    }

    var rightClickHandler: (() -> Void)? {
        didSet {
            if rightClickHandler != nil && rightClickRecognizer == nil {
                let gestureRecognizer = NSClickGestureRecognizer(
                    target: self,
                    action: #selector(rightClick)
                )
                gestureRecognizer.buttonMask = 1 << 1
                addGestureRecognizer(gestureRecognizer)
                rightClickRecognizer = gestureRecognizer
            } else if rightClickHandler == nil, let rightClickRecognizer {
                removeGestureRecognizer(rightClickRecognizer)
                self.rightClickRecognizer = nil
            }
        }
    }

    var longPressHandler: (() -> Void)? {
        didSet {
            if longPressHandler != nil && longPressRecognizer == nil {
                let gestureRecognizer = NSPressGestureRecognizer(
                    target: self,
                    action: #selector(longPress)
                )
                // Both GTK and UIKit default to half a second for long presses
                gestureRecognizer.minimumPressDuration = 0.5
                addGestureRecognizer(gestureRecognizer)
                longPressRecognizer = gestureRecognizer
            } else if longPressHandler == nil, let longPressRecognizer {
                removeGestureRecognizer(longPressRecognizer)
                self.longPressRecognizer = nil
            }
        }
    }

    private var leftClickRecognizer: NSClickGestureRecognizer?
    private var rightClickRecognizer: NSClickGestureRecognizer?
    private var longPressRecognizer: NSPressGestureRecognizer?

    @objc
    func leftClick() {
        leftClickHandler?()
    }

    @objc
    func rightClick() {
        rightClickHandler?()
    }

    @objc
    func longPress(sender: NSPressGestureRecognizer) {
        // GTK emits the event once as soon as the gesture is recognized.
        // AppKit emits it twice, once when it's recognized and once when you release the mouse button.
        // For consistency, ignore the second event.
        if sender.state != .ended {
            longPressHandler?()
        }
    }
}
