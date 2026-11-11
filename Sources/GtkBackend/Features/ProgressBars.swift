import CGtk
import Gtk
@_spi(Backends) import SwiftCrossUI

extension GtkBackend: BackendFeatures.ProgressBars {
    public func createProgressBar() -> Widget {
        ProgressBar()
    }

    public func updateProgressBar(
        _ widget: Widget,
        progressFraction: Double?,
        environment: EnvironmentValues
    ) {
        let progressBar = widget as! ProgressBar
        progressBar.fraction = progressFraction ?? 0
        let backgroundColor: Gtk.Color
        switch environment.colorScheme {
            case .light:
                backgroundColor = Gtk.Color.eightBit(61, 61, 61, 38)
            case .dark:
                backgroundColor = Gtk.Color.eightBit(90, 90, 90)
        }
        progressBar.cssProvider.loadCss(
            from: """
                trough {
                    background-color: \(CSSProperty.rgba(backgroundColor));
                }
                """
        )
    }
}
