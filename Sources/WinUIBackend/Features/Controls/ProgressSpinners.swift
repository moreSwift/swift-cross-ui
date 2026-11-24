@_spi(Backends) import SwiftCrossUI
import WinUI

extension WinUIBackend: BackendFeatures.ProgressSpinners {
    public func createProgressSpinner() -> Widget {
        let spinner = ProgressRing()
        spinner.isIndeterminate = true
        return spinner
    }
}
