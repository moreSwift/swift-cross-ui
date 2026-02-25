import CGtk

/// Allows to enter or change numeric values.
///
/// <picture><source srcset="spinbutton-dark.png" media="(prefers-color-scheme: dark)"><img alt="An example GtkSpinButton" src="spinbutton.png"></picture>
///
/// Rather than having to directly type a number into a `GtkEntry`,
/// `GtkSpinButton` allows the user to click on one of two arrows
/// to increment or decrement the displayed value. A value can still be
/// typed in, with the bonus that it can be checked to ensure it is in a
/// given range.
///
/// The main properties of a `GtkSpinButton` are through an adjustment.
/// See the [class@Gtk.Adjustment] documentation for more details about
/// an adjustment's properties.
///
/// Note that `GtkSpinButton` will by default make its entry large enough
/// to accommodate the lower and upper bounds of the adjustment. If this
/// is not desired, the automatic sizing can be turned off by explicitly
/// setting [property@Gtk.Editable:width-chars] to a value != -1.
///
/// ## Using a GtkSpinButton to get an integer
///
/// ```c
/// // Provides a function to retrieve an integer value from a GtkSpinButton
/// // and creates a spin button to model percentage values.
///
/// int
/// grab_int_value (GtkSpinButton *button,
/// gpointer       user_data)
/// {
/// return gtk_spin_button_get_value_as_int (button);
/// }
///
/// void
/// create_integer_spin_button (void)
/// {
///
/// GtkWidget *window, *button;
/// GtkAdjustment *adjustment;
///
/// adjustment = gtk_adjustment_new (50.0, 0.0, 100.0, 1.0, 5.0, 0.0);
///
/// window = gtk_window_new ();
///
/// // creates the spinbutton, with no decimal places
/// button = gtk_spin_button_new (adjustment, 1.0, 0);
/// gtk_window_set_child (GTK_WINDOW (window), button);
///
/// gtk_window_present (GTK_WINDOW (window));
/// }
/// ```
///
/// ## Using a GtkSpinButton to get a floating point value
///
/// ```c
/// // Provides a function to retrieve a floating point value from a
/// // GtkSpinButton, and creates a high precision spin button.
///
/// float
/// grab_float_value (GtkSpinButton *button,
/// gpointer       user_data)
/// {
/// return gtk_spin_button_get_value (button);
/// }
///
/// void
/// create_floating_spin_button (void)
/// {
/// GtkWidget *window, *button;
/// GtkAdjustment *adjustment;
///
/// adjustment = gtk_adjustment_new (2.500, 0.0, 5.0, 0.001, 0.1, 0.0);
///
/// window = gtk_window_new ();
///
/// // creates the spinbutton, with three decimal places
/// button = gtk_spin_button_new (adjustment, 0.001, 3);
/// gtk_window_set_child (GTK_WINDOW (window), button);
///
/// gtk_window_present (GTK_WINDOW (window));
/// }
/// ```
///
/// # Shortcuts and Gestures
///
/// The following signals have default keybindings:
///
/// - [signal@Gtk.SpinButton::change-value]
///
/// # CSS nodes
///
/// ```
/// spinbutton.horizontal
/// ├── text
/// │    ├── undershoot.left
/// │    ╰── undershoot.right
/// ├── button.down
/// ╰── button.up
/// ```
///
/// ```
/// spinbutton.vertical
/// ├── button.up
/// ├── text
/// │    ├── undershoot.left
/// │    ╰── undershoot.right
/// ╰── button.down
/// ```
///
/// `GtkSpinButton`s main CSS node has the name spinbutton. It creates subnodes
/// for the entry and the two buttons, with these names. The button nodes have
/// the style classes .up and .down. The `GtkText` subnodes (if present) are put
/// below the text node. The orientation of the spin button is reflected in
/// the .vertical or .horizontal style class on the main node.
///
/// # Accessibility
///
/// `GtkSpinButton` uses the [enum@Gtk.AccessibleRole.spin_button] role.
open class SpinButton: Widget, CellEditable, Editable, Orientable {
    /// Creates a new `GtkSpinButton`.
    public convenience init(
        adjustment: UnsafeMutablePointer<GtkAdjustment>!, climbRate: Double, digits: UInt
    ) {
        self.init(
            gtk_spin_button_new(adjustment, climbRate, guint(digits))
        )
    }

    /// Creates a new `GtkSpinButton` with the given properties.
    ///
    /// This is a convenience constructor that allows creation
    /// of a numeric `GtkSpinButton` without manually creating
    /// an adjustment. The value is initially set to the minimum
    /// value and a page increment of 10 * @step is the default.
    /// The precision of the spin button is equivalent to the
    /// precision of @step.
    ///
    /// Note that the way in which the precision is derived works
    /// best if @step is a power of ten. If the resulting precision
    /// is not suitable for your needs, use
    /// [method@Gtk.SpinButton.set_digits] to correct it.
    public convenience init(range min: Double, max: Double, step: Double) {
        self.init(
            gtk_spin_button_new_with_range(min, max, step)
        )
    }

    open override func didMoveToParent() {
        super.didMoveToParent()

        addSignal(name: "activate") { [weak self] () in
            guard let self else { return }
            self.activate?(self)
        }

        let handler1:
            @convention(c) (UnsafeMutableRawPointer, GtkScrollType, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<GtkScrollType>.run(data, value1)
                }

        addSignal(name: "change-value", handler: gCallback(handler1)) {
            [weak self] (param0: GtkScrollType) in
            guard let self else { return }
            self.changeValue?(self, param0)
        }

        let handler2:
            @convention(c) (UnsafeMutableRawPointer, gpointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<gpointer>.run(data, value1)
                }

        addSignal(name: "input", handler: gCallback(handler2)) { [weak self] (param0: gpointer) in
            guard let self else { return }
            self.input?(self, param0)
        }

        addSignal(name: "output") { [weak self] () in
            guard let self else { return }
            self.output?(self)
        }

        addSignal(name: "value-changed") { [weak self] () in
            guard let self else { return }
            self.valueChanged?(self)
        }

        addSignal(name: "wrapped") { [weak self] () in
            guard let self else { return }
            self.wrapped?(self)
        }

        addSignal(name: "editing-done") { [weak self] () in
            guard let self else { return }
            self.editingDone?(self)
        }

        addSignal(name: "remove-widget") { [weak self] () in
            guard let self else { return }
            self.removeWidget?(self)
        }

        addSignal(name: "changed") { [weak self] () in
            guard let self else { return }
            self.changed?(self)
        }

        let handler9:
            @convention(c) (UnsafeMutableRawPointer, Int, Int, UnsafeMutableRawPointer) -> Void =
                { _, value1, value2, data in
                    SignalBox2<Int, Int>.run(data, value1, value2)
                }

        addSignal(name: "delete-text", handler: gCallback(handler9)) {
            [weak self] (param0: Int, param1: Int) in
            guard let self else { return }
            self.deleteText?(self, param0, param1)
        }

        let handler10:
            @convention(c) (
                UnsafeMutableRawPointer, UnsafePointer<CChar>, Int, gpointer,
                UnsafeMutableRawPointer
            ) -> Void =
                { _, value1, value2, value3, data in
                    SignalBox3<UnsafePointer<CChar>, Int, gpointer>.run(
                        data, value1, value2, value3)
                }

        addSignal(name: "insert-text", handler: gCallback(handler10)) {
            [weak self] (param0: UnsafePointer<CChar>, param1: Int, param2: gpointer) in
            guard let self else { return }
            self.insertText?(self, param0, param1, param2)
        }

        let handler11:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::activates-default", handler: gCallback(handler11)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyActivatesDefault?(self, param0)
        }

        let handler12:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::adjustment", handler: gCallback(handler12)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyAdjustment?(self, param0)
        }

        let handler13:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::climb-rate", handler: gCallback(handler13)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyClimbRate?(self, param0)
        }

        let handler14:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::digits", handler: gCallback(handler14)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyDigits?(self, param0)
        }

        let handler15:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::numeric", handler: gCallback(handler15)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyNumeric?(self, param0)
        }

        let handler16:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::snap-to-ticks", handler: gCallback(handler16)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifySnapToTicks?(self, param0)
        }

        let handler17:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::update-policy", handler: gCallback(handler17)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyUpdatePolicy?(self, param0)
        }

        let handler18:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::value", handler: gCallback(handler18)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyValue?(self, param0)
        }

        let handler19:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::wrap", handler: gCallback(handler19)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyWrap?(self, param0)
        }

        let handler20:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::editing-canceled", handler: gCallback(handler20)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyEditingCanceled?(self, param0)
        }

        let handler21:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::cursor-position", handler: gCallback(handler21)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyCursorPosition?(self, param0)
        }

        let handler22:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::editable", handler: gCallback(handler22)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyEditable?(self, param0)
        }

        let handler23:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::enable-undo", handler: gCallback(handler23)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyEnableUndo?(self, param0)
        }

        let handler24:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::max-width-chars", handler: gCallback(handler24)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyMaxWidthChars?(self, param0)
        }

        let handler25:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::selection-bound", handler: gCallback(handler25)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifySelectionBound?(self, param0)
        }

        let handler26:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::text", handler: gCallback(handler26)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyText?(self, param0)
        }

        let handler27:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::width-chars", handler: gCallback(handler27)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyWidthChars?(self, param0)
        }

        let handler28:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::xalign", handler: gCallback(handler28)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyXalign?(self, param0)
        }

        let handler29:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::orientation", handler: gCallback(handler29)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyOrientation?(self, param0)
        }
    }

    /// The acceleration rate when you hold down a button or key.
    @GObjectProperty(named: "climb-rate") public var climbRate: Double

    /// The number of decimal places to display.
    @GObjectProperty(named: "digits") public var digits: UInt

    /// Whether non-numeric characters should be ignored.
    @GObjectProperty(named: "numeric") public var numeric: Bool

    /// Whether erroneous values are automatically changed to the spin buttons
    /// nearest step increment.
    @GObjectProperty(named: "snap-to-ticks") public var snapToTicks: Bool

    /// Whether the spin button should update always, or only when the value
    /// is acceptable.
    @GObjectProperty(named: "update-policy") public var updatePolicy: SpinButtonUpdatePolicy

    /// The current value.
    @GObjectProperty(named: "value") public var value: Double

    /// Whether a spin button should wrap upon reaching its limits.
    @GObjectProperty(named: "wrap") public var wrap: Bool

    /// The current position of the insertion cursor in chars.
    @GObjectProperty(named: "cursor-position") public var cursorPosition: Int

    /// Whether the entry contents can be edited.
    @GObjectProperty(named: "editable") public var editable: Bool

    /// If undo/redo should be enabled for the editable.
    @GObjectProperty(named: "enable-undo") public var enableUndo: Bool

    /// The desired maximum width of the entry, in characters.
    @GObjectProperty(named: "max-width-chars") public var maxWidthChars: Int

    /// The contents of the entry.
    @GObjectProperty(named: "text") public var text: String

    /// Number of characters to leave space for in the entry.
    @GObjectProperty(named: "width-chars") public var widthChars: Int

    /// The horizontal alignment, from 0 (left) to 1 (right).
    ///
    /// Reversed for RTL layouts.
    @GObjectProperty(named: "xalign") public var xalign: Float

    /// The orientation of the orientable.
    @GObjectProperty(named: "orientation") public var orientation: Orientation

    /// Emitted when the spin button is activated.
    ///
    /// The keybindings for this signal are all forms of the <kbd>Enter</kbd> key.
    ///
    /// If the <kbd>Enter</kbd> key results in the value being committed to the
    /// spin button, then activation does not occur until <kbd>Enter</kbd> is
    /// pressed again.
    public var activate: ((SpinButton) -> Void)?

    /// Emitted when the user initiates a value change.
    ///
    /// This is a [keybinding signal](class.SignalAction.html).
    ///
    /// Applications should not connect to it, but may emit it with
    /// g_signal_emit_by_name() if they need to control the cursor
    /// programmatically.
    ///
    /// The default bindings for this signal are Up/Down and PageUp/PageDown.
    public var changeValue: ((SpinButton, GtkScrollType) -> Void)?

    /// Emitted to convert the users input into a double value.
    ///
    /// The signal handler is expected to use [method@Gtk.Editable.get_text]
    /// to retrieve the text of the spinbutton and set @new_value to the
    /// new value.
    ///
    /// The default conversion uses g_strtod().
    public var input: ((SpinButton, gpointer) -> Void)?

    /// Emitted to tweak the formatting of the value for display.
    ///
    /// ```c
    /// // show leading zeros
    /// static gboolean
    /// on_output (GtkSpinButton *spin,
    /// gpointer       data)
    /// {
    /// char *text;
    /// int value;
    ///
    /// value = gtk_spin_button_get_value_as_int (spin);
    /// text = g_strdup_printf ("%02d", value);
    /// gtk_editable_set_text (GTK_EDITABLE (spin), text):
    /// g_free (text);
    ///
    /// return TRUE;
    /// }
    /// ```
    public var output: ((SpinButton) -> Void)?

    /// Emitted when the value is changed.
    ///
    /// Also see the [signal@Gtk.SpinButton::output] signal.
    public var valueChanged: ((SpinButton) -> Void)?

    /// Emitted right after the spinbutton wraps from its maximum
    /// to its minimum value or vice-versa.
    public var wrapped: ((SpinButton) -> Void)?

    /// This signal is a sign for the cell renderer to update its
    /// value from the @cell_editable.
    ///
    /// Implementations of `GtkCellEditable` are responsible for
    /// emitting this signal when they are done editing, e.g.
    /// `GtkEntry` emits this signal when the user presses Enter. Typical things to
    /// do in a handler for ::editing-done are to capture the edited value,
    /// disconnect the @cell_editable from signals on the `GtkCellRenderer`, etc.
    ///
    /// gtk_cell_editable_editing_done() is a convenience method
    /// for emitting `GtkCellEditable::editing-done`.
    public var editingDone: ((SpinButton) -> Void)?

    /// This signal is meant to indicate that the cell is finished
    /// editing, and the @cell_editable widget is being removed and may
    /// subsequently be destroyed.
    ///
    /// Implementations of `GtkCellEditable` are responsible for
    /// emitting this signal when they are done editing. It must
    /// be emitted after the `GtkCellEditable::editing-done` signal,
    /// to give the cell renderer a chance to update the cell's value
    /// before the widget is removed.
    ///
    /// gtk_cell_editable_remove_widget() is a convenience method
    /// for emitting `GtkCellEditable::remove-widget`.
    public var removeWidget: ((SpinButton) -> Void)?

    /// Emitted at the end of a single user-visible operation on the
    /// contents.
    ///
    /// E.g., a paste operation that replaces the contents of the
    /// selection will cause only one signal emission (even though it
    /// is implemented by first deleting the selection, then inserting
    /// the new content, and may cause multiple ::notify::text signals
    /// to be emitted).
    public var changed: ((SpinButton) -> Void)?

    /// Emitted when text is deleted from the widget by the user.
    ///
    /// The default handler for this signal will normally be responsible for
    /// deleting the text, so by connecting to this signal and then stopping
    /// the signal with g_signal_stop_emission(), it is possible to modify the
    /// range of deleted text, or prevent it from being deleted entirely.
    ///
    /// The @start_pos and @end_pos parameters are interpreted as for
    /// [method@Gtk.Editable.delete_text].
    public var deleteText: ((SpinButton, Int, Int) -> Void)?

    /// Emitted when text is inserted into the widget by the user.
    ///
    /// The default handler for this signal will normally be responsible
    /// for inserting the text, so by connecting to this signal and then
    /// stopping the signal with g_signal_stop_emission(), it is possible
    /// to modify the inserted text, or prevent it from being inserted entirely.
    public var insertText: ((SpinButton, UnsafePointer<CChar>, Int, gpointer) -> Void)?

    public var notifyActivatesDefault: ((SpinButton, OpaquePointer) -> Void)?

    public var notifyAdjustment: ((SpinButton, OpaquePointer) -> Void)?

    public var notifyClimbRate: ((SpinButton, OpaquePointer) -> Void)?

    public var notifyDigits: ((SpinButton, OpaquePointer) -> Void)?

    public var notifyNumeric: ((SpinButton, OpaquePointer) -> Void)?

    public var notifySnapToTicks: ((SpinButton, OpaquePointer) -> Void)?

    public var notifyUpdatePolicy: ((SpinButton, OpaquePointer) -> Void)?

    public var notifyValue: ((SpinButton, OpaquePointer) -> Void)?

    public var notifyWrap: ((SpinButton, OpaquePointer) -> Void)?

    public var notifyEditingCanceled: ((SpinButton, OpaquePointer) -> Void)?

    public var notifyCursorPosition: ((SpinButton, OpaquePointer) -> Void)?

    public var notifyEditable: ((SpinButton, OpaquePointer) -> Void)?

    public var notifyEnableUndo: ((SpinButton, OpaquePointer) -> Void)?

    public var notifyMaxWidthChars: ((SpinButton, OpaquePointer) -> Void)?

    public var notifySelectionBound: ((SpinButton, OpaquePointer) -> Void)?

    public var notifyText: ((SpinButton, OpaquePointer) -> Void)?

    public var notifyWidthChars: ((SpinButton, OpaquePointer) -> Void)?

    public var notifyXalign: ((SpinButton, OpaquePointer) -> Void)?

    public var notifyOrientation: ((SpinButton, OpaquePointer) -> Void)?
}
