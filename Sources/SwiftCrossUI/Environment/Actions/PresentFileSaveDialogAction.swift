import Foundation

/// Presents a 'Save file' dialog fit for selecting a save destination.
public struct PresentFileSaveDialogAction: Sendable {
    let backend: any BaseAppBackend
    let window: MainActorBox<Any?>

    /// Presents a 'Save file' dialog fit for selecting a save destination.
    ///
    /// - Parameters:
    ///   - title: The dialog's title. Defaults to "Save".
    ///   - message: The dialog's message. Defaults to an empty string.
    ///   - defaultButtonLabel: The label for the dialog's default button.
    ///     Defaults to "Save".
    ///   - initialDirectory: The directory to start the dialog in. Defaults
    ///     to `nil`, which lets the backend choose (usually it'll be the
    ///     app's current working directory and/or the directory where the
    ///     previous dialog was dismissed).
    ///   - showHiddenFiles: Whether to show hidden files. Defaults to `false`.
    ///   - nameFieldLabel: The placeholder label for the file name field.
    ///     Defaults to `nil`, which uses the backend-specific default.
    ///   - defaultFileName: The default file name. Defaults to `nil`, which
    ///     uses the backend-specific default.
    /// - Returns: The URL of the user's chosen save destination, or `nil` if
    ///   the user cancelled the dialog.
    public func callAsFunction(
        title: String = "Save",
        message: String = "",
        defaultButtonLabel: String = "Save",
        initialDirectory: URL? = nil,
        showHiddenFiles: Bool = false,
        nameFieldLabel: String? = nil,
        defaultFileName: String? = nil
    ) async -> URL? {
        guard let backend = backend as? any BackendFeatures.FileSaveDialogs else {
            logger.warnOnce("\(type(of: backend)) does not support file save dialogs")
            return nil
        }

        func chooseFile<Backend: BackendFeatures.FileSaveDialogs>(backend: Backend) async -> URL? {
            return await withCheckedContinuation { continuation in
                backend.runInMainThread {
                    let window = self.window.value.map { $0 as! Backend.Window }

                    backend.showSaveDialog(
                        fileDialogOptions: FileDialogOptions(
                            title: title,
                            defaultButtonLabel: defaultButtonLabel,
                            allowedContentTypes: [],
                            showHiddenFiles: showHiddenFiles,
                            allowOtherContentTypes: true,
                            initialDirectory: initialDirectory
                        ),
                        saveDialogOptions: SaveDialogOptions(
                            nameFieldLabel: nameFieldLabel,
                            defaultFileName: defaultFileName
                        ),
                        window: window
                    ) { result in
                        switch result {
                            case .success(let url):
                                continuation.resume(returning: url)
                            case .cancelled:
                                continuation.resume(returning: nil)
                        }
                    }
                }
            }
        }
        return await chooseFile(backend: backend)
    }
}
