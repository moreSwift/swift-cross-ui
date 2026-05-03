import Foundation

/// Reveals a file in the system's file manager.
@MainActor
public struct RevealFileAction {
    let backend: any BackendFeatures.RevealFiles

    init?<Backend: BaseAppBackend>(backend: Backend) {
        guard let backend = backend as? any BackendFeatures.RevealFiles else {
            return nil
        }
        self.backend = backend
    }

    /// Reveals a file in the system's file manager.
    ///
    /// This opens the file's enclosing directory and highlights the file.
    ///
    /// - Parameter file: The file to reveal.
    public func callAsFunction(_ file: URL) {
        do {
            try backend.revealFile(file)
        } catch {
            logger.warning(
                "failed to reveal file",
                metadata: [
                    "url": "\(file)",
                    "error": "\(error)",
                ]
            )
        }
    }
}
