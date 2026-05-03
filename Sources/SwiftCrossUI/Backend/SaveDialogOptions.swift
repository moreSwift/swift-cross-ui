/// Options for 'save file' dialogs.
public struct SaveDialogOptions {
    /// The placeholder label for the file name field. If `nil`, the label is
    /// set to a backend-specific value.
    public var nameFieldLabel: String?
    /// The default file name. If `nil`, the file name will typically be empty,
    /// but can be any backend-specific value.
    public var defaultFileName: String?
}
