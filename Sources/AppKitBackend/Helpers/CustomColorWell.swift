import AppKit

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
