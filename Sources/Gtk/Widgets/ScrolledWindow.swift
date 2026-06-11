import CGtk

public class ScrolledWindow: Widget {
    var child: Widget?

    public convenience init() {
        self.init(gtk_scrolled_window_new())
    }

    @GObjectProperty(named: "min-content-width") public var minimumContentWidth: Int
    @GObjectProperty(named: "max-content-width") public var maximumContentWidth: Int

    @GObjectProperty(named: "min-content-height") public var minimumContentHeight: Int
    @GObjectProperty(named: "max-content-height") public var maximumContentHeight: Int

    @GObjectProperty(named: "propagate-natural-height") public var propagateNaturalHeight: Bool
    @GObjectProperty(named: "propagate-natural-width") public var propagateNaturalWidth: Bool

    public func setScrollBarPresence(hasVerticalScrollBar: Bool, hasHorizontalScrollBar: Bool) {
        gtk_scrolled_window_set_policy(
            opaquePointer,
            hasHorizontalScrollBar ? GTK_POLICY_AUTOMATIC : GTK_POLICY_NEVER,
            hasVerticalScrollBar ? GTK_POLICY_AUTOMATIC : GTK_POLICY_NEVER
        )
    }

    public func setChild(_ child: Widget) {
        self.child?.parentWidget = nil
        self.child = child
        gtk_scrolled_window_set_child(opaquePointer, child.widgetPointer)
        child.parentWidget = self
    }

    public func removeChild() {
        gtk_scrolled_window_set_child(opaquePointer, nil)
        child?.parentWidget = nil
        child = nil
    }

    public func getChild() -> Widget? {
        return child
    }
}
