import CGtk

public class ScrolledWindow: Widget {
    var child: Widget?

    /// Stick-to-bottom anchoring for streaming content. While enabled, the
    /// view stays pinned to the newest content as it grows when the scrollbar
    /// was within range of the bottom before the growth; scrolling up
    /// releases the pin, and scrolling back near the bottom re-engages it on
    /// the next growth. Off by default; opt in per scroll view via the
    /// `scrollAnchorsToBottom` environment value.
    public var anchorsToBottom = false {
        didSet { installBottomAnchor() }
    }
    /// The adjustment's `upper` as of the last change; compared against the
    /// pre-change scroll geometry to decide whether the user was at the
    /// bottom when new content arrived.
    private var lastUpper = 0.0
    private var bottomAnchorInstalled = false

    private func installBottomAnchor() {
        guard !bottomAnchorInstalled, let adjustment = gtk_scrolled_window_get_vadjustment(opaquePointer)
        else { return }
        bottomAnchorInstalled = true
        let onChanged: @convention(c) (OpaquePointer?, UnsafeMutableRawPointer?) -> Void = { _, data in
            guard let data else { return }
            let owner = Unmanaged<ScrolledWindow>.fromOpaque(data).takeUnretainedValue()
            owner.snapToBottomIfAnchored()
        }
        // Retained: one box per scroll container, outlives the signals.
        let box = Unmanaged.passRetained(self).toOpaque()
        g_signal_connect_data(adjustment, "changed", unsafeBitCast(onChanged, to: GCallback.self), box, nil, GConnectFlags(rawValue: 0))
    }

    /// Distance from the bottom that still counts as "at the bottom".
    private static let bottomSlack = 120.0

    private func snapToBottomIfAnchored() {
        guard let adjustment = gtk_scrolled_window_get_vadjustment(opaquePointer) else { return }
        let value = gtk_adjustment_get_value(adjustment)
        let pageSize = gtk_adjustment_get_page_size(adjustment)
        let upper = gtk_adjustment_get_upper(adjustment)
        // Read the pre-change geometry before updating lastUpper: when GTK
        // coalesces two growths into one signal, writing first would make a
        // scrolled-up user look "at bottom" and get yanked down.
        let wasAtBottom = value + pageSize >= lastUpper - Self.bottomSlack
        lastUpper = upper
        guard anchorsToBottom, wasAtBottom, upper > pageSize else { return }
        let target = upper - pageSize
        if abs(gtk_adjustment_get_value(adjustment) - target) > 1 {
            gtk_adjustment_set_value(adjustment, target)
        }
    }

    public convenience init() {
        self.init(gtk_scrolled_window_new())
    }

    open override func didMoveToParent() {
        super.didMoveToParent()
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
