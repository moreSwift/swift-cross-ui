import SwiftCrossUI
import UIKit



//MARK: Might come back and make a shim for this :P
@available(iOS 8.0, *)
extension UIKitBackend {
    public final class Alert {
        let controller: UIAlertController
        var handler: ((Int) -> Void)?

        init() {
            self.controller = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        }
    }

    public func createAlert() -> Alert {
        Alert()
    }

    public func updateAlert(
        _ alert: Alert,
        title: String,
        actionLabels: [String],
        environment _: EnvironmentValues
    ) {
        alert.controller.title = title

        for (i, actionLabel) in actionLabels.enumerated() {
            let action = UIAlertAction(title: actionLabel, style: .default) {
                [weak alert] _ in
                guard let alert else { return }
                alert.handler?(i)
            }
            alert.controller.addAction(action)
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

        alert.handler = handleResponse
        window.rootViewController!.present(alert.controller, animated: false)
    }

    public func dismissAlert(_ alert: Alert, window: Window?) {
        alert.controller.dismiss(animated: false)
    }
}
