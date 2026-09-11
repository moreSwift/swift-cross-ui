import AppKit

/// A scroll view with scrolling gestures disabled. Used as a dummy scroll view to
/// allow us to properly set the width of NSTableView (had some weird issues).
final class NSDisabledScrollView: NSScrollView {
    override func scrollWheel(with event: NSEvent) {
        self.nextResponder?.scrollWheel(with: event)
    }
}
