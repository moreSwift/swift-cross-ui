import CGtk
import Foundation
import Gtk
@_spi(Backends) import SwiftCrossUI

extension GtkBackend: BackendFeatures.IncomingURLs {
    public func setIncomingURLHandler(to action: @escaping (URL) -> Void) {
        gtkApp.onOpen = { urls in
            for url in urls {
                action(url)
            }
        }
    }
}
