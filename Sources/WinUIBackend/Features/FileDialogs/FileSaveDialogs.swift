@_spi(Backends) import SwiftCrossUI
import WinUI

extension WinUIBackend: BackendFeatures.FileSaveDialogs {
    public func showSaveDialog(
        fileDialogOptions: FileDialogOptions,
        saveDialogOptions: SaveDialogOptions,
        window: Window?,
        resultHandler handleResult: @escaping (DialogResult<URL>) -> Void
    ) {
        let picker = FileSavePicker()

        let window = window ?? windows[0]
        let hwnd = window.getHWND()!
        let interface: SwiftIInitializeWithWindow = try! picker.thisPtr.QueryInterface()
        try! interface.initialize(with: hwnd)

        _ = picker.fileTypeChoices.insert("Text", [".txt"].toVector())
        let promise = try! picker.pickSaveFileAsync()!
        promise.completed = { operation, status in
            let result: DialogResult<URL> = Self.handleAsyncOperationCompletion(
                operation,
                status
            ) { result in
                    let file = URL(fileURLWithPath: result.path)
                    return .success(file)
                } onFailure: {
                    return .cancelled
                }
            handleResult(result)
        }
    }
}
