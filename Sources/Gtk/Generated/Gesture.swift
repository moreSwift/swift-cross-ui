import CGtk

/// The base class for gesture recognition.
///
/// Although `GtkGesture` is quite generalized to serve as a base for
/// multi-touch gestures, it is suitable to implement single-touch and
/// pointer-based gestures (using the special %NULL `GdkEventSequence`
/// value for these).
///
/// The number of touches that a `GtkGesture` need to be recognized is
/// controlled by the [property@Gtk.Gesture:n-points] property, if a
/// gesture is keeping track of less or more than that number of sequences,
/// it won't check whether the gesture is recognized.
///
/// As soon as the gesture has the expected number of touches, it will check
/// regularly if it is recognized, the criteria to consider a gesture as
/// "recognized" is left to `GtkGesture` subclasses.
///
/// A recognized gesture will then emit the following signals:
///
/// - [signal@Gtk.Gesture::begin] when the gesture is recognized.
/// - [signal@Gtk.Gesture::update], whenever an input event is processed.
/// - [signal@Gtk.Gesture::end] when the gesture is no longer recognized.
///
/// ## Event propagation
///
/// In order to receive events, a gesture needs to set a propagation phase
/// through [method@Gtk.EventController.set_propagation_phase].
///
/// In the capture phase, events are propagated from the toplevel down
/// to the target widget, and gestures that are attached to containers
/// above the widget get a chance to interact with the event before it
/// reaches the target.
///
/// In the bubble phase, events are propagated up from the target widget
/// to the toplevel, and gestures that are attached to containers above
/// the widget get a chance to interact with events that have not been
/// handled yet.
///
/// ## States of a sequence
///
/// Whenever input interaction happens, a single event may trigger a cascade
/// of `GtkGesture`s, both across the parents of the widget receiving the
/// event and in parallel within an individual widget. It is a responsibility
/// of the widgets using those gestures to set the state of touch sequences
/// accordingly in order to enable cooperation of gestures around the
/// `GdkEventSequence`s triggering those.
///
/// Within a widget, gestures can be grouped through [method@Gtk.Gesture.group].
/// Grouped gestures synchronize the state of sequences, so calling
/// [method@Gtk.Gesture.set_state] on one will effectively propagate
/// the state throughout the group.
///
/// By default, all sequences start out in the %GTK_EVENT_SEQUENCE_NONE state,
/// sequences in this state trigger the gesture event handler, but event
/// propagation will continue unstopped by gestures.
///
/// If a sequence enters into the %GTK_EVENT_SEQUENCE_DENIED state, the gesture
/// group will effectively ignore the sequence, letting events go unstopped
/// through the gesture, but the "slot" will still remain occupied while
/// the touch is active.
///
/// If a sequence enters in the %GTK_EVENT_SEQUENCE_CLAIMED state, the gesture
/// group will grab all interaction on the sequence, by:
///
/// - Setting the same sequence to %GTK_EVENT_SEQUENCE_DENIED on every other
/// gesture group within the widget, and every gesture on parent widgets
/// in the propagation chain.
/// - Emitting [signal@Gtk.Gesture::cancel] on every gesture in widgets
/// underneath in the propagation chain.
/// - Stopping event propagation after the gesture group handles the event.
///
/// Note: if a sequence is set early to %GTK_EVENT_SEQUENCE_CLAIMED on
/// %GDK_TOUCH_BEGIN/%GDK_BUTTON_PRESS (so those events are captured before
/// reaching the event widget, this implies %GTK_PHASE_CAPTURE), one similar
/// event will be emulated if the sequence changes to %GTK_EVENT_SEQUENCE_DENIED.
/// This way event coherence is preserved before event propagation is unstopped
/// again.
///
/// Sequence states can't be changed freely.
/// See [method@Gtk.Gesture.set_state] to know about the possible
/// lifetimes of a `GdkEventSequence`.
///
/// ## Touchpad gestures
///
/// On the platforms that support it, `GtkGesture` will handle transparently
/// touchpad gesture events. The only precautions users of `GtkGesture` should
/// do to enable this support are:
///
/// - If the gesture has %GTK_PHASE_NONE, ensuring events of type
/// %GDK_TOUCHPAD_SWIPE and %GDK_TOUCHPAD_PINCH are handled by the `GtkGesture`
open class Gesture: EventController {

    open override func registerSignals() {
        super.registerSignals()

        let handler0:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "begin", handler: gCallback(handler0)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.begin?(self, param0)
        }

        let handler1:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "cancel", handler: gCallback(handler1)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.cancel?(self, param0)
        }

        let handler2:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "end", handler: gCallback(handler2)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.end?(self, param0)
        }

        let handler3:
            @convention(c) (
                UnsafeMutableRawPointer,
                OpaquePointer,
                GtkEventSequenceState,
                UnsafeMutableRawPointer
            ) -> Void =
            { _, value1, value2, data in
                SignalBox2<OpaquePointer, GtkEventSequenceState>.run(data, value1, value2)
            }

        addSignal(name: "sequence-state-changed", handler: gCallback(handler3)) {
            [weak self] (param0: OpaquePointer, param1: GtkEventSequenceState) in
            guard let self else { return }
            self.sequenceStateChanged?(self, param0, param1)
        }

        let handler4:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "update", handler: gCallback(handler4)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.update?(self, param0)
        }

        let handler5:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::n-points", handler: gCallback(handler5)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyNPoints?(self, param0)
        }
    }

    /// Emitted when the gesture is recognized.
    ///
    /// This means the number of touch sequences matches
    /// [property@Gtk.Gesture:n-points].
    ///
    /// Note: These conditions may also happen when an extra touch
    /// (eg. a third touch on a 2-touches gesture) is lifted, in that
    /// situation @sequence won't pertain to the current set of active
    /// touches, so don't rely on this being true.
    public var begin: ((Gesture, OpaquePointer) -> Void)?

    /// Emitted whenever a sequence is cancelled.
    ///
    /// This usually happens on active touches when
    /// [method@Gtk.EventController.reset] is called on @gesture
    /// (manually, due to grabs...), or the individual @sequence
    /// was claimed by parent widgets' controllers (see
    /// [method@Gtk.Gesture.set_sequence_state]).
    ///
    /// @gesture must forget everything about @sequence as in
    /// response to this signal.
    public var cancel: ((Gesture, OpaquePointer) -> Void)?

    /// Emitted when @gesture either stopped recognizing the event
    /// sequences as something to be handled, or the number of touch
    /// sequences became higher or lower than [property@Gtk.Gesture:n-points].
    ///
    /// Note: @sequence might not pertain to the group of sequences that
    /// were previously triggering recognition on @gesture (ie. a just
    /// pressed touch sequence that exceeds [property@Gtk.Gesture:n-points]).
    /// This situation may be detected by checking through
    /// [method@Gtk.Gesture.handles_sequence].
    public var end: ((Gesture, OpaquePointer) -> Void)?

    /// Emitted whenever a sequence state changes.
    ///
    /// See [method@Gtk.Gesture.set_sequence_state] to know
    /// more about the expectable sequence lifetimes.
    public var sequenceStateChanged: ((Gesture, OpaquePointer, GtkEventSequenceState) -> Void)?

    /// Emitted whenever an event is handled while the gesture is recognized.
    ///
    /// @sequence is guaranteed to pertain to the set of active touches.
    public var update: ((Gesture, OpaquePointer) -> Void)?

    public var notifyNPoints: ((Gesture, OpaquePointer) -> Void)?
}
