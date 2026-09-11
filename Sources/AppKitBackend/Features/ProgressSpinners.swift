import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.ProgressSpinners {
    public func createProgressSpinner() -> Widget {
        let container = NSView()
        let spinner = NSProgressIndicator()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.isIndeterminate = true
        spinner.style = .spinning
        spinner.startAnimation(nil)
        container.addSubview(spinner)
        return container
    }

    public func setSize(
        ofProgressSpinner widget: Widget,
        to size: SIMD2<Int>
    ) {
        guard Int(widget.frame.size.height) != size.y else { return }
        setSize(of: widget, to: size)
        let spinner = NSProgressIndicator()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.isIndeterminate = true
        spinner.style = .spinning
        spinner.startAnimation(nil)
        spinner.widthAnchor.constraint(equalToConstant: CGFloat(size.x)).isActive = true
        spinner.heightAnchor.constraint(equalToConstant: CGFloat(size.y)).isActive = true

        widget.subviews = []
        widget.addSubview(spinner)
    }
}
