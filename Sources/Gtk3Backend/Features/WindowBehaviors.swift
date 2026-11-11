import CGtk3
import Gtk3
@_spi(Backends) import SwiftCrossUI

extension Gtk3Backend: BackendFeatures.WindowBehaviors {
    public func setBehaviors(
        ofWindow window: Window,
        closable: Bool,
        minimizable: Bool,
        resizable: Bool
    ) {
        // FIXME: This doesn't seem to work on macOS at least
        window.deletable = closable

        // TODO: Figure out if there's some magic way to disable minimization
        //   in a framework where the minimize button usually doesn't even exist

        window.resizable = resizable
    }
}
