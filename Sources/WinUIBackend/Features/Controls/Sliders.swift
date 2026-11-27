@_spi(Backends) import SwiftCrossUI
import WinUI

extension WinUIBackend: BackendFeatures.Sliders {
    public func createSlider() -> Widget {
        let slider = Slider()
        slider.valueChanged.addHandler { [weak internalState, weak slider] _, event in
            guard
                let internalState,
                let slider
            else { return }

            internalState.sliderChangeActions[ObjectIdentifier(slider)]?(
                Double(event?.newValue ?? 0)
            )
        }
        slider.stepFrequency = 0.01
        return slider
    }

    public func updateSlider(
        _ slider: Widget,
        minimum: Double,
        maximum: Double,
        decimalPlaces _: Int,
        environment: EnvironmentValues,
        onChange: @escaping (Double) -> Void
    ) {
        let slider = slider as! WinUI.Slider
        slider.minimum = minimum
        slider.maximum = maximum
        environment.apply(to: slider)
        internalState.sliderChangeActions[ObjectIdentifier(slider)] = onChange
    }

    public func setValue(ofSlider slider: Widget, to value: Double) {
        let slider = slider as! WinUI.Slider
        slider.value = value
    }
}
