@_spi(Backends) import SwiftCrossUI
import WinUI

extension WinUIBackend: BackendFeatures.ProgressBars {
    public func createProgressBar() -> Widget {
        let progressBar = ProgressBar()
        progressBar.maximum = 10_000
        return progressBar
    }

    public func updateProgressBar(
        _ widget: Widget,
        progressFraction: Double?,
        environment: EnvironmentValues
    ) {
        let progressBar = widget as! ProgressBar
        if let progressFraction {
            progressBar.isIndeterminate = false
            progressBar.value = progressBar.maximum * progressFraction
        } else {
            progressBar.isIndeterminate = true
        }
    }
}
