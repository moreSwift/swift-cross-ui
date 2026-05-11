import AndroidKit
import SwiftCrossUI

extension AndroidBackend: BackendFeatures.Alerts {
    public typealias Alert = AlertFragment

    public func createAlert() -> AlertFragment {
        AlertFragment(environment: Self.env)
    }

    public func updateAlert(
        _ alert: AlertFragment,
        title: String,
        actionLabels: [String],
        environment: EnvironmentValues
    ) {
        alert.update(title, actionLabels)
    }

    public func showAlert(
        _ alert: AlertFragment,
        window: Window?,
        responseHandler handleResponse: @escaping (Int) -> Void
    ) {
        let action = SwiftAction(environment: Self.env) {
            let index = alert.getButtonIndex()
            handleResponse(Int(index))
        }

        alert.setAction(action)
        alert.show(Self.activity)
    }

    public func dismissAlert(_ alert: AlertFragment, window: Window?) {
        alert.dismiss()
    }
}
