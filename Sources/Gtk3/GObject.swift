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
        // disconnect all GTK signal handlers before releasing the object
        // to prevent callbacks firing on deallocated Swift wrapper instances.
        for (id, _) in signals {
            g_signal_handler_disconnect(gobjectPointer, id)
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
    func addSignal(name: String, callback: @escaping () -> Void) {
        let box = SignalBox0(callback: callback)
        let handler:
            @convention(c) (
                UnsafeMutableRawPointer,
                UnsafeMutableRawPointer
            ) -> Void = { _, data in
                let box = Unmanaged<SignalBox0>.fromOpaque(data).takeUnretainedValue()
                box.callback()
            }

        let handlerId = connectSignal(
            gobjectPointer,
            name: name,
            data: Unmanaged.passUnretained(box).toOpaque(),
            handler: unsafeBitCast(handler, to: GCallback.self)
        )

        signals.append((handlerId, box))
    }

    func addSignal<T1>(name: String, handler: GCallback, callback: @escaping (T1) -> Void) {
        let box = SignalBox1(callback: callback)

        let handlerId = connectSignal(
            gobjectPointer,
            name: name,
            data: Unmanaged.passUnretained(box).toOpaque(),
            handler: handler
        )

        signals.append((handlerId, box))
    }

    func addSignal<T1, T2>(name: String, handler: GCallback, callback: @escaping (T1, T2) -> Void) {
        let box = SignalBox2(callback: callback)

        let handlerId = connectSignal(
            gobjectPointer,
            name: name,
            data: Unmanaged.passUnretained(box).toOpaque(),
            handler: handler
        )

        signals.append((handlerId, box))
    }

    func addSignal<T1, T2, T3>(
        name: String,
        handler: GCallback,
        callback: @escaping (T1, T2, T3) -> Void
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

    func addSignal<T1, T2, T3, T4>(
        name: String,
        handler: GCallback,
        callback: @escaping (T1, T2, T3, T4) -> Void
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

    func addSignal<T1, T2, T3, T4, T5>(
        name: String,
        handler: GCallback,
        callback: @escaping (T1, T2, T3, T4, T5) -> Void
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

    func addSignal<T1, T2, T3, T4, T5, T6>(
        name: String,
        handler: GCallback,
        callback: @escaping (T1, T2, T3, T4, T5, T6) -> Void
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
