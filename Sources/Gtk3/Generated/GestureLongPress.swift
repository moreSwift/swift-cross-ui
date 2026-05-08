import CGtk3

/// #GtkGestureLongPress is a #GtkGesture implementation able to recognize
/// long presses, triggering the #GtkGestureLongPress::pressed after the
/// timeout is exceeded.
///
/// If the touchpoint is lifted before the timeout passes, or if it drifts
/// too far of the initial press point, the #GtkGestureLongPress::cancelled
/// signal will be emitted.
open class GestureLongPress: GestureSingle {
    /// Returns a newly created #GtkGesture that recognizes long presses.
    public convenience init(widget: UnsafeMutablePointer<GtkWidget>!) {
        self.init(
            gtk_gesture_long_press_new(widget)
        )
    }

    open override func registerSignals() {
        super.registerSignals()

        addSignal(name: "cancelled") { [weak self] () in
            guard let self else { return }
            self.cancelled?(self)
        }

        let handler1:
            @convention(c) (UnsafeMutableRawPointer, Double, Double, UnsafeMutableRawPointer) ->
            Void =
            { _, value1, value2, data in
                SignalBox2<Double, Double>.run(data, value1, value2)
            }

        addSignal(name: "pressed", handler: gCallback(handler1)) {
            [weak self] (param0: Double, param1: Double) in
            guard let self else { return }
            self.pressed?(self, param0, param1)
        }

        let handler2:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::delay-factor", handler: gCallback(handler2)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyDelayFactor?(self, param0)
        }
    }

    /// This signal is emitted whenever a press moved too far, or was released
    /// before #GtkGestureLongPress::pressed happened.
    public var cancelled: ((GestureLongPress) -> Void)?

    /// This signal is emitted whenever a press goes unmoved/unreleased longer than
    /// what the GTK+ defaults tell.
    public var pressed: ((GestureLongPress, Double, Double) -> Void)?

    public var notifyDelayFactor: ((GestureLongPress, OpaquePointer) -> Void)?
}
