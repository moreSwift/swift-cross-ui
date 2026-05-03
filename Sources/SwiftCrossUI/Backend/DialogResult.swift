/// The result of a dialog.
public enum DialogResult<T> {
    /// The dialog succeeded with a result value.
    case success(T)
    /// The dialog was cancelled.
    case cancelled
}
