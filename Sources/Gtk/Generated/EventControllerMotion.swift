import CGtk

/// Tracks the pointer position.
///
/// The event controller offers [signal@Gtk.EventControllerMotion::enter]
/// and [signal@Gtk.EventControllerMotion::leave] signals, as well as
/// [property@Gtk.EventControllerMotion:is-pointer] and
/// [property@Gtk.EventControllerMotion:contains-pointer] properties
/// which are updated to reflect changes in the pointer position as it
/// moves over the widget.
open class EventControllerMotion: EventController {
    /// Creates a new event controller that will handle motion events.
    public convenience init() {
        self.init(
            gtk_event_controller_motion_new()
        )
    }

    open override func registerSignals() {
        super.registerSignals()

        let handler0:
            @convention(c) (UnsafeMutableRawPointer, Double, Double, UnsafeMutableRawPointer) ->
            Void =
            { _, value1, value2, data in
                SignalBox2<Double, Double>.run(data, value1, value2)
            }

        addSignal(name: "enter", handler: gCallback(handler0)) {
            [weak self] (param0: Double, param1: Double) in
            guard let self else { return }
            self.enter?(self, param0, param1)
        }

        addSignal(name: "leave") { [weak self] () in
            guard let self else { return }
            self.leave?(self)
        }

        let handler2:
            @convention(c) (UnsafeMutableRawPointer, Double, Double, UnsafeMutableRawPointer) ->
            Void =
            { _, value1, value2, data in
                SignalBox2<Double, Double>.run(data, value1, value2)
            }

        addSignal(name: "motion", handler: gCallback(handler2)) {
            [weak self] (param0: Double, param1: Double) in
            guard let self else { return }
            self.motion?(self, param0, param1)
        }

        let handler3:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::contains-pointer", handler: gCallback(handler3)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyContainsPointer?(self, param0)
        }

        let handler4:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::is-pointer", handler: gCallback(handler4)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyIsPointer?(self, param0)
        }
    }

    /// Whether the pointer is in the controllers widget or a descendant.
    ///
    /// See also [property@Gtk.EventControllerMotion:is-pointer].
    ///
    /// When handling crossing events, this property is updated
    /// before [signal@Gtk.EventControllerMotion::enter], but after
    /// [signal@Gtk.EventControllerMotion::leave] is emitted.
    @GObjectProperty(named: "contains-pointer") public var containsPointer: Bool

    /// Whether the pointer is in the controllers widget itself,
    /// as opposed to in a descendent widget.
    ///
    /// See also [property@Gtk.EventControllerMotion:contains-pointer].
    ///
    /// When handling crossing events, this property is updated
    /// before [signal@Gtk.EventControllerMotion::enter], but after
    /// [signal@Gtk.EventControllerMotion::leave] is emitted.
    @GObjectProperty(named: "is-pointer") public var isPointer: Bool

    /// Signals that the pointer has entered the widget.
    public var enter: ((EventControllerMotion, Double, Double) -> Void)?

    /// Signals that the pointer has left the widget.
    public var leave: ((EventControllerMotion) -> Void)?

    /// Emitted when the pointer moves inside the widget.
    public var motion: ((EventControllerMotion, Double, Double) -> Void)?

    public var notifyContainsPointer: ((EventControllerMotion, OpaquePointer) -> Void)?

    public var notifyIsPointer: ((EventControllerMotion, OpaquePointer) -> Void)?
}
