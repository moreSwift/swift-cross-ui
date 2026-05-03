import Foundation

extension BackendFeatures {
    /// Backend methods for handling incoming URLs.
    ///
    /// These are used by ``View/onOpenURL(perform:)``.
    @MainActor
    public protocol IncomingURLs: Core {
        /// Sets the handler for URLs directed to the application (e.g. URLs
        /// associated with a custom URL scheme).
        ///
        /// - Parameter action: The incoming URL handler.
        func setIncomingURLHandler(to action: @escaping (URL) -> Void)
    }
}
