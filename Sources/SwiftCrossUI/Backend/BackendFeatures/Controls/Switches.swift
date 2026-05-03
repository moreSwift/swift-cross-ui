extension BackendFeatures {
    /// Backend methods for toggle switches.
    ///
    /// These are used by ``Toggle`` when ``EnvironmentValues/toggleStyle`` is
    /// ``ToggleStyle/switch``.
    @MainActor
    public protocol Switches: Core {
        /// If `true`, a toggle in the ``ToggleStyle/switch`` style grows to fill
        /// its parent container.
        var requiresToggleSwitchSpacer: Bool { get }

        /// Creates a switch that is either on or off.
        ///
        /// - Returns: A switch.
        func createSwitch() -> Widget

        /// Sets the change handler of a switch.
        ///
        /// - Parameters:
        ///   - switchWidget: The switch to update.
        ///   - environment: The current environment.
        ///   - onChange: The action to perform when the switch is toggled on or
        ///     off. This replaces any existing change handlers.
        func updateSwitch(
            _ switchWidget: Widget,
            environment: EnvironmentValues,
            onChange: @escaping (Bool) -> Void
        )

        /// Sets the state of a switch.
        ///
        /// - Parameters:
        ///   - switchWidget: The switch to set the state of.
        ///   - state: The new state.
        func setState(ofSwitch switchWidget: Widget, to state: Bool)
    }
}
