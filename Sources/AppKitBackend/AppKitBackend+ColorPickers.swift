import SwiftCrossUI
import AppKit

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

final class CustomColorWell: NSColorWell {
    init() {
        super.init(frame: .zero)

        self.target = self
        self.action = #selector(onColorChanged)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not used for this view")
    }

    private var opacity: CGFloat = 1.0

    var supportsOpacity = true {
        didSet {
            if #available(macOS 14, *) {
                super.supportsAlpha = supportsOpacity
            }
        }
    }

    override var color: NSColor {
        get {
            let color = super.color
            if !supportsOpacity {
                return color.withAlphaComponent(opacity)
            }
            return color
        }
        set {
            opacity = newValue.alphaComponent
            super.color = newValue
        }
    }

    var onChange: ((NSColor) -> Void)?

    @objc func onColorChanged() {
        onChange?(color)
    }
}
