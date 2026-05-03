import CGtk3
import Gtk3CHelpers

public class GSimpleAction: GAction, GObjectRepresentable {
    public var actionPointer: OpaquePointer

    public var gobjectPointer: UnsafeMutablePointer<CGtk3.GObject> {
        UnsafeMutablePointer<CGtk3.GObject>(actionPointer)
    }

    @GObjectProperty(named: "enabled") public var enabled: Bool

    private class Box<T> {
        var value: T
        init(_ value: T) { self.value = value }
    }

    public init(name: String, action: @escaping () -> Void) {
        actionPointer = g_simple_action_new(name, nil)

        connectActionSignal(Box(action)) { _, _, data in
            let action = Unmanaged<Box<() -> Void>>.fromOpaque(data).takeUnretainedValue()
            action.value()
        }
    }

    public init(name: String, state: Bool, action: @escaping (Bool) -> Void) {
        actionPointer = g_simple_action_new_stateful(
            name,
            nil,
            g_variant_new_boolean(state.toGBoolean())
        )

        connectActionSignal(Box(action)) { actionPointer, _, data in
            // Get the current state...
            let stateVariant = g_action_get_state(OpaquePointer(actionPointer))
            let state = g_variant_get_boolean(stateVariant).toBool()

            // ...toggle it...
            let newState = !state
            g_simple_action_set_state(
                OpaquePointer(actionPointer),
                g_variant_new_boolean(newState.toGBoolean())
            )

            // ...then get the action and call it with the new state.
            let action = Unmanaged<Box<(Bool) -> Void>>.fromOpaque(data).takeUnretainedValue()
            action.value(newState)
        }
    }

    private func connectActionSignal(
        _ value: some AnyObject,
        handler:
            @convention(c) (
                UnsafeMutableRawPointer,
                OpaquePointer,
                UnsafeMutableRawPointer
            ) -> Void
    ) {
        g_signal_connect_data(
            UnsafeMutableRawPointer(actionPointer),
            "activate",
            gCallback(handler),
            Unmanaged.passRetained(value).toOpaque(),
            { data, _ in
                Unmanaged<AnyObject>.fromOpaque(data!).release()
            },
            SHIM_G_CONNECT_AFTER
        )
    }
}
