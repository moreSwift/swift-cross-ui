import CGtk
import Gtk
@_spi(Backends) import SwiftCrossUI

extension GtkBackend: BackendFeatures.WindowClosing {
    public func close(window: Window) {
        window.close()
    }

    public func setCloseHandler(
        ofWindow window: Window,
        to action: @escaping () -> Void
    ) {
        window.onCloseRequest = { [weak self] _ in
            action()
            window.destroy()
            // Forget the closed window: its wrapper holds its widgets, and each styled widget's
            // display-wide style provider, for as long as it is in `windows`.
            self?.windows.removeAll { $0 === window }
        }
    }
}
