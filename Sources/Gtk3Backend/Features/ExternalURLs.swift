import CGtk3
import Foundation
import Gtk3
@_spi(Backends) import SwiftCrossUI

extension Gtk3Backend: BackendFeatures.ExternalURLs {
    public func openExternalURL(_ url: URL) throws {
        // Used instead of gtk_uri_launcher_launch to maintain <4.10 compatibility
        var error: UnsafeMutablePointer<GError>? = nil
        gtk_show_uri(nil, url.absoluteString, guint(GDK_CURRENT_TIME), &error)

        if let error {
            throw Gtk3Error(
                code: Int(error.pointee.code),
                domain: Int(error.pointee.domain),
                message: String(cString: error.pointee.message)
            )
        }
    }
}
