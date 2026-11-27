@_spi(Backends) import SwiftCrossUI
import WinUI
import Foundation

extension WinUIBackend: BackendFeatures.DatePickers {
    public var supportedDatePickerStyles: [DatePickerStyle] {
        [
            .automatic,
            .graphical,
            .compact,
            .wheel,
        ]
    }

    public func createDatePicker() -> Widget {
        return CustomDatePicker()
    }

    public func updateDatePicker(
        _ datePicker: Widget,
        environment: EnvironmentValues,
        date: Date,
        range: ClosedRange<Date>,
        components: DatePickerComponents,
        onChange: @escaping (Date) -> Void
    ) {
        let customDatePicker = datePicker as! CustomDatePicker

        if components.contains(.hourMinuteAndSecond) {
            print(
                "DatePickerComponents.hourMinuteAndSecond is not supported in WinUIBackend. Falling back to .hourAndMinute."
            )
        }

        customDatePicker.toggleTimeView(shown: components.contains(.hourAndMinute))

        if environment.timeZone != .current {
            print("environment.timeZone is has no effect in WinUIBackend.")
        }

        let dateViewType: CustomDatePicker.DateViewType.Discriminator? =
            if components.contains(.date) {
                switch environment.datePickerStyle {
                    case .automatic, .wheel:
                        .datePicker
                    case .compact:
                        .calendarDatePicker
                    case .graphical:
                        .calendarView
                }
            } else {
                nil
            }

        customDatePicker.onChange = onChange
        customDatePicker.changeDateView(to: dateViewType)
        customDatePicker.updateIfNeeded(date: date, calendar: environment.calendar)
        customDatePicker.setDateRange(to: range)
        customDatePicker.setEnabled(to: environment.isEnabled)

        // TODO(parity): foreground color ignored
        // Setting foreground like for other views works for TimePicker and DatePicker but not for
        // CalendarView or CalendarDatePicker.
    }
}
