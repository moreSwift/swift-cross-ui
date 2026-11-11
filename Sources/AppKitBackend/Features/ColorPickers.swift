import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.ColorPickers {
    public func createColorPicker() -> NSView {
        CustomColorWell()
    }

    public func updateColorPicker(
        _ colorPicker: NSView,
        supportsOpacity: Bool,
        environment: EnvironmentValues,
        onChange: @escaping (Color.Resolved) -> Void
    ) {
        let colorWell = colorPicker as! CustomColorWell

        colorWell.isEnabled = environment.isEnabled
        colorWell.supportsOpacity = supportsOpacity
        colorWell.onChange = { nsColor in
            // TODO(bbrk24): Can this conversion fail?
            let rgbColor = nsColor.usingColorSpace(.genericRGB)!

            onChange(
                Color.Resolved(
                    red: Float(rgbColor.redComponent),
                    green: Float(rgbColor.greenComponent),
                    blue: Float(rgbColor.blueComponent),
                    opacity: Float(rgbColor.alphaComponent)
                )
            )
        }
    }

    public func setValue(ofColorPicker colorPicker: NSView, to color: Color.Resolved) {
        (colorPicker as! CustomColorWell).color = color.nsColor
    }
}
