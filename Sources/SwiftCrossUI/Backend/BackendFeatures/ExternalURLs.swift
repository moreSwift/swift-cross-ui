import Foundation

extension BackendFeatures {
    /// Backend methods for opening URLs in external apps.
    ///
    /// These are used by ``EnvironmentValues/openURL``.
    @MainActor
    public protocol ExternalURLs: Core {
        /// Opens an external URL in the system browser or app registered for the
        /// URL's protocol.
        ///
        /// - Parameter url: The URL to open.
        func openExternalURL(_ url: URL) throws
    }
}
