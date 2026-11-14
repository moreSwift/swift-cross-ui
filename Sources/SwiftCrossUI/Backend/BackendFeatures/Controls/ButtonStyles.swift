extension BackendFeatures {
    // The button style modification functions returning AnyView are a tradeoff.
    // Due to the typesystem it's not possible to achieve strongly typed returns without
    // needing to wrap them in AnyView later or causing immense generic bleed.
    // As Label is already type erased and we don't need the type information in the backends,
    // I believe making this tradeoff should be fine.
    @MainActor
    public protocol ButtonStyles: Core {
        /// The default button style that the backend desires.
        ///
        /// - Returns: The default ``ButtonStyle``.
        func defaultButtonStyle() -> any ButtonStyle

        func borderedButtonStyleModification(
            with config: ButtonStyleConfiguration
        ) -> AnyView

        func borderlessButtonStyleModification(
            with config: ButtonStyleConfiguration
        ) -> AnyView

        func plainButtonStyleModification(
            with config: ButtonStyleConfiguration
        ) -> AnyView
    }
}

extension BackendFeatures.ButtonStyles {
    public func borderedButtonStyleModification(
        with config: ButtonStyleConfiguration
    ) -> AnyView {
        AnyView(
            config.label
                .foregroundColor(
                    !config.environment.isEnabled ?
                        // SwiftUI uses tertiary afaict.
                        config.environment.suggestedForegroundColor.opacity(0.3)
                        : config.environment.suggestedForegroundColor
                )
        )
    }

    // Why 80% for active(pressed) was chosen:
    // A pressed SwiftUI .plain button looks visually the same as
    // a not pressed one at 0.8 opacity.
    // Why 50% disabled opacity was chosen:
    // A disabled SwiftUI .plain button looks visually the same as
    // an enabled one at 0.5 opacity.
    public func borderlessButtonStyleModification(
        with config: ButtonStyleConfiguration
    ) -> AnyView {
        AnyView(
            config.label
                .foregroundColor(
                    config.environment.foregroundColor ?? config.environment
                        .suggestedForegroundColor
                        .opacity(config.environment.colorScheme == .dark ? 0.7 : 0.5)
                )
                .opacity(
                    config.environment.isEnabled ? config.isPressed ? 0.80: 1.0 : 0.5
                )
        )
    }

    public func plainButtonStyleModification(
        with config: ButtonStyleConfiguration
    ) -> AnyView {
        AnyView(config.label
            .opacity(
                config.environment.isEnabled ? (config.isPressed ? 0.80: 1.0) : 0.5
            )
        )
    }
}
