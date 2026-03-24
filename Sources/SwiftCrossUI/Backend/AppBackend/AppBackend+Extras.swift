import Foundation

@MainActor
public protocol AppBackend_ExternalURLs: AppBackend_Base {
    /// Sets the handler for URLs directed to the application (e.g. URLs
    /// associated with a custom URL scheme).
    ///
    /// - Parameter action: The incoming URL handler.
    func setIncomingURLHandler(to action: @escaping (URL) -> Void)
    

    /// Opens an external URL in the system browser or app registered for the
    /// URL's protocol.
    ///
    /// - Parameter url: The URL to open.
    func openExternalURL(_ url: URL) throws
}

@MainActor
public protocol AppBackend_RevealFile: AppBackend_Base {
    /// Reveals a file in the system's file manager.
    ///
    /// This typically opens the file's enclosing directory and highlights the
    /// file.
    ///
    /// - Parameter url: The URL of the file to reveal.
    func revealFile(_ url: URL) throws
}
