/// Options for 'open file' dialogs.
public struct OpenDialogOptions {
    /// The selection mode to use on backends that can only select one kind of
    /// item per dialog.
    public enum SingleKindSelectionMode: Equatable {
        /// Select files.
        case files
        /// Select directories (folders).
        case directories
    }

    /// Whether to allow selecting files.
    public var allowSelectingFiles: Bool
    /// Whether to allow selecting directories (folders).
    public var allowSelectingDirectories: Bool
    /// Whether to allow multiple selections. If `false`, the user can only
    /// select one item.
    public var allowMultipleSelections: Bool

    /// The mode to use on backends that can only select files or directories,
    /// but not both in the same dialog.
    ///
    /// When both files and directories are enabled, files are preferred to
    /// preserve the behavior of existing GTK and WinUI backends.
    public var singleKindSelectionMode: SingleKindSelectionMode {
        if allowSelectingFiles {
            return .files
        } else if allowSelectingDirectories {
            return .directories
        } else {
            preconditionFailure("Open dialogs must allow selecting files or directories")
        }
    }
}
