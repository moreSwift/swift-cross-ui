import CGtk3
import Gtk3
@_spi(Backends) import SwiftCrossUI

extension Gtk3Backend: BackendFeatures.WindowClosing {
    public func close(window: Window) {
        window.close()

        // NB: It seems GTK3 won't automatically signal `::delete-event` if
        // the window is closed programmatically. Since the close handler
        // calls `window.destroy()`, we avoid calling that ourselves to avoid
        // a double-free; however, if the handler isn't set, we _do_ call
        // `destroy()` to avoid leaking the window.
        if let onCloseRequest = window.onCloseRequest {
            onCloseRequest(window)
        } else {
            window.destroy()
        }
    }

    public func setCloseHandler(
        ofWindow window: Window,
        to action: @escaping () -> Void
    ) {
        window.onCloseRequest = { _ in
            action()
            window.destroy()
        }
    }
}
