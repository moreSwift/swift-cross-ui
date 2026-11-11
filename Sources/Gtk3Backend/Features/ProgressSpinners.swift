import CGtk3
import Gtk3
@_spi(Backends) import SwiftCrossUI

extension Gtk3Backend: BackendFeatures.ProgressSpinners {
    public func createProgressSpinner() -> Widget {
        let spinner = Spinner()
        spinner.start()
        return spinner
    }
}
