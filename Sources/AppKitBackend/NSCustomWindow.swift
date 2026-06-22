import AppKit
import SwiftCrossUI

public class NSCustomWindow: NSWindow, FocusChainManager {
    public typealias Widget = AppKitBackend.Widget

    var customDelegate = Delegate()
    var persistentUndoManager = UndoManager()

    /// A reference to the sheet currently presented on top of this window, if any.
    /// If the sheet itself has another sheet presented on top of it, then that doubly
    /// nested sheet gets stored as the sheet's nestedSheet, and so on.
    var nestedSheet: NSCustomSheet?

    var lastBackingScaleFactor: CGFloat?
    /// Allows the backing scale factor to be overridden. Useful for keeping
    /// UI tests consistent across devices.
    ///
    /// Idea from https://github.com/pointfreeco/swift-snapshot-testing/pull/533
    public var backingScaleFactorOverride: CGFloat?

    public override var backingScaleFactor: CGFloat {
        backingScaleFactorOverride ?? super.backingScaleFactor
    }

    class Delegate: NSObject, NSWindowDelegate {
        var resizeHandler: ((SIMD2<Int>) -> Void)?
        var closeHandler: (() -> Void)?

        func setResizeHandler(_ resizeHandler: @escaping (SIMD2<Int>) -> Void) {
            self.resizeHandler = resizeHandler
        }

        func setCloseHandler(_ closeHandler: @escaping () -> Void) {
            self.closeHandler = closeHandler
        }

        func windowWillClose(_ notification: Notification) {
            closeHandler?()

            guard let window = notification.object as? NSCustomWindow else { return }

            // Not sure if this is actually needed
            NotificationCenter.default.removeObserver(window)
        }

        func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
            guard let resizeHandler else {
                return frameSize
            }

            let contentSize = sender.contentRect(
                forFrameRect: NSRect(
                    x: sender.frame.origin.x,
                    y: sender.frame.origin.y,
                    width: frameSize.width,
                    height: frameSize.height
                )
            )

            resizeHandler(
                SIMD2(
                    Int(contentSize.width.rounded(.towardZero)),
                    Int(contentSize.height.rounded(.towardZero))
                )
            )

            return frameSize
        }

        func windowWillReturnUndoManager(_ window: NSWindow) -> UndoManager? {
            (window as! NSCustomWindow).persistentUndoManager
        }
    }

    // MARK: - AppKit FocusChain handling -

    override public var initialFirstResponder: NSView? {
        get {
            guard let responder = super.initialFirstResponder else {
                return nil
            }
            // Doing this in set doesn't work for some reason.
            // set gets called first, sets the value but its nil for the get
            // directly after. Doing it here instead works.
            return findNextAllowedFocusTarget(suggestion: responder)
        }
        set {
            super.initialFirstResponder = newValue
        }
    }

    override public func selectKeyView(following view: NSView) {
        selectTabStop(following: view)
    }

    override public func selectKeyView(preceding view: NSView) {
        selectTabStop(preceding: view)
    }

    // MARK: - FocusChainManager implementation -

    public func closestValidStop(following view: Widget) -> Widget? {
        view.nextValidKeyView
    }

    public func closestValidStop(preceding view: Widget) -> Widget? {
        view.previousValidKeyView
    }

    public func makeKey(_ widget: Widget) {
        makeFirstResponder(widget)
    }

    public func getParent(of widget: Widget) -> Widget? {
        widget.superview
    }
}

extension NSView: FocusChainParticipant {
    public var canBeTabStop: Bool {
        canBecomeKeyView
    }
}
