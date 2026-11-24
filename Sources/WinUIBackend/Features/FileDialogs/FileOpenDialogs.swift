@_spi(Backends) import SwiftCrossUI
import WinUI

extension WinUIBackend: BackendFeatures.FileOpenDialogs {
    public func showOpenDialog(
        fileDialogOptions: FileDialogOptions,
        openDialogOptions: OpenDialogOptions,
        window: Window?,
        resultHandler handleResult: @escaping (DialogResult<[URL]>) -> Void
    ) {
        let picker = FileOpenPicker()

        let window = window ?? windows[0]
        let hwnd = window.getHWND()!
        let interface: SwiftIInitializeWithWindow = try! picker.thisPtr.QueryInterface()
        try! interface.initialize(with: hwnd)

        picker.fileTypeFilter.append("*")

        if openDialogOptions.allowMultipleSelections {
            let promise = try! picker.pickMultipleFilesAsync()!
            promise.completed = { operation, status in
                let result: DialogResult<[URL]> = Self.handleAsyncOperationCompletion(
                    operation,
                    status
                ) { result in
                        let files = Array(result).compactMap { $0 }
                            .map(\.path)
                            .map(URL.init(fileURLWithPath:))
                        return .success(files)
                    } onFailure: {
                        return .cancelled
                    }
                handleResult(result)
            }
        } else {
            let promise = try! picker.pickSingleFileAsync()!
            promise.completed = { operation, status in
                let result: DialogResult<[URL]> = Self.handleAsyncOperationCompletion(
                    operation,
                    status
                ) { result in
                        let file = URL(fileURLWithPath: result.path)
                        return .success([file])
                    } onFailure: {
                        return .cancelled
                    }
                handleResult(result)
            }
        }
    }
}
