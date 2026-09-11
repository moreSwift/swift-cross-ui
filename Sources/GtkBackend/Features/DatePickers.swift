import CGtk
import Foundation
import Gtk
@_spi(Backends) import SwiftCrossUI

extension GtkBackend: BackendFeatures.DatePickers {
    public var supportedDatePickerStyles: [DatePickerStyle] { [.automatic, .graphical] }
    
    public func createDatePicker() -> Widget {
        let widget = Gtk.Calendar()
        widget.date = Date()
        return widget
    }

    public func updateDatePicker(
        _ datePicker: Widget,
        environment: EnvironmentValues,
        date: Date,
        range: ClosedRange<Date>,
        components: DatePickerComponents,
        onChange: @escaping (Date) -> Void
    ) {
        if components.contains(.hourAndMinute) {
            debugLogOnce("Warning: time picker is unimplemented on GtkBackend")
        }

        let calendarWidget = datePicker as! Gtk.Calendar
        calendarWidget.date = date
        calendarWidget.daySelected = { calendarWidget in
            let date = max(range.lowerBound, min(calendarWidget.date, range.upperBound))
            calendarWidget.date = date
            onChange(date)
        }
        calendarWidget.sensitive = environment.isEnabled
        calendarWidget.css.clear()
        calendarWidget.css.set(properties: Self.cssProperties(for: environment, isControl: true))
    }
}
