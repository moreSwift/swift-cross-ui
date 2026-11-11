import CGtk

open class Paned: Widget, Orientable {
    public convenience init(orientation: Orientation) {
        self.init(gtk_paned_new(orientation.toGtk()))
    }

    public var startChild: Widget? {
        didSet {
            oldValue?.parentWidget = nil
            gtk_paned_set_start_child(opaquePointer, startChild?.castedPointer())
            startChild?.parentWidget = self
        }
    }

    public var endChild: Widget? {
        didSet {
            oldValue?.parentWidget = nil
            gtk_paned_set_end_child(opaquePointer, endChild?.castedPointer())
            endChild?.parentWidget = self
        }
    }

    open override func didMoveToParent() {
        startChild?.didMoveToParent()
        endChild?.didMoveToParent()

        let handler:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::position", handler: gCallback(handler)) {
            [weak self] (_: OpaquePointer) in
            guard let self else { return }
            self.notifyPosition?(self)
        }
    }

    public var notifyPosition: ((Paned) -> Void)?

    @GObjectProperty(named: "position") public var position: Int
    @GObjectProperty(named: "max-position") public var maxPosition: Int
    @GObjectProperty(named: "min-position") public var minPosition: Int
    @GObjectProperty(named: "shrink-start-child") public var shrinkStartChild: Bool
    @GObjectProperty(named: "shrink-end-child") public var shrinkEndChild: Bool
    @GObjectProperty(named: "resize-start-child") public var resizeStartChild: Bool
    @GObjectProperty(named: "resize-end-child") public var resizeEndChild: Bool
}
