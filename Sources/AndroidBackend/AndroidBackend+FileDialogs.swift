import Foundation
import SwiftCrossUI
import SwiftJava

extension AndroidBackend: BackendFeatures.FileOpenDialogs {
    public func showOpenDialog(
        fileDialogOptions: FileDialogOptions,
        openDialogOptions: OpenDialogOptions,
        window: Window?,
        resultHandler handleResult: @escaping (DialogResult<[Foundation.URL]>) -> Void
    ) {
        let startingFolder = fileDialogOptions.initialDirectory.map {
            JavaString($0.absoluteString, environment: Self.env)
        }

        if openDialogOptions.allowSelectingFiles {
            let options = FilesActivityContract.Options(
                openDialogOptions.allowMultipleSelections,
                fileDialogOptions.allowedContentTypes.flatMap(\.mimeTypes),
                startingFolder,
                environment: Self.env
            )
            Self.fileDialogCallback = {
                handleResult($0.isEmpty ? .cancelled : .success($0))
            }
            helpers.launchFilesActivity(options)
        } else if openDialogOptions.allowSelectingDirectories {
            Self.folderDialogCallback = { url in
                if let url {
                    handleResult(.success([url]))
                } else {
                    handleResult(.cancelled)
                }
            }
            helpers.launchFolderActivity(startingFolder)
        } else {
            preconditionFailure("Neither file nor directory selection allowed?!")
        }
    }
}
