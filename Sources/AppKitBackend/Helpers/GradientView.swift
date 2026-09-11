import AppKit

class GradientView: NSView {
    override var isFlipped: Bool { true }

    func setGradientLayer(to layer: CAGradientLayer) {
        self.layer = layer
        layer.drawsAsynchronously = true
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        self.wantsLayer = true
    }
}
