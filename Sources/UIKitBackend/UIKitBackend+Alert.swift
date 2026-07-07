@_spi(Backends) import SwiftCrossUI
import UIKit

extension UIKitBackend {
    public typealias Alert = UIAlertController

    final class CustomAlertAction: UIAlertAction {
        var handler: (() -> Void)?
    }

    public func createAlert() -> Alert {
        Alert(title: nil, message: nil, preferredStyle: .alert)
    }

    public func updateAlert(
        _ alert: Alert,
        title: String,
        actionLabels: [String],
        environment _: EnvironmentValues
    ) {
        alert.title = title

        for actionLabel in actionLabels {
            let action = CustomAlertAction(title: actionLabel, style: .default) { action in
                (action as! CustomAlertAction).handler?()
            }
            alert.addAction(action)
        }
    }

    public func showAlert(
        _ alert: Alert,
        window: Window?,
        responseHandler handleResponse: @escaping (Int) -> Void
    ) {
        guard let window = window ?? Self.mainWindow else {
            assertionFailure("Could not find window in which to display alert")
            return
        }

        for (index, action) in alert.actions.enumerated() {
            (action as! CustomAlertAction).handler = { handleResponse(index) }
        }
        window.rootViewController!.present(alert, animated: true)
    }

    public func dismissAlert(_ alert: Alert, window: Window?) {
        alert.dismiss(animated: true)
    }
}
