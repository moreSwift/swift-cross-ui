import SwiftCrossUI
import AndroidKit

// implements BackendFeatures.Sliders
extension AndroidBackend {
    public func createSlider() -> Widget {
        CustomSlider(Self.activity, environment: Self.env).as(AndroidKit.View.self)!
    }

    public func updateSlider(
        _ slider: Widget,
        minimum: Double,
        maximum: Double,
        decimalPlaces: Int,
        environment: EnvironmentValues,
        onChange: @escaping (Double) -> Void
    ) {
        let slider = slider.as(CustomSlider.self)!

        slider.setEnabled(environment.isEnabled)
        slider.setAction(SwiftAction(environment: Self.env) {
            onChange(Double(slider.getValue()))
        })
        slider.setBounds(min: Float(minimum), max: Float(maximum), places: Int32(decimalPlaces))
    }

    public func setValue(ofSlider slider: Widget, to value: Double) {
        slider.as(CustomSlider.self)!.setValue(Float(value))
    }
}
