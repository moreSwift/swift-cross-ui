@_spi(Backends) import SwiftCrossUI
import Foundation

extension DummyBackend {
    public class DatePicker: Widget {
        var style: DatePickerStyle = .automatic
        var value = Date()
        var range = Date.distantPast ... Date.distantFuture
        var components: DatePickerComponents = .init(rawValue: 0)
        var onChange: ((Date) -> Void)?
        var enabled = true
    }
}
