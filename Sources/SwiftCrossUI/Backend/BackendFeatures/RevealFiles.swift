import Foundation

extension BackendFeatures {
    /// Backend methods for revealing files in the system's file manager.
    ///
    /// These are used by ``EnvironmentValues/revealFile``.
    @MainActor
    public protocol RevealFiles: Core {
        /// Reveals a file in the system's file manager.
        ///
        /// This typically opens the file's enclosing directory and highlights the
        /// file.
        ///
        /// - Parameter url: The URL of the file to reveal.
        func revealFile(_ url: URL) throws
    }
}
