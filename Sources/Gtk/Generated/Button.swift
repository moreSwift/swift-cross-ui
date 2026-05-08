import CGtk

/// Calls a callback function when the button is clicked.
///
/// <picture><source srcset="button-dark.png" media="(prefers-color-scheme: dark)"><img alt="An example GtkButton" src="button.png"></picture>
///
/// The `GtkButton` widget can hold any valid child widget. That is, it can hold
/// almost any other standard `GtkWidget`. The most commonly used child is the
/// `GtkLabel`.
///
/// # Shortcuts and Gestures
///
/// The following signals have default keybindings:
///
/// - [signal@Gtk.Button::activate]
///
/// # CSS nodes
///
/// `GtkButton` has a single CSS node with name button. The node will get the
/// style classes .image-button or .text-button, if the content is just an
/// image or label, respectively. It may also receive the .flat style class.
/// When activating a button via the keyboard, the button will temporarily
/// gain the .keyboard-activating style class.
///
/// Other style classes that are commonly used with `GtkButton` include
/// .suggested-action and .destructive-action. In special cases, buttons
/// can be made round by adding the .circular style class.
///
/// Button-like widgets like [class@Gtk.ToggleButton], [class@Gtk.MenuButton],
/// [class@Gtk.VolumeButton], [class@Gtk.LockButton], [class@Gtk.ColorButton]
/// or [class@Gtk.FontButton] use style classes such as .toggle, .popup, .scale,
/// .lock, .color on the button node to differentiate themselves from a plain
/// `GtkButton`.
///
/// # Accessibility
///
/// `GtkButton` uses the [enum@Gtk.AccessibleRole.button] role.
open class Button: Widget, Actionable {
    /// Creates a new `GtkButton` widget.
    ///
    /// To add a child widget to the button, use [method@Gtk.Button.set_child].
    public convenience init() {
        self.init(
            gtk_button_new()
        )
    }

    /// Creates a new button containing an icon from the current icon theme.
    ///
    /// If the icon name isn’t known, a “broken image” icon will be
    /// displayed instead. If the current icon theme is changed, the icon
    /// will be updated appropriately.
    public convenience init(iconName: String) {
        self.init(
            gtk_button_new_from_icon_name(iconName)
        )
    }

    /// Creates a `GtkButton` widget with a `GtkLabel` child.
    public convenience init(label: String) {
        self.init(
            gtk_button_new_with_label(label)
        )
    }

    /// Creates a new `GtkButton` containing a label.
    ///
    /// If characters in @label are preceded by an underscore, they are underlined.
    /// If you need a literal underscore character in a label, use “__” (two
    /// underscores). The first underlined character represents a keyboard
    /// accelerator called a mnemonic. Pressing <kbd>Alt</kbd> and that key
    /// activates the button.
    public convenience init(mnemonic label: String) {
        self.init(
            gtk_button_new_with_mnemonic(label)
        )
    }

    open override func didMoveToParent() {
        super.didMoveToParent()

        addSignal(name: "activate") { [weak self] () in
            guard let self else { return }
            self.activate?(self)
        }

        addSignal(name: "clicked") { [weak self] () in
            guard let self else { return }
            self.clicked?(self)
        }

        let handler2:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::can-shrink", handler: gCallback(handler2)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyCanShrink?(self, param0)
        }

        let handler3:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::child", handler: gCallback(handler3)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyChild?(self, param0)
        }

        let handler4:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::has-frame", handler: gCallback(handler4)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyHasFrame?(self, param0)
        }

        let handler5:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::icon-name", handler: gCallback(handler5)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyIconName?(self, param0)
        }

        let handler6:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::label", handler: gCallback(handler6)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyLabel?(self, param0)
        }

        let handler7:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::use-underline", handler: gCallback(handler7)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyUseUnderline?(self, param0)
        }

        let handler8:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::action-name", handler: gCallback(handler8)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyActionName?(self, param0)
        }

        let handler9:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::action-target", handler: gCallback(handler9)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyActionTarget?(self, param0)
        }
    }

    /// Whether the button has a frame.
    @GObjectProperty(named: "has-frame") public var hasFrame: Bool

    /// The name of the icon used to automatically populate the button.
    @GObjectProperty(named: "icon-name") public var iconName: String?

    /// Text of the label inside the button, if the button contains a label widget.
    @GObjectProperty(named: "label") public var label: String?

    /// If set, an underline in the text indicates that the following character is
    /// to be used as mnemonic.
    @GObjectProperty(named: "use-underline") public var useUnderline: Bool

    /// The name of the action with which this widget should be associated.
    @GObjectProperty(named: "action-name") public var actionName: String?

    /// Emitted to animate press then release.
    ///
    /// This is an action signal. Applications should never connect
    /// to this signal, but use the [signal@Gtk.Button::clicked] signal.
    ///
    /// The default bindings for this signal are all forms of the
    /// <kbd>␣</kbd> and <kbd>Enter</kbd> keys.
    public var activate: ((Button) -> Void)?

    /// Emitted when the button has been activated (pressed and released).
    public var clicked: ((Button) -> Void)?

    public var notifyCanShrink: ((Button, OpaquePointer) -> Void)?

    public var notifyChild: ((Button, OpaquePointer) -> Void)?

    public var notifyHasFrame: ((Button, OpaquePointer) -> Void)?

    public var notifyIconName: ((Button, OpaquePointer) -> Void)?

    public var notifyLabel: ((Button, OpaquePointer) -> Void)?

    public var notifyUseUnderline: ((Button, OpaquePointer) -> Void)?

    public var notifyActionName: ((Button, OpaquePointer) -> Void)?

    public var notifyActionTarget: ((Button, OpaquePointer) -> Void)?
}
