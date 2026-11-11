import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.ProgressBars {
    public func createProgressBar() -> Widget {
        let progressBar = NSProgressIndicator()
        progressBar.isIndeterminate = false
        progressBar.style = .bar
        progressBar.minValue = 0
        progressBar.maxValue = 1
        return progressBar
    }

    public func updateProgressBar(
        _ widget: Widget,
        progressFraction: Double?,
        environment: EnvironmentValues
    ) {
        let progressBar = widget as! NSProgressIndicator
        progressBar.doubleValue = progressFraction ?? 0
        progressBar.appearance = environment.colorScheme.nsAppearance

        if progressFraction == nil && !progressBar.isIndeterminate {
            // Start the indeterminate animation
            progressBar.isIndeterminate = true
            progressBar.startAnimation(nil)
        } else if progressFraction != nil && progressBar.isIndeterminate {
            // Stop the indeterminate animation
            progressBar.isIndeterminate = false
            progressBar.stopAnimation(nil)
        }
    }
}
