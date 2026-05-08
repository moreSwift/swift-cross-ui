import CGtk3

/// #GtkSwitch is a widget that has two states: on or off. The user can control
/// which state should be active by clicking the empty area, or by dragging the
/// handle.
///
/// GtkSwitch can also handle situations where the underlying state changes with
/// a delay. See #GtkSwitch::state-set for details.
///
/// # CSS nodes
///
/// |[<!-- language="plain" -->
/// switch
/// ╰── slider
/// ]|
///
/// GtkSwitch has two css nodes, the main node with the name switch and a subnode
/// named slider. Neither of them is using any style classes.
open class Switch: Widget, Activatable {
    /// Creates a new #GtkSwitch widget.
    public convenience init() {
        self.init(
            gtk_switch_new()
        )
    }

    open override func didMoveToParent() {
        super.didMoveToParent()

        addSignal(name: "activate") { [weak self] () in
            guard let self else { return }
            self.activate?(self)
        }

        let handler1:
            @convention(c) (UnsafeMutableRawPointer, Bool, UnsafeMutableRawPointer) -> Void =
            { _, value1, data in
                SignalBox1<Bool>.run(data, value1)
            }

        addSignal(name: "state-set", handler: gCallback(handler1)) { [weak self] (param0: Bool) in
            guard let self else { return }
            self.stateSet?(self, param0)
        }

        let handler2:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::active", handler: gCallback(handler2)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyActive?(self, param0)
        }

        let handler3:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::state", handler: gCallback(handler3)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyState?(self, param0)
        }

        let handler4:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::related-action", handler: gCallback(handler4)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyRelatedAction?(self, param0)
        }

        let handler5:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::use-action-appearance", handler: gCallback(handler5)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyUseActionAppearance?(self, param0)
        }
    }

    /// Whether the #GtkSwitch widget is in its on or off state.
    @GObjectProperty(named: "active") public var active: Bool

    /// The ::activate signal on GtkSwitch is an action signal and
    /// emitting it causes the switch to animate.
    /// Applications should never connect to this signal, but use the
    /// notify::active signal.
    public var activate: ((Switch) -> Void)?

    /// The ::state-set signal on GtkSwitch is emitted to change the underlying
    /// state. It is emitted when the user changes the switch position. The
    /// default handler keeps the state in sync with the #GtkSwitch:active
    /// property.
    ///
    /// To implement delayed state change, applications can connect to this signal,
    /// initiate the change of the underlying state, and call gtk_switch_set_state()
    /// when the underlying state change is complete. The signal handler should
    /// return %TRUE to prevent the default handler from running.
    ///
    /// Visually, the underlying state is represented by the trough color of
    /// the switch, while the #GtkSwitch:active property is represented by the
    /// position of the switch.
    public var stateSet: ((Switch, Bool) -> Void)?

    public var notifyActive: ((Switch, OpaquePointer) -> Void)?

    public var notifyState: ((Switch, OpaquePointer) -> Void)?

    public var notifyRelatedAction: ((Switch, OpaquePointer) -> Void)?

    public var notifyUseActionAppearance: ((Switch, OpaquePointer) -> Void)?
}
