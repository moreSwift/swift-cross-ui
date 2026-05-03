/// Options for 'open file' dialogs.
public struct OpenDialogOptions {
    /// Whether to allow selecting files.
    public var allowSelectingFiles: Bool
    /// Whether to allow selecting directories (folders).
    public var allowSelectingDirectories: Bool
    /// Whether to allow multiple selections. If `false`, the user can only
    /// select one item.
    public var allowMultipleSelections: Bool
}
