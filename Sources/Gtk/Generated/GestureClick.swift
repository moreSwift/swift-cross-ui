import CGtk

/// Recognizes click gestures.
///
/// It is able to recognize multiple clicks on a nearby zone, which
/// can be listened for through the [signal@Gtk.GestureClick::pressed]
/// signal. Whenever time or distance between clicks exceed the GTK
/// defaults, [signal@Gtk.GestureClick::stopped] is emitted, and the
/// click counter is reset.
open class GestureClick: GestureSingle {
    /// Returns a newly created `GtkGesture` that recognizes
    /// single and multiple presses.
    public convenience init() {
        self.init(
            gtk_gesture_click_new()
        )
    }

    open override func registerSignals() {
        super.registerSignals()

        let handler0:
            @convention(c) (UnsafeMutableRawPointer, Int, Double, Double, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, value2, value3, data in
                SignalBox3<Int, Double, Double>.run(data, value1, value2, value3)
            }

        addSignal(name: "pressed", handler: gCallback(handler0)) {
            [weak self] (param0: Int, param1: Double, param2: Double) in
            guard let self else { return }
            self.pressed?(self, param0, param1, param2)
        }

        let handler1:
            @convention(c) (UnsafeMutableRawPointer, Int, Double, Double, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, value2, value3, data in
                SignalBox3<Int, Double, Double>.run(data, value1, value2, value3)
            }

        addSignal(name: "released", handler: gCallback(handler1)) {
            [weak self] (param0: Int, param1: Double, param2: Double) in
            guard let self else { return }
            self.released?(self, param0, param1, param2)
        }

        addSignal(name: "stopped") { [weak self] () in
            guard let self else { return }
            self.stopped?(self)
        }

        let handler3:
            @convention(c) (
                UnsafeMutableRawPointer,
                Double,
                Double,
                UInt,
                OpaquePointer,
                UnsafeMutableRawPointer
            ) -> Void =
            { _, value1, value2, value3, value4, data in
                SignalBox4<Double, Double, UInt, OpaquePointer>.run(
                    data,
                    value1,
                    value2,
                    value3,
                    value4
                )
            }

        addSignal(name: "unpaired-release", handler: gCallback(handler3)) {
            [weak self] (param0: Double, param1: Double, param2: UInt, param3: OpaquePointer) in
            guard let self else { return }
            self.unpairedRelease?(self, param0, param1, param2, param3)
        }
    }

    /// Emitted whenever a button or touch press happens.
    public var pressed: ((GestureClick, Int, Double, Double) -> Void)?

    /// Emitted when a button or touch is released.
    ///
    /// @n_press will report the number of press that is paired to
    /// this event, note that [signal@Gtk.GestureClick::stopped] may
    /// have been emitted between the press and its release, @n_press
    /// will only start over at the next press.
    public var released: ((GestureClick, Int, Double, Double) -> Void)?

    /// Emitted whenever any time/distance threshold has been exceeded.
    public var stopped: ((GestureClick) -> Void)?

    /// Emitted whenever the gesture receives a release
    /// event that had no previous corresponding press.
    ///
    /// Due to implicit grabs, this can only happen on situations
    /// where input is grabbed elsewhere mid-press or the pressed
    /// widget voluntarily relinquishes its implicit grab.
    public var unpairedRelease: ((GestureClick, Double, Double, UInt, OpaquePointer) -> Void)?
}
