import AppKit
import SwiftCrossUI

extension AppKitBackend {
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

    public func showSaveDialog(
        fileDialogOptions: FileDialogOptions,
        saveDialogOptions: SaveDialogOptions,
        window: Window?,
        resultHandler handleResult: @escaping (DialogResult<URL>) -> Void
    ) {
        let panel = NSSavePanel()
        panel.message = fileDialogOptions.title
        panel.prompt = fileDialogOptions.defaultButtonLabel
        panel.directoryURL = fileDialogOptions.initialDirectory
        panel.showsHiddenFiles = fileDialogOptions.showHiddenFiles
        panel.allowsOtherFileTypes = fileDialogOptions.allowOtherContentTypes

        // TODO: allowedContentTypes

        panel.nameFieldLabel = saveDialogOptions.nameFieldLabel ?? panel.nameFieldLabel
        panel.nameFieldStringValue = saveDialogOptions.defaultFileName ?? ""

        let handleResponse: (NSApplication.ModalResponse) -> Void = { response in
            guard response != .continue else {
                return
            }

            if response == .OK {
                handleResult(.success(panel.url!))
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
