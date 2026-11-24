@_spi(Bakcends) import SwiftCrossUI
import WinUI

extension WinUIBackend: BackendFeatures.ToggleButtons {
    public func createToggle() -> Widget {
        let toggle = ToggleButton()
        toggle.click.addHandler { [weak internalState] _, _ in
            guard let internalState else { return }
            internalState.toggleClickActions[ObjectIdentifier(toggle)]?(toggle.isChecked ?? false)
        }
        return toggle
    }

    public func updateToggle(
        _ toggle: Widget,
        label: String,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        let toggle = toggle as! ToggleButton
        let block = TextBlock()
        block.text = label
        toggle.content = block

        // Use opposite color scheme for label if checked to match WinUI's default
        // behaviour.
        environment.with(
            \.colorScheme,
            toggle.isChecked == true
            ? environment.colorScheme.opposite
            : environment.colorScheme
        ).apply(to: block)

        environment.apply(to: toggle)

        internalState.toggleClickActions[ObjectIdentifier(toggle)] = { state in
            onChange(state)

            // Update label color scheme just in case the update doesn't get
            // propagated back to us (e.g. if the user passes in a dummy binding)
            environment.with(
                \.colorScheme,
                state ? environment.colorScheme.opposite : environment.colorScheme
            ).apply(to: block)
        }
    }

    public func setState(ofToggle toggle: Widget, to state: Bool) {
        let toggle = toggle as! ToggleButton
        toggle.isChecked = state
    }
}
