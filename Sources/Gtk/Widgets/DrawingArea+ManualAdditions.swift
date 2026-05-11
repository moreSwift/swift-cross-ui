import CGtk

extension DrawingArea {
    public func setDrawFunc(
        _ drawFunc: @escaping (
            _ cairo: OpaquePointer,
            _ width: Int,
            _ height: Int
        ) -> Void
    ) {
        let box = SignalBox3<OpaquePointer, Int, Int> { cairo, width, height in
            drawFunc(cairo, width, height)
        }

        gtk_drawing_area_set_draw_func(
            castedPointer(),
            { _, cairo, width, height, data in
                let box = Unmanaged<SignalBox3<OpaquePointer, Int, Int>>
                    .fromOpaque(data!)
                    .takeUnretainedValue()
                box.callback(cairo!, Int(width), Int(height))
            },
            Unmanaged.passRetained(box).toOpaque(),
            { data in
                Unmanaged<SignalBox3<OpaquePointer, Int, Int>>
                    .fromOpaque(data!)
                    .release()
            }
        )
    }
}
