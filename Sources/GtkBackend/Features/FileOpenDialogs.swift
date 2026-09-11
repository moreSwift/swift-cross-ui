import CGtk
import Foundation
import Gtk
@_spi(Backends) import SwiftCrossUI

extension GtkBackend: BackendFeatures.FileOpenDialogs {
    public func showOpenDialog(
        fileDialogOptions: FileDialogOptions,
        openDialogOptions: OpenDialogOptions,
        window: Window?,
        resultHandler handleResult: @escaping (DialogResult<[URL]>) -> Void
    ) {
        // See FileSaveDialogs feature implementation
        showFileChooserDialog(
            fileDialogOptions: fileDialogOptions,
            action: .open,
            configure: { chooser in
                chooser.selectMultiple = openDialogOptions.allowMultipleSelections
            },
            window: window ?? windows[0],
            resultHandler: handleResult
        )
    }
}
