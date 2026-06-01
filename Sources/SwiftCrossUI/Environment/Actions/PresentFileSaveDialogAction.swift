import Foundation

/// Presents a 'Save file' dialog fit for selecting a save destination. Returns
/// `nil` if the user cancels the operation.
public struct PresentFileSaveDialogAction: Sendable {
    let backend: any AppBackend
    let window: MainActorBox<Any?>
    
    /*@available(iOS 13, *)
    public func callAsFunction(
        title: String = "Save",
        message: String = "",
        defaultButtonLabel: String = "Save",
        initialDirectory: URL? = nil,
        showHiddenFiles: Bool = false,
        nameFieldLabel: String? = nil,
        defaultFileName: String? = nil
    ) async -> URL? {
        func chooseFile<Backend: AppBackend>(backend: Backend) async -> URL? {
            return await withCheckedContinuation { continuation in
                backend.runInMainThread {
                    let window: Backend.Window? =
                        if let window = self.window.value {
                            .some(window as! Backend.Window)
                        } else {
                            nil
                        }

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
    }*/
    
    // MARK: - iOS 12 and below version with completion handler
    public func callAsFunction(
        title: String = "Save",
        message: String = "",
        defaultButtonLabel: String = "Save",
        initialDirectory: URL? = nil,
        showHiddenFiles: Bool = false,
        nameFieldLabel: String? = nil,
        defaultFileName: String? = nil,
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
                            completion(url)
                        case .cancelled:
                            completion(nil)
                    }
                }
            }
        }

        chooseFile(backend: backend, completion: completion)
    }
}
