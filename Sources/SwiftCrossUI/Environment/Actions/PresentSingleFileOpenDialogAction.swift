import Foundation

/// Presents an 'Open file' dialog fit for selecting a single file. Some
/// backends only allow selecting either files or directories but not both
/// in a single dialog. Returns `nil` if the user cancels the operation.
public struct PresentSingleFileOpenDialogAction {
    let backend: any AppBackend
    let window: MainActorBox<Any?>

    // MARK: - iOS 13+ async/await version
    /*@available(iOS 13.0, *)
    public func callAsFunction(
        title: String = "Open",
        message: String = "",
        defaultButtonLabel: String = "Open",
        initialDirectory: URL? = nil,
        showHiddenFiles: Bool = false,
        allowSelectingFiles: Bool = true,
        allowSelectingDirectories: Bool = false
    ) async -> URL? {
        func chooseFile<Backend: AppBackend>(backend: Backend) async -> URL? {
            await withCheckedContinuation { continuation in
                backend.runInMainThread {
                    let window: Backend.Window? = {
                        if let window = self.window.value {
                            return window as? Backend.Window
                        }
                        return nil
                    }()

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
                            case .success(let urls):
                                continuation.resume(returning: urls.first)
                            case .cancelled:
                                continuation.resume(returning: nil)
                        }
                    }
                }
            }
        }

        return await chooseFile(backend: backend)
    }*/

    // MARK: - iOS 12 and below version with completion handler
    public func callAsFunction(
        title: String = "Open",
        message: String = "",
        defaultButtonLabel: String = "Open",
        initialDirectory: URL? = nil,
        showHiddenFiles: Bool = false,
        allowSelectingFiles: Bool = true,
        allowSelectingDirectories: Bool = false,
        completion: @escaping (URL?) -> Void
    ) {
        func chooseFile<Backend: AppBackend>(backend: Backend, completion: @escaping (URL?) -> Void) {
            backend.runInMainThread {
                let window: Backend.Window? = {
                    if let window = self.window.value {
                        return window as? Backend.Window
                    }
                    return nil
                }()

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
                        case .success(let urls):
                            completion(urls.first)
                        case .cancelled:
                            completion(nil)
                    }
                }
            }
        }

        chooseFile(backend: backend, completion: completion)
    }
}
