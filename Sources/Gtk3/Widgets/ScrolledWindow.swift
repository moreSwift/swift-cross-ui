import CGtk3

public class ScrolledWindow: Bin {
    public convenience init() {
        self.init(gtk_scrolled_window_new(nil, nil))
    }

    @GObjectProperty(named: "min-content-width") public var minimumContentWidth: Int
    @GObjectProperty(named: "max-content-width") public var maximumContentWidth: Int

    @GObjectProperty(named: "min-content-height") public var minimumContentHeight: Int
    @GObjectProperty(named: "max-content-height") public var maximumContentHeight: Int

    @GObjectProperty(named: "propagate-natural-height") public var propagateNaturalHeight: Bool
    @GObjectProperty(named: "propagate-natural-width") public var propagateNaturalWidth: Bool

    public func setScrollBarPresence(hasVerticalScrollBar: Bool, hasHorizontalScrollBar: Bool) {
        gtk_scrolled_window_set_policy(
            castedPointer(),
            hasHorizontalScrollBar ? GTK_POLICY_AUTOMATIC : GTK_POLICY_NEVER,
            hasVerticalScrollBar ? GTK_POLICY_AUTOMATIC : GTK_POLICY_NEVER
        )
    }
}
