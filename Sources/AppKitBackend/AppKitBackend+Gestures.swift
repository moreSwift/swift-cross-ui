import AppKit
import SwiftCrossUI

extension AppKitBackend {
    public func createTapGestureTarget(wrapping child: Widget, gesture _: TapGesture) -> Widget {
        let container = NSView()

        container.addSubview(child)
        child.leadingAnchor.constraint(equalTo: container.leadingAnchor)
            .isActive = true
        child.topAnchor.constraint(equalTo: container.topAnchor)
            .isActive = true
        child.translatesAutoresizingMaskIntoConstraints = false

        let tapGestureTarget = NSCustomTapGestureTarget()
        container.addSubview(tapGestureTarget)
        tapGestureTarget.leadingAnchor.constraint(equalTo: container.leadingAnchor)
            .isActive = true
        tapGestureTarget.topAnchor.constraint(equalTo: container.topAnchor)
            .isActive = true
        tapGestureTarget.trailingAnchor.constraint(equalTo: container.trailingAnchor)
            .isActive = true
        tapGestureTarget.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            .isActive = true
        tapGestureTarget.translatesAutoresizingMaskIntoConstraints = false

        return container
    }

    public func updateTapGestureTarget(
        _ container: Widget,
        gesture: TapGesture,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        let tapGestureTarget = container.subviews[1] as! NSCustomTapGestureTarget
        switch (gesture.kind, environment.isEnabled) {
            case (_, false):
                tapGestureTarget.leftClickHandler = nil
                tapGestureTarget.rightClickHandler = nil
                tapGestureTarget.longPressHandler = nil
            case (.primary, true):
                tapGestureTarget.leftClickHandler = action
                tapGestureTarget.rightClickHandler = nil
                tapGestureTarget.longPressHandler = nil
            case (.secondary, true):
                tapGestureTarget.leftClickHandler = nil
                tapGestureTarget.rightClickHandler = action
                tapGestureTarget.longPressHandler = nil
            case (.longPress, true):
                tapGestureTarget.leftClickHandler = nil
                tapGestureTarget.rightClickHandler = nil
                tapGestureTarget.longPressHandler = action
        }
    }

    public func createHoverTarget(wrapping child: Widget) -> Widget {
        let container = NSView()

        container.addSubview(child)
        child.leadingAnchor.constraint(equalTo: container.leadingAnchor)
            .isActive = true
        child.topAnchor.constraint(equalTo: container.topAnchor)
            .isActive = true
        child.translatesAutoresizingMaskIntoConstraints = false

        let hoverGestureTarget = NSCustomHoverTarget()
        container.addSubview(hoverGestureTarget)
        hoverGestureTarget.leadingAnchor.constraint(equalTo: container.leadingAnchor)
            .isActive = true
        hoverGestureTarget.topAnchor.constraint(equalTo: container.topAnchor)
            .isActive = true
        hoverGestureTarget.trailingAnchor.constraint(equalTo: container.trailingAnchor)
            .isActive = true
        hoverGestureTarget.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            .isActive = true
        hoverGestureTarget.translatesAutoresizingMaskIntoConstraints = false

        return container
    }

    public func updateHoverTarget(
        _ container: Widget,
        environment: EnvironmentValues,
        action: @escaping (Bool) -> Void
    ) {
        let hoverGestureTarget = container.subviews[1] as! NSCustomHoverTarget
        hoverGestureTarget.hoverChangesHandler = action
    }
}

final class NSCustomTapGestureTarget: NSView {
    var leftClickHandler: (() -> Void)? {
        didSet {
            if leftClickHandler != nil && leftClickRecognizer == nil {
                let gestureRecognizer = NSClickGestureRecognizer(
                    target: self, action: #selector(leftClick))
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
                    target: self, action: #selector(rightClick))
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
                    target: self, action: #selector(longPress))
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

final class NSCustomHoverTarget: NSView {
    var hoverChangesHandler: ((Bool) -> Void)? {
        didSet {
            if hoverChangesHandler != nil && trackingArea == nil {
                setNewTrackingArea()
            } else if hoverChangesHandler == nil, let trackingArea {
                removeTrackingArea(trackingArea)
                self.trackingArea = nil
            }
        }
    }

    private var trackingArea: NSTrackingArea?

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingArea {
            self.removeTrackingArea(trackingArea)
        }
        setNewTrackingArea()
    }

    override func mouseEntered(with event: NSEvent) {
        hoverChangesHandler?(true)
    }

    override func mouseExited(with event: NSEvent) {
        hoverChangesHandler?(false)
    }

    private func setNewTrackingArea() {
        let options: NSTrackingArea.Options = [
            .mouseEnteredAndExited,
            .activeInKeyWindow,
        ]
        let area = NSTrackingArea(
            rect: self.bounds,
            options: options,
            owner: self,
            userInfo: nil)
        addTrackingArea(area)
        trackingArea = area
    }
}
