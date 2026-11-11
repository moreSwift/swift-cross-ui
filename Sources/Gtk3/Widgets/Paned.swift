import CGtk3

open class Paned: Container, Orientable {
    public init(orientation: Orientation) {
        super.init(gtk_paned_new(orientation.toGtk()))
    }

    public var startChild: Widget? {
        didSet {
            if let oldValue {
                remove(oldValue)
            }
            if let startChild {
                gtk_paned_pack1(castedPointer(), startChild.castedPointer(), 1, 0)
                startChild.parentWidget = self
            }
        }
    }

    public var endChild: Widget? {
        didSet {
            if let oldValue {
                remove(oldValue)
            }
            if let endChild {
                gtk_paned_pack2(castedPointer(), endChild.castedPointer(), 1, 0)
                endChild.parentWidget = self
            }
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
}
