import Foundation

/// Presents an 'Open file' dialog fit for selecting a single file.
@available(tvOS, unavailable, message: "tvOS does not provide file system access")
public struct PresentSingleFileOpenDialogAction: Sendable {
    let backend: any BaseAppBackend
    let window: MainActorBox<Any?>

    /// Presents an 'Open file' dialog fit for selecting a single file.
    ///
    /// - Important: GtkBackend, Gtk3Backend, and WinUIBackend will only
    ///   enable _either_ files or directories for selection, but won't
    ///   enable both types in a single dialog.
    ///
    /// - Parameters:
    ///   - title: The dialog's title. Defaults to "Open".
    ///   - message: The dialog's message. Defaults to an empty string.
    ///   - defaultButtonLabel: The label for the dialog's default button.
    ///     Defaults to "Open".
    ///   - initialDirectory: The directory to start the dialog in. Defaults
    ///     to `nil`, which lets the backend choose (usually it'll be the
    ///     app's current working directory and/or the directory where the
    ///     previous dialog was dismissed).
    ///   - showHiddenFiles: Whether to show hidden files. Defaults to `false`.
    ///   - allowSelectingFiles: Whether to allow selecting files (as opposed
    ///     to directories) in the dialog. Defaults to `true`.
    ///   - allowSelectingDirectories: Whether to allow selecting directories
    ///     in the dialog. Defaults to `true`.
    /// - Returns: The URL of the user's chosen file, or `nil` if the user
    ///   cancelled the dialog.
    public func callAsFunction(
        title: String = "Open",
        message: String = "",
        defaultButtonLabel: String = "Open",
        initialDirectory: URL? = nil,
        showHiddenFiles: Bool = false,
        allowSelectingFiles: Bool = true,
        allowSelectingDirectories: Bool = false
    ) async -> URL? {
        guard let backend = backend as? any BackendFeatures.FileOpenDialogs else {
            logger.warnOnce("\(type(of: backend)) does not support file open dialogs")
            return nil
        }

        func chooseFile<Backend: BackendFeatures.FileOpenDialogs>(backend: Backend) async -> URL? {
            await withCheckedContinuation { continuation in
                backend.runInMainThread {
                    let window = self.window.value.map { $0 as! Backend.Window }

                    backend.showOpenDialog(
                        fileDialogOptions: FileDialogOptions(
                            title: title,
                            defaultButtonLabel: defaultButtonLabel,
                            allowedContentTypes: [],
                            showHiddenFiles: showHiddenFiles,
                            allowOtherContentTypes: true,
                            initialDirectory: initialDirectory
                        ),
                        openDialogOptions: OpenDialogOptions(
                            allowSelectingFiles: allowSelectingFiles,
                            allowSelectingDirectories: allowSelectingDirectories,
                            allowMultipleSelections: false
                        ),
                        window: window
                    ) { result in
                        switch result {
                            case .success(let url):
                                continuation.resume(returning: url[0])
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
