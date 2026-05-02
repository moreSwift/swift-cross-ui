extension BackendFeatures {
    /// Backend methods for sliders.
    ///
    /// These are used by ``Slider``.
    @MainActor
    public protocol Sliders: Core {
        /// Creates a slider for choosing a numerical value from a range. Predominantly used
        /// by ``Slider``.
        func createSlider() -> Widget

        /// Sets the minimum and maximum selectable value of a slider, the number of
        /// decimal places displayed by the slider, and the slider's change handler.
        ///
        /// - Parameters:
        ///   - slider: The slider to update.
        ///   - minimum: The minimum selectable value of the slider (inclusive).
        ///   - maximum: The maximum selectable value of the slider (inclusive).
        ///   - decimalPlaces: The number of decimal places displayed by the slider.
        ///   - environment: The current environment.
        ///   - onChange: The action to perform when the slider's value changes.
        ///     This replaces any existing change handlers.
        func updateSlider(
            _ slider: Widget,
            minimum: Double,
            maximum: Double,
            decimalPlaces: Int,
            environment: EnvironmentValues,
            onChange: @escaping (Double) -> Void
        )

        /// Sets the selected value of a slider.
        ///
        /// - Parameters:
        ///   - slider: The slider to set the value of.
        ///   - value: The new value.
        func setValue(ofSlider slider: Widget, to value: Double)
    }
}
