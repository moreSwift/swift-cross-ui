extension BackendFeatures {
    public typealias Buttons = StringLabelButtons & ViewLabelButtons

    /// Backend methods for simple buttons.
    ///
    /// These are used by ``Toggle`` and ``Menu``.
    @MainActor
    public protocol StringLabelButtons: Core {
        /// Creates a labelled button with an action triggered on click/tap.
        ///
        /// Used by controls in button style like ``Menu``, ``Toggle`` or more constrained result builders.
        ///
        /// - Returns: A button.
        func createSimpleButton() -> Widget

        /// Sets a button's label and action.
        ///
        /// - Parameters:
        ///   - button: The button to update.
        ///   - label: The button's label.
        ///   - environment: The current environment.
        ///   - action: The action to perform when the button is clicked/tapped.
        ///     This replaces any existing actions.
        func updateSimpleButton(
            _ button: Widget,
            label: String,
            environment: EnvironmentValues,
            action: @escaping () -> Void
        )
    }

    /// Backend methods for more complex buttons supporting an arbitrary ``View`` as label.
    ///
    /// These are used by ``Button``.
    @MainActor
    public protocol ViewLabelButtons: Core {
        /// Creates a button that uses `widget` as its label with an action triggered on click/tap.
        ///
        /// Predominantly used by ``Button``.
        ///
        /// - Parameters:
        ///   - widget: The widget the button should use as label.
        ///
        /// - Returns: A button.
        func createButton(wrapping widget: Widget) -> Widget

        /// Sets a button's action and updates the rendered style based on the environment.
        ///
        /// - Parameters:
        ///   - button: The button to update.
        ///   - environment: The current environment.
        ///   - action: The action to perform when the button is clicked/tapped.
        ///     This replaces any existing actions.
        func updateButton(
            _ button: Widget,
            environment: EnvironmentValues,
            action: @escaping () -> Void
        )

        /// Buttons are set to label size + padding by SwiftCrossUI.
        /// Backends may choose different amounts of padding for different button styles.
        ///
        /// A padding of (0, 0) is recommended for all styles without a system defined background.
        ///
        /// - Parameters:
        ///   - environment: The current environment.
        ///
        /// - Returns: A vector containing the **total** spacing horizontally and vertically.
        func buttonPadding(in environment: EnvironmentValues) -> SIMD2<Int>

        /// The default button style that the backend desires.
        ///
        /// - Returns: The default ``ButtonStyle``.
        func defaultButtonStyle() -> ButtonStyle

        /// Modifies the environment for the body of a button label.
        ///
        /// Backends may implement their own to align with the platform's conventions more closely.
        /// The default implementation applies SwiftUI-like behavior.
        ///
        /// - Returns: The modified environment.
        func buttonLabelEnvironment(
            from environment: EnvironmentValues
        ) -> EnvironmentValues
    }
}

// MARK: - Default Implementations
extension BackendFeatures.ViewLabelButtons {
    public func buttonLabelEnvironment(
        from environment: EnvironmentValues
    ) -> EnvironmentValues {
        var labelEnvironment = environment

        let buttonStyle = environment.resolvedButtonStyle.kind
        let deviceClass = environment.backend.deviceClass

        if !environment.isEnabled, buttonStyle == .bordered {
            if deviceClass == .desktop || deviceClass == .tv {
                labelEnvironment = labelEnvironment.with(
                    \.foregroundColor,
                    environment.foregroundColor ?? .gray
                        .opacity(0.5) // SwiftUI is closer to secondary.
                )
            } else if deviceClass == .phone || deviceClass == .tablet {
                labelEnvironment = labelEnvironment.with(
                    \.foregroundColor,
                    environment.foregroundColor?.opacity(0.8) ?? .blue.opacity(0.8)
                )
            } else if deviceClass == .tv {
                labelEnvironment = labelEnvironment.with(
                    \.foregroundColor,
                    environment.foregroundColor ?? .white.opacity(0.5)
                )
            }
        }

        // The disabled opacities and defaults are based on discoveries in SwiftUI.
        // iOS appears to dimm even foregroundColors in the environment.

        // Set the default foregroundColor for the label unless overridden.
        // Uses the same colors as SwiftUI.
        if
            buttonStyle == .borderless,
            deviceClass == .desktop
        {
            labelEnvironment = labelEnvironment.with(
                \.foregroundColor,
                environment.foregroundColor ?? .gray
            )
        } else if
            deviceClass == .phone || deviceClass == .tablet,
            buttonStyle == .borderless || buttonStyle == .bordered
        {
            labelEnvironment = labelEnvironment.with(
                \.foregroundColor,
                environment.foregroundColor ?? .blue // TODO: Replace with .accent
            )
        }

        return labelEnvironment
    }
}
