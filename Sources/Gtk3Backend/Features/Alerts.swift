import CGtk3
import Gtk3
@_spi(Backends) import SwiftCrossUI

extension Gtk3Backend: BackendFeatures.Alerts {
    public typealias Alert = Gtk3.MessageDialog

    public func createAlert() -> Alert {
        let dialog = Gtk3.MessageDialog()

        // The Ubuntu Gtk3 theme seems to only set the bottom corner radii.
        dialog.css.set(properties: [
            .cornerRadius(13)
        ])

        return dialog
    }

    public func updateAlert(
        _ alert: Alert,
        title: String,
        actionLabels: [String],
        environment: EnvironmentValues
    ) {
        alert.text = title
        for (i, label) in actionLabels.enumerated() {
            alert.addButton(label: label, responseId: i)
        }
    }

    public func showAlert(
        _ alert: Alert,
        window: Window?,
        responseHandler handleResponse: @escaping (Int) -> Void
    ) {
        alert.response = { _, responseId in
            guard responseId != Int(UInt32(bitPattern: -4)) else {
                // Ignore escape key for now. Once we support detecting
                // the primary and secondary actions of alerts we can wire
                // this up to whichever action is the default cancellation
                // action.
                return
            }

            alert.destroy()
            handleResponse(responseId)
        }
        alert.isModal = true
        alert.isDecorated = false
        alert.setTransient(for: window ?? windows[0])
        alert.show()
    }

    public func dismissAlert(_ alert: Alert, window: Window?) {
        alert.destroy()
    }
}
