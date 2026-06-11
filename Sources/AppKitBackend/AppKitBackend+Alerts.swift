import AppKit
import SwiftCrossUI

extension AppKitBackend {
    public typealias Alert = NSAlert

    public func createAlert() -> Alert {
        NSAlert()
    }

    public func updateAlert(
        _ alert: Alert,
        title: String,
        actionLabels: [String],
        environment: EnvironmentValues
    ) {
        alert.messageText = title
        for label in actionLabels {
            alert.addButton(withTitle: label)
        }
    }

    public func showAlert(
        _ alert: Alert,
        window: Window?,
        responseHandler handleResponse: @escaping (Int) -> Void
    ) {
        let completionHandler: (NSApplication.ModalResponse) -> Void = { response in
            guard response != .stop, response != .continue else {
                return
            }

            guard response != .abort, response != .cancel else {
                logger.warning("got abort or cancel modal response, unexpected and unhandled")
                return
            }

            let firstButton = NSApplication.ModalResponse.alertFirstButtonReturn.rawValue
            let action = response.rawValue - firstButton
            handleResponse(action)
        }

        if let window {
            alert.beginSheetModal(
                for: window,
                completionHandler: completionHandler
            )
        } else {
            let response = alert.runModal()
            completionHandler(response)
        }
    }

    public func dismissAlert(_ alert: Alert, window: Window?) {
        if let window {
            window.endSheet(alert.window)
        } else {
            NSApplication.shared.stopModal()
        }
    }
}
