import CGtk3

open class ToggleButton: Button {
    public convenience init() {
        self.init(gtk_toggle_button_new())
    }

    public convenience init(label: String) {
        self.init(gtk_toggle_button_new_with_label(label))
    }

    public convenience init(mnemonic label: String) {
        self.init(gtk_toggle_button_new_with_mnemonic(label))
    }

    open override func didMoveToParent() {
        super.didMoveToParent()

        addSignal(name: "toggled") { [weak self] in
            guard let self else { return }
            self.toggled?(self)
        }

        let handler:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::active", handler: gCallback(handler)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyActive?(self, param0)
        }
    }

    @GObjectProperty(named: "active") open var active: Bool

    open var toggled: ((ToggleButton) -> Void)?

    public var notifyActive: ((ToggleButton, OpaquePointer) -> Void)?
}
