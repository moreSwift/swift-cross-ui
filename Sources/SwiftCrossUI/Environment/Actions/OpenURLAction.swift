import Foundation

/// Opens a URL with the default application.
///
/// May present an application picker if multiple applications are registered
/// for the given URL protocol.
@MainActor
public struct OpenURLAction {
    let action: (URL) -> Void

    init?<Backend: AppBackend.Base>(backend: Backend) {
        guard let backend = backend as? any AppBackend.ExternalURLs else {
            return nil
        }

        action = { url in
            do {
                try backend.openExternalURL(url)
            } catch {
                logger.warning(
                    "failed to open external url",
                    metadata: [
                        "url": "\(url)",
                        "error": "\(error)",
                    ])
            }
        }
    }

    /// Opens a URL with the default application.
    ///
    /// - Parameter url: The URL to open.
    public func callAsFunction(_ url: URL) {
        action(url)
    }
}
