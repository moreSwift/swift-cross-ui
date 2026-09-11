import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.DatePickers {
    public var supportedDatePickerStyles: [DatePickerStyle] {
        [.automatic, .graphical, .compact]
    }

    // Depending on the calendar, era is either necessary or must be omitted. Making the wrong
    // choice for the current calendar means the cursor position is reset after every keystroke. I
    // know of no simple way to tell whether NSDatePicker requires or forbids eras for a given
    // calendar, so in lieu of that I have hardcoded the calendar identifiers.
    private static let calendarsRequiringEra: Set<Calendar.Identifier> = [
        .buddhist,
        .coptic,
        .ethiopicAmeteAlem,
        .ethiopicAmeteMihret,
        .indian,
        .islamic,
        .islamicCivil,
        .islamicTabular,
        .islamicUmmAlQura,
        .japanese,
        .persian,
        .republicOfChina,
    ]

    public func createDatePicker() -> NSView {
        let datePicker = CustomDatePicker()
        datePicker.delegate = datePicker.strongDelegate
        return datePicker
    }

    public func updateDatePicker(
        _ datePicker: NSView,
        environment: EnvironmentValues,
        date: Date,
        range: ClosedRange<Date>,
        components: DatePickerComponents,
        onChange: @escaping (Date) -> Void
    ) {
        let datePicker = datePicker as! CustomDatePicker

        datePicker.isEnabled = environment.isEnabled
        datePicker.textColor = environment.suggestedForegroundColor.resolve(in: environment).nsColor

        // If the time zone is set to autoupdatingCurrent, then the cursor position is reset after
        // every keystroke. Thanks Apple
        datePicker.timeZone =
            environment.timeZone == .autoupdatingCurrent ? .current : environment.timeZone

        // A couple properties cause infinite update loops if we assign to them on every update, so
        // check their values first.
        if datePicker.calendar != environment.calendar {
            datePicker.calendar = environment.calendar
        }

        if datePicker.dateValue != date {
            datePicker.dateValue = date
        }

        var elementFlags: NSDatePicker.ElementFlags = []
        if components.contains(.date) {
            elementFlags.insert(.yearMonthDay)
            if Self.calendarsRequiringEra.contains(environment.calendar.identifier) {
                elementFlags.insert(.era)
            }
        }
        if components.contains(.hourMinuteAndSecond) {
            elementFlags.insert(.hourMinuteSecond)
        } else if components.contains(.hourAndMinute) {
            elementFlags.insert(.hourMinute)
        }

        if datePicker.datePickerElements != elementFlags {
            datePicker.datePickerElements = elementFlags
        }

        datePicker.strongDelegate.onChange = onChange

        datePicker.minDate = range.lowerBound
        datePicker.maxDate = range.upperBound

        datePicker.datePickerStyle =
            switch environment.datePickerStyle {
                case .automatic, .compact:
                    .textFieldAndStepper
                case .graphical:
                    .clockAndCalendar
            }
    }
}
