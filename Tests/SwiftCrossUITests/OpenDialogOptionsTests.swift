import Testing

@testable import SwiftCrossUI

@Suite("Testing open dialog options")
struct OpenDialogOptionsTests {
    @Test("Files-only dialogs use file selection mode")
    func filesOnlySingleKindSelectionMode() {
        let options = OpenDialogOptions(
            allowSelectingFiles: true,
            allowSelectingDirectories: false,
            allowMultipleSelections: false
        )

        #expect(options.singleKindSelectionMode == .files)
    }

    @Test("Directories-only dialogs use directory selection mode")
    func directoriesOnlySingleKindSelectionMode() {
        let options = OpenDialogOptions(
            allowSelectingFiles: false,
            allowSelectingDirectories: true,
            allowMultipleSelections: false
        )

        #expect(options.singleKindSelectionMode == .directories)
    }

    @Test("Mixed dialogs prefer file selection mode for single-kind backends")
    func mixedSingleKindSelectionMode() {
        let options = OpenDialogOptions(
            allowSelectingFiles: true,
            allowSelectingDirectories: true,
            allowMultipleSelections: false
        )

        #expect(options.singleKindSelectionMode == .files)
    }
}
