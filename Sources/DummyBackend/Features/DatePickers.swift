@_spi(Backends) import SwiftCrossUI
import Foundation

extension DummyBackend: BackendFeatures.DatePickers {
    public var supportedDatePickerStyles: [DatePickerStyle] {
        [.automatic, .compact, .graphical]
    }

    public func createDatePicker() -> Widget {
        DatePicker()
    }

    public func updateDatePicker(
        _ datePicker: Widget,
        environment: EnvironmentValues,
        date: Date,
        range: ClosedRange<Date>,
        components: DatePickerComponents,
        onChange: @escaping (Date) -> Void
    ) {
        let datePicker = datePicker as! DatePicker
        datePicker.style = environment.datePickerStyle
        datePicker.value = date
        datePicker.range = range
        datePicker.components = components
        datePicker.onChange = onChange
        datePicker.enabled = environment.isEnabled
    }
}
