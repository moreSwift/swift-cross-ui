import CGtk3

open class GObject: GObjectRepresentable {
    public var gobjectPointer: UnsafeMutablePointer<CGtk3.GObject>

    public var opaquePointer: OpaquePointer? {
        return OpaquePointer(gobjectPointer)
    }

    public init<T>(_ pointer: UnsafeMutablePointer<T>) {
        gobjectPointer = pointer.cast()
        g_object_ref(gobjectPointer)
    }

    public init(_ pointer: OpaquePointer) {
        gobjectPointer = UnsafeMutablePointer(pointer)
        g_object_ref(gobjectPointer)
    }

    deinit {
        // Disconnect all GTK signal handlers before releasing the object
        // to prevent callbacks firing on deallocated Swift wrapper instances.
        for (handlerId, _) in signals {
            // Gtk 3 seems to disconnect the signals before we get here in some cases,
            // so we first check if the signal handler is still connected
            guard g_signal_handler_is_connected(gobjectPointer, gulong(handlerId)) == 1 else {
                continue
            }

            disconnectSignal(gobjectPointer, handlerId: handlerId)
        }

        g_object_unref(gobjectPointer)
    }

    private var signals: [(UInt, Any)] = []

    open func registerSignals() {}

    func removeSignals() {
        for (handlerId, _) in signals {
            disconnectSignal(gobjectPointer, handlerId: handlerId)
        }

        signals = []
    }

    /// Adds a signal that is not carrying any additional information.
    func addSignal<R>(name: String, handler: GCallback, callback: @escaping () -> R) {
        let box = SignalBox0(callback: callback)

        let handlerId = connectSignal(
            gobjectPointer,
            name: name,
            data: Unmanaged.passUnretained(box).toOpaque(),
            handler: handler
        )

        signals.append((handlerId, box))
    }

    func addSignal<T1, R>(name: String, handler: GCallback, callback: @escaping (T1) -> R) {
        let box = SignalBox1(callback: callback)

        let handlerId = connectSignal(
            gobjectPointer,
            name: name,
            data: Unmanaged.passUnretained(box).toOpaque(),
            handler: handler
        )

        signals.append((handlerId, box))
    }

    func addSignal<T1, T2, R>(name: String, handler: GCallback, callback: @escaping (T1, T2) -> R) {
        let box = SignalBox2(callback: callback)

        let handlerId = connectSignal(
            gobjectPointer,
            name: name,
            data: Unmanaged.passUnretained(box).toOpaque(),
            handler: handler
        )

        signals.append((handlerId, box))
    }

    func addSignal<T1, T2, T3, R>(
        name: String,
        handler: GCallback,
        callback: @escaping (T1, T2, T3) -> R
    ) {
        let box = SignalBox3(callback: callback)

        let handlerId = connectSignal(
            gobjectPointer,
            name: name,
            data: Unmanaged.passUnretained(box).toOpaque(),
            handler: handler
        )

        signals.append((handlerId, box))
    }

    func addSignal<T1, T2, T3, T4, R>(
        name: String,
        handler: GCallback,
        callback: @escaping (T1, T2, T3, T4) -> R
    ) {
        let box = SignalBox4(callback: callback)

        let handlerId = connectSignal(
            gobjectPointer,
            name: name,
            data: Unmanaged.passUnretained(box).toOpaque(),
            handler: handler
        )

        signals.append((handlerId, box))
    }

    func addSignal<T1, T2, T3, T4, T5, R>(
        name: String,
        handler: GCallback,
        callback: @escaping (T1, T2, T3, T4, T5) -> R
    ) {
        let box = SignalBox5(callback: callback)

        let handlerId = connectSignal(
            gobjectPointer,
            name: name,
            data: Unmanaged.passUnretained(box).toOpaque(),
            handler: handler
        )

        signals.append((handlerId, box))
    }

    func addSignal<T1, T2, T3, T4, T5, T6, R>(
        name: String,
        handler: GCallback,
        callback: @escaping (T1, T2, T3, T4, T5, T6) -> R
    ) {
        let box = SignalBox6(callback: callback)

        let handlerId = connectSignal(
            gobjectPointer,
            name: name,
            data: Unmanaged.passUnretained(box).toOpaque(),
            handler: handler
        )

        signals.append((handlerId, box))
    }
}
