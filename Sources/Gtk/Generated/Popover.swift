import CGtk

/// Presents a bubble-like popup.
///
/// <picture><source srcset="popover-dark.png" media="(prefers-color-scheme: dark)"><img alt="An example GtkPopover" src="popover.png"></picture>
///
/// It is primarily meant to provide context-dependent information
/// or options. Popovers are attached to a parent widget. By default,
/// they point to the whole widget area, although this behavior can be
/// changed with [method@Gtk.Popover.set_pointing_to].
///
/// The position of a popover relative to the widget it is attached to
/// can also be changed with [method@Gtk.Popover.set_position]
///
/// By default, `GtkPopover` performs a grab, in order to ensure input
/// events get redirected to it while it is shown, and also so the popover
/// is dismissed in the expected situations (clicks outside the popover,
/// or the Escape key being pressed). If no such modal behavior is desired
/// on a popover, [method@Gtk.Popover.set_autohide] may be called on it to
/// tweak its behavior.
///
/// ## GtkPopover as menu replacement
///
/// `GtkPopover` is often used to replace menus. The best way to do this
/// is to use the [class@Gtk.PopoverMenu] subclass which supports being
/// populated from a `GMenuModel` with [ctor@Gtk.PopoverMenu.new_from_model].
///
/// ```xml
/// <section><attribute name="display-hint">horizontal-buttons</attribute><item><attribute name="label">Cut</attribute><attribute name="action">app.cut</attribute><attribute name="verb-icon">edit-cut-symbolic</attribute></item><item><attribute name="label">Copy</attribute><attribute name="action">app.copy</attribute><attribute name="verb-icon">edit-copy-symbolic</attribute></item><item><attribute name="label">Paste</attribute><attribute name="action">app.paste</attribute><attribute name="verb-icon">edit-paste-symbolic</attribute></item></section>
/// ```
///
/// # Shortcuts and Gestures
///
/// `GtkPopover` supports the following keyboard shortcuts:
///
/// - <kbd>Escape</kbd> closes the popover.
/// - <kbd>Alt</kbd> makes the mnemonics visible.
///
/// The following signals have default keybindings:
///
/// - [signal@Gtk.Popover::activate-default]
///
/// # CSS nodes
///
/// ```
/// popover.background[.menu]
/// ├── arrow
/// ╰── contents
/// ╰── <child>
/// ```
///
/// `GtkPopover` has a main node with name `popover`, an arrow with name `arrow`,
/// and another node for the content named `contents`. The `popover` node always
/// gets the `.background` style class. It also gets the `.menu` style class
/// if the popover is menu-like, e.g. is a [class@Gtk.PopoverMenu].
///
/// Particular uses of `GtkPopover`, such as touch selection popups or
/// magnifiers in `GtkEntry` or `GtkTextView` get style classes like
/// `.touch-selection` or `.magnifier` to differentiate from plain popovers.
///
/// When styling a popover directly, the `popover` node should usually
/// not have any background. The visible part of the popover can have
/// a shadow. To specify it in CSS, set the box-shadow of the `contents` node.
///
/// Note that, in order to accomplish appropriate arrow visuals, `GtkPopover`
/// uses custom drawing for the `arrow` node. This makes it possible for the
/// arrow to change its shape dynamically, but it also limits the possibilities
/// of styling it using CSS. In particular, the `arrow` gets drawn over the
/// `content` node's border and shadow, so they look like one shape, which
/// means that the border width of the `content` node and the `arrow` node should
/// be the same. The arrow also does not support any border shape other than
/// solid, no border-radius, only one border width (border-bottom-width is
/// used) and no box-shadow.
open class Popover: Widget, Native, ShortcutManager {
    /// Creates a new `GtkPopover`.
    public convenience init() {
        self.init(
            gtk_popover_new()
        )
    }

    open override func didMoveToParent() {
        super.didMoveToParent()

        addSignal(name: "activate-default") { [weak self] () in
            guard let self else { return }
            self.activateDefault?(self)
        }

        addSignal(name: "closed") { [weak self] () in
            guard let self else { return }
            self.closed?(self)
        }

        let handler2:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::autohide", handler: gCallback(handler2)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyAutohide?(self, param0)
        }

        let handler3:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::cascade-popdown", handler: gCallback(handler3)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyCascadePopdown?(self, param0)
        }

        let handler4:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::child", handler: gCallback(handler4)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyChild?(self, param0)
        }

        let handler5:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::default-widget", handler: gCallback(handler5)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyDefaultWidget?(self, param0)
        }

        let handler6:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::has-arrow", handler: gCallback(handler6)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyHasArrow?(self, param0)
        }

        let handler7:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::mnemonics-visible", handler: gCallback(handler7)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyMnemonicsVisible?(self, param0)
        }

        let handler8:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::pointing-to", handler: gCallback(handler8)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyPointingTo?(self, param0)
        }

        let handler9:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::position", handler: gCallback(handler9)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyPosition?(self, param0)
        }
    }

    /// Whether to dismiss the popover on outside clicks.
    @GObjectProperty(named: "autohide") public var autohide: Bool

    /// Whether the popover pops down after a child popover.
    ///
    /// This is used to implement the expected behavior of submenus.
    @GObjectProperty(named: "cascade-popdown") public var cascadePopdown: Bool

    /// Whether to draw an arrow.
    @GObjectProperty(named: "has-arrow") public var hasArrow: Bool

    /// Whether mnemonics are currently visible in this popover.
    @GObjectProperty(named: "mnemonics-visible") public var mnemonicsVisible: Bool

    /// How to place the popover, relative to its parent.
    @GObjectProperty(named: "position") public var position: PositionType

    /// Emitted whend the user activates the default widget.
    ///
    /// This is a [keybinding signal](class.SignalAction.html).
    ///
    /// The default binding for this signal is <kbd>Enter</kbd>.
    public var activateDefault: ((Popover) -> Void)?

    /// Emitted when the popover is closed.
    public var closed: ((Popover) -> Void)?

    public var notifyAutohide: ((Popover, OpaquePointer) -> Void)?

    public var notifyCascadePopdown: ((Popover, OpaquePointer) -> Void)?

    public var notifyChild: ((Popover, OpaquePointer) -> Void)?

    public var notifyDefaultWidget: ((Popover, OpaquePointer) -> Void)?

    public var notifyHasArrow: ((Popover, OpaquePointer) -> Void)?

    public var notifyMnemonicsVisible: ((Popover, OpaquePointer) -> Void)?

    public var notifyPointingTo: ((Popover, OpaquePointer) -> Void)?

    public var notifyPosition: ((Popover, OpaquePointer) -> Void)?
}
