import Foundation

/// Reveals a file in the system's file manager.
@MainActor
public struct RevealFileAction {
    let action: (URL) -> Void

    init?<Backend: AppBackend.Base>(backend: Backend) {
        guard let backend = backend as? any AppBackend.RevealFile else {
            return nil
        }

        action = { file in
            do {
                try backend.revealFile(file)
            } catch {
                logger.warning(
                    "failed to reveal file",
                    metadata: [
                        "url": "\(file)",
                        "error": "\(error)",
                    ])
            }
        }
    }

    /// Reveals a file in the system's file manager.
    ///
    /// This opens the file's enclosing directory and highlights the file.
    ///
    /// - Parameter file: The file to reveal.
    public func callAsFunction(_ file: URL) {
        action(file)
    }
}
