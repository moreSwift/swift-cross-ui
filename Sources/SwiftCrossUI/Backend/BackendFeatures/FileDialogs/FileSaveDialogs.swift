import Foundation

extension BackendFeatures {
    /// Backend methods for file save dialogs.
    ///
    /// These are used by ``EnvironmentValues/chooseFileSaveDestination``.
    @MainActor
    public protocol FileSaveDialogs: Core {
        /// Presents a 'Save file' dialog to the user for selecting a file save
        /// destination.
        ///
        /// - Parameters:
        ///   - fileDialogOptions: The general file dialog options to use.
        ///   - saveDialogOptions: The save dialog-specific options to use.
        ///   - window: The window to attach the dialog to. If `nil`, the backend
        ///     can either make the dialog a whole app modal, a standalone window,
        ///     or a modal for a window of its choosing.
        ///   - handleResult: The action to perform when the user chooses a
        ///     destination or cancels the dialog. Receives a `DialogResult<URL>`.
        func showSaveDialog(
            fileDialogOptions: FileDialogOptions,
            saveDialogOptions: SaveDialogOptions,
            window: Window?,
            resultHandler handleResult: @escaping (DialogResult<URL>) -> Void
        )
    }
}
