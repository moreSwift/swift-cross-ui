import CGtk

public class ToggleButton: Button {
    public convenience init() {
        self.init(
            gtk_toggle_button_new()
        )
    }

    public convenience init(label: String) {
        self.init(
            gtk_toggle_button_new_with_label(label)
        )
    }

    public convenience init(mnemonic label: String) {
        self.init(
            gtk_toggle_button_new_with_mnemonic(label)
        )
    }

    open override func didMoveToParent() {
        super.didMoveToParent()

        let handler: @convention(c) (
            UnsafeMutableRawPointer,
            UnsafeMutableRawPointer
        ) -> Void = { _, data in
            SignalBox0<Void>.run(data)
        }

        addSignal(
            name: "toggled",
            handler: gCallback(handler)
        ) { [weak self] in
            guard let self else { return }
            self.toggled?(self)
        }
    }

    @GObjectProperty(named: "active") public var active: Bool

    public var toggled: ((ToggleButton) -> Void)?
}
