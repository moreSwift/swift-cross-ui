import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.FileOpenDialogs {
    public func showOpenDialog(
        fileDialogOptions: FileDialogOptions,
        openDialogOptions: OpenDialogOptions,
        window: Window?,
        resultHandler handleResult: @escaping (DialogResult<[URL]>) -> Void
    ) {
        let panel = NSOpenPanel()
        panel.message = fileDialogOptions.title
        panel.prompt = fileDialogOptions.defaultButtonLabel
        panel.directoryURL = fileDialogOptions.initialDirectory
        panel.showsHiddenFiles = fileDialogOptions.showHiddenFiles
        panel.allowsOtherFileTypes = fileDialogOptions.allowOtherContentTypes

        // TODO: allowedContentTypes

        panel.allowsMultipleSelection = openDialogOptions.allowMultipleSelections
        panel.canChooseFiles = openDialogOptions.allowSelectingFiles
        panel.canChooseDirectories = openDialogOptions.allowSelectingDirectories

        let handleResponse: (NSApplication.ModalResponse) -> Void = { response in
            guard response != .continue else {
                return
            }

            if response == .OK {
                handleResult(.success(panel.urls))
            } else {
                handleResult(.cancelled)
            }
        }

        if let window {
            panel.beginSheetModal(for: window, completionHandler: handleResponse)
        } else {
            let response = panel.runModal()
            handleResponse(response)
        }
    }
}
