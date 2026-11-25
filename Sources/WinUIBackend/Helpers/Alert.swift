import WinUI

public class Alert: ContentDialog {
    var window: WinUIBackend.Window?
    var parentAlert: Alert?
    var handleResponse: ((Int) -> Void)?
    var ignoreNextDismissal = false

    /// Shows an alert that has already been attached to a window (via xamlRoot),
    /// and attached to the alert stack (via parentAlert and updating
    /// window.currentAlert)
    func showAttached() {
        let promise = try! showAsync()!
        promise.completed = { [weak self] operation, status in
            guard
                let self,
                status == .completed,
                let operation,
                let result = try? operation.getResults()
            else {
                return
            }

            if !self.ignoreNextDismissal {
                // If the alert was shown over the top of another alert, show
                // the parent alert
                self.window?.currentAlert = self.parentAlert
                self.parentAlert?.showAttached()

                let index =
                    switch result {
                        case .primary: 0
                        case .secondary: 1
                        case .none: 2
                        default:
                            fatalError("WinUIBackend: Invalid dialog response")
                    }
                self.handleResponse?(index)
            } else {
                self.ignoreNextDismissal = false
            }
        }
    }
}
