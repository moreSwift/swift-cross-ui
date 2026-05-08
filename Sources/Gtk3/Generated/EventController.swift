import CGtk3

/// #GtkEventController is a base, low-level implementation for event
/// controllers. Those react to a series of #GdkEvents, and possibly trigger
/// actions as a consequence of those.
open class EventController: GObject {

    open override func registerSignals() {
        super.registerSignals()

        let handler0:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::propagation-phase", handler: gCallback(handler0)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyPropagationPhase?(self, param0)
        }

        let handler1:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::widget", handler: gCallback(handler1)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyWidget?(self, param0)
        }
    }

    public var notifyPropagationPhase: ((EventController, OpaquePointer) -> Void)?

    public var notifyWidget: ((EventController, OpaquePointer) -> Void)?
}
