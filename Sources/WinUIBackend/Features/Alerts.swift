@_spi(Backends) import SwiftCrossUI
import WinUI

// swiftlint:disable force_try

extension WinUIBackend: BackendFeatures.Alerts {
    public func createAlert() -> Alert {
        Alert()
    }

    public func updateAlert(
        _ alert: Alert,
        title: String,
        actionLabels: [String],
        environment: EnvironmentValues
    ) {
        alert.title = title
        if actionLabels.count >= 1 {
            alert.primaryButtonText = actionLabels[0]
        }
        if actionLabels.count >= 2 {
            alert.secondaryButtonText = actionLabels[1]
        }
        if actionLabels.count >= 3 {
            alert.closeButtonText = actionLabels[2]
        }

        switch environment.colorScheme {
            case .light:
                alert.requestedTheme = .light
            case .dark:
                alert.requestedTheme = .dark
        }
    }

    public func showAlert(
        _ alert: Alert,
        window: WinUIBackend.Window?,
        responseHandler handleResponse: @escaping (Int) -> Void
    ) {
        // WinUI only allows one dialog at a time so we limit ourselves using
        // a semaphore.
        guard let window = window ?? windows.first else {
            logger.warning("WinUI can't show alert without window")
            return
        }

        guard let xamlRoot = window.content.xamlRoot else {
            logger.warning("WinUI can't show alert before window XamlRoot is available")
            return
        }

        alert.xamlRoot = xamlRoot
        alert.window = window

        // WinUI only allows one dialog at a time (subsequent dialogs throw
        // exceptions), so we hide any existing alert before showing the new one
        if let currentAlert = window.currentAlert {
            currentAlert.ignoreNextDismissal = true
            try! currentAlert.hide()
            alert.parentAlert = currentAlert
        }

        window.currentAlert = alert
        alert.handleResponse = handleResponse
        alert.showAttached()
    }

    public func dismissAlert(_ alert: Alert, window: WinUIBackend.Window?) {
        try! alert.hide()
        alert.window?.currentAlert = alert.parentAlert
        alert.parentAlert?.showAttached()
    }
}
