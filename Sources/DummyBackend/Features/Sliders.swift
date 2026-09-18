@_spi(Backends) import SwiftCrossUI

extension DummyBackend: BackendFeatures.Sliders {
    public func createSlider() -> Widget {
        Slider()
    }

    public func updateSlider(
        _ slider: Widget,
        minimum: Double,
        maximum: Double,
        decimalPlaces: Int,
        environment: SwiftCrossUI.EnvironmentValues,
        onChange: @escaping (Double) -> Void
    ) {
        let slider = slider as! Slider
        slider.minimumValue = minimum
        slider.maximumValue = maximum
        slider.decimalPlaces = decimalPlaces
        slider.changeHandler = onChange
    }

    public func setValue(ofSlider slider: Widget, to value: Double) {
        (slider as! Slider).value = value
    }
}
