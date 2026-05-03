import Foundation

/// The result returned when a user either selects a file or dismisses the
/// file chooser dialog.
public enum FileChooserResult {
    /// The user selected a file at the given URL.
    case success(URL)
    /// The user closed the file chooser dialog.
    case cancelled
}
