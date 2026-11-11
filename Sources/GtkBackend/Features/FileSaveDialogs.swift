import CGtk
import Foundation
import Gtk
@_spi(Backends) import SwiftCrossUI

extension GtkBackend: BackendFeatures.FileSaveDialogs {
    public func showSaveDialog(
        fileDialogOptions: FileDialogOptions,
        saveDialogOptions: SaveDialogOptions,
        window: Window?,
        resultHandler handleResult: @escaping (DialogResult<URL>) -> Void
    ) {
        showFileChooserDialog(
            fileDialogOptions: fileDialogOptions,
            action: .save,
            configure: { chooser in
                if let defaultFileName = saveDialogOptions.defaultFileName {
                    chooser.setCurrentName(defaultFileName)
                }
            },
            window: window ?? windows[0]
        ) { result in
            switch result {
                case .success(let urls):
                    handleResult(.success(urls[0]))
                case .cancelled:
                    handleResult(.cancelled)
            }
        }

    }

    func showFileChooserDialog(
        fileDialogOptions: FileDialogOptions,
        action: FileChooserAction,
        configure: (Gtk.FileChooserNative) -> Void,
        window: Window?,
        resultHandler handleResult: @escaping (DialogResult<[URL]>) -> Void
    ) {
        let chooser = Gtk.FileChooserNative(
            title: fileDialogOptions.title,
            parent: window?.widgetPointer.cast(),
            action: action.toGtk(),
            acceptLabel: fileDialogOptions.defaultButtonLabel,
            cancelLabel: "Cancel"
        )

        if let initialDirectory = fileDialogOptions.initialDirectory {
            chooser.setCurrentFolder(initialDirectory)
        }

        configure(chooser)

        chooser.registerSignals()
        chooser.response = { (_: NativeDialog, response: Int) -> Void in
            // Release our intentional retain cycle which ironically only exists
            // because of this line. The retain cycle keeps the file chooser
            // around long enough for the user to respond (it gets released
            // immediately if we don't do this in the response signal handler).
            chooser.response = nil

            let response = Int32(bitPattern: UInt32(UInt(response)))
            if response == Int(ResponseType.accept.toGtk().rawValue) {
                let files = chooser.getFiles()
                var urls: [URL] = []
                for i in 0..<files.count {
                    let url = URL(
                        fileURLWithPath: GFile(files[i]).path
                    )
                    urls.append(url)
                }
                handleResult(.success(urls))
            } else {
                handleResult(.cancelled)
            }
        }

        gtk_native_dialog_show(chooser.gobjectPointer.cast())
    }
}
