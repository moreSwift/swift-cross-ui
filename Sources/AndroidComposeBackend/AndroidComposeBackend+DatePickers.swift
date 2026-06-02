import Foundation
import SwiftCrossUI

extension AndroidComposeBackend: BackendFeatures.DatePickers {
    public var supportedDatePickerStyles: [DatePickerStyle] {
        [.automatic]
    }
  
    public func createDatePicker() -> Widget {
        let id = allocateId()
        try? bridge.createNode(id: id, type: "DatePicker")
        return id
    }

    public func updateDatePicker(
        _ datePicker: Widget,
        environment: EnvironmentValues,
        date: Date,
        range: ClosedRange<Date>,
        components: DatePickerComponents,
        onChange: @escaping (Date) -> Void
    ) {
        try? bridge.setProperty(id: datePicker, key: "value", value: "\(date.timeIntervalSince1970)")
        try? bridge.setProperty(id: datePicker, key: "rangeMin", value: "\(range.lowerBound.timeIntervalSince1970)")
        try? bridge.setProperty(id: datePicker, key: "rangeMax", value: "\(range.upperBound.timeIntervalSince1970)")
        try? bridge.setProperty(id: datePicker, key: "enabled", value: environment.isEnabled ? "true" : "false")
        handlers[datePicker, default: EventHandlers()].onChange = { payload in
            if let interval = Double(payload) {
                onChange(Date(timeIntervalSince1970: interval))
            }
        }
    }
}
