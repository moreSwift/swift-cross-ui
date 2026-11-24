@_spi(Backends) import SwiftCrossUI
import WinUI
import Foundation
import WinAppSDK

extension WinUIBackend: BackendFeatures.IncomingURLs {
    public func setIncomingURLHandler(to action: @escaping (URL) -> Void) {
        let isFirstCall = incomingURLHandler == nil
        self.incomingURLHandler = action

        if isFirstCall {
            // Check if this app instance was launched by a URL activation. If it
            // was a URL activation, then handle it now.
            let args = try! AppInstance.getCurrent().getActivatedEventArgs()!
            processActivationArguments(args)
        }
    }
}
