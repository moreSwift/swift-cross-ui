import CGtk

/// Tracks keyboard focus.
///
/// The event controller offers [signal@Gtk.EventControllerFocus::enter]
/// and [signal@Gtk.EventControllerFocus::leave] signals, as well as
/// [property@Gtk.EventControllerFocus:is-focus] and
/// [property@Gtk.EventControllerFocus:contains-focus] properties
/// which are updated to reflect focus changes inside the widget hierarchy
/// that is rooted at the controllers widget.
open class EventControllerFocus: EventController {
    /// Creates a new event controller that will handle focus events.
    public convenience init() {
        self.init(
            gtk_event_controller_focus_new()
        )
    }

    open override func registerSignals() {
        super.registerSignals()

        addSignal(name: "enter") { [weak self] () in
            guard let self else { return }
            self.enter?(self)
        }

        addSignal(name: "leave") { [weak self] () in
            guard let self else { return }
            self.leave?(self)
        }

        let handler2:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::contains-focus", handler: gCallback(handler2)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyContainsFocus?(self, param0)
        }

        let handler3:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::is-focus", handler: gCallback(handler3)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyIsFocus?(self, param0)
        }
    }

    /// %TRUE if focus is contained in the controllers widget.
    ///
    /// See [property@Gtk.EventControllerFocus:is-focus] for whether
    /// the focus is in the widget itself or inside a descendent.
    ///
    /// When handling focus events, this property is updated
    /// before [signal@Gtk.EventControllerFocus::enter] or
    /// [signal@Gtk.EventControllerFocus::leave] are emitted.
    @GObjectProperty(named: "contains-focus") public var containsFocus: Bool

    /// %TRUE if focus is in the controllers widget itself,
    /// as opposed to in a descendent widget.
    ///
    /// See also [property@Gtk.EventControllerFocus:contains-focus].
    ///
    /// When handling focus events, this property is updated
    /// before [signal@Gtk.EventControllerFocus::enter] or
    /// [signal@Gtk.EventControllerFocus::leave] are emitted.
    @GObjectProperty(named: "is-focus") public var isFocus: Bool

    /// Emitted whenever the focus enters into the widget or one
    /// of its descendents.
    ///
    /// Note that this means you may not get an ::enter signal
    /// even though the widget becomes the focus location, in
    /// certain cases (such as when the focus moves from a descendent
    /// of the widget to the widget itself). If you are interested
    /// in these cases, you can monitor the
    /// [property@Gtk.EventControllerFocus:is-focus]
    /// property for changes.
    public var enter: ((EventControllerFocus) -> Void)?

    /// Emitted whenever the focus leaves the widget hierarchy
    /// that is rooted at the widget that the controller is attached to.
    ///
    /// Note that this means you may not get a ::leave signal
    /// even though the focus moves away from the widget, in
    /// certain cases (such as when the focus moves from the widget
    /// to a descendent). If you are interested in these cases, you
    /// can monitor the [property@Gtk.EventControllerFocus:is-focus]
    /// property for changes.
    public var leave: ((EventControllerFocus) -> Void)?

    public var notifyContainsFocus: ((EventControllerFocus, OpaquePointer) -> Void)?

    public var notifyIsFocus: ((EventControllerFocus, OpaquePointer) -> Void)?
}
