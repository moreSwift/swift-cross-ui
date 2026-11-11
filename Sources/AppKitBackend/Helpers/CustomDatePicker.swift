import AppKit

final class CustomDatePicker: NSDatePicker {
    var strongDelegate = CustomDatePickerDelegate()
}

final class CustomDatePickerDelegate: NSObject, NSDatePickerCellDelegate {
    var onChange: ((Date) -> Void)?

    func datePickerCell(
        _: NSDatePickerCell,
        validateProposedDateValue proposedDateValue: AutoreleasingUnsafeMutablePointer<NSDate>,
        timeInterval _: UnsafeMutablePointer<TimeInterval>?
    ) {
        onChange?(proposedDateValue.pointee as Date)
    }
}
