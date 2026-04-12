#if !os(tvOS)
    import SwiftCrossUI
    import UIKit

    extension UIKitBackend: BackendFeatures.FileOpenDialogs {
        final class FilePickerDelegate: NSObject, UIDocumentPickerDelegate {
            var resultHandler: ((DialogResult<[URL]>) -> Void)

            init(resultHandler: @escaping (DialogResult<[URL]>) -> Void) {
                self.resultHandler = resultHandler
            }

            func documentPicker(
                _ controller: UIDocumentPickerViewController,
                didPickDocumentsAt urls: [URL]
            ) {
                resultHandler(.success(urls))
            }

            func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
                resultHandler(.cancelled)
            }
        }

        public func showOpenDialog(
            fileDialogOptions: FileDialogOptions,
            openDialogOptions: OpenDialogOptions,
            window: UIWindow?,
            resultHandler handleResult: @escaping (DialogResult<[URL]>) -> Void
        ) {
            var allowedTypes: [String] = []

            if openDialogOptions.allowSelectingDirectories {
                allowedTypes.append("public.directory")
            }

            // TODO(#235): Respect fileDialogOptions.allowedContentTypes and fileDialogOptions.allowOtherContentTypes
            if openDialogOptions.allowSelectingFiles {
                allowedTypes.append("public.data")
            }

            let pickerController = UIDocumentPickerViewController(
                documentTypes: allowedTypes,
                in: .import
            )

            pickerController.allowsMultipleSelection = openDialogOptions.allowMultipleSelections
            pickerController.directoryURL = fileDialogOptions.initialDirectory

            pickerController.shouldShowFileExtensions =
                fileDialogOptions.allowOtherContentTypes
                || fileDialogOptions.allowedContentTypes.count > 1

            let delegate = FilePickerDelegate(resultHandler: handleResult)
            pickerController.delegate = delegate
            self.filePickerDelegates.setObject(delegate, forKey: pickerController)

            guard let window = window ?? Self.mainWindow else {
                fatalError(
                    "Attempting to present an open dialog before any windows have been created"
                )
            }

            window.rootViewController!.present(pickerController, animated: true)
        }
    }
#endif
