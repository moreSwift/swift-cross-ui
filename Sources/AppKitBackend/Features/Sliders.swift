import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.Sliders {
    public func createSlider() -> Widget {
        return NSSlider()
    }

    public func updateSlider(
        _ slider: Widget,
        minimum: Double,
        maximum: Double,
        decimalPlaces: Int,
        environment: EnvironmentValues,
        onChange: @escaping (Double) -> Void
    ) {
        // TODO: Implement decimalPlaces
        let slider = slider as! NSSlider
        slider.minValue = minimum
        slider.maxValue = maximum
        slider.onAction = { slider in
            let slider = slider as! NSSlider
            onChange(slider.doubleValue)
        }
        slider.isEnabled = environment.isEnabled
    }

    public func setValue(ofSlider slider: Widget, to value: Double) {
        let slider = slider as! NSSlider
        slider.doubleValue = value
    }
}
