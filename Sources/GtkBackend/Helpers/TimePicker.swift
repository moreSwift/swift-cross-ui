import CGtk
import Foundation
import Gtk

// This class is incomplete and unused. It was meant to implement time components for DatePicker,
// but I couldn't get the spin buttons to work. TODOs include:
// - Fix the spin buttons
// - Update the strings in the AM/PM picker when the locale changes
// - Replace the calls to calendar.date(bySetting:value:of:) with something that actually does what we need
// - Implement range when possible
@available(macOS 13, *)
final class TimePicker: Box {
    private var hourCycle: Locale.HourCycle
    private let hourPicker: SpinButton
    private let hourMinuteSeparator = Label(string: ":")
    private let minutePicker = SpinButton(range: 0, max: 59, step: 1)
    private var minuteSecondSeparator: Label?
    private var secondPicker: SpinButton?
    private var amPmPicker: DropDown?

    var onChange: ((Date) -> Void)?

    init() {
        let hourCycle = Locale.current.hourCycle

        self.hourCycle = hourCycle
        self.hourPicker = SpinButton(
            range: TimePicker.minHour(for: hourCycle),
            max: TimePicker.maxHour(for: hourCycle),
            step: 1
        )

        super.init(gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0))

        self.hourPicker.wrap = true
        self.hourPicker.orientation = .vertical
        self.hourPicker.numeric = true
        self.minutePicker.wrap = true
        self.minutePicker.orientation = .vertical
        self.minutePicker.numeric = true

        self.add(self.hourPicker)
        self.add(self.hourMinuteSeparator)
        self.add(self.minutePicker)
    }

    func setEnabled(to isEnabled: Bool) {
        hourPicker.sensitive = isEnabled
    }

    private static func minHour(for hourCycle: Locale.HourCycle) -> Double {
        switch hourCycle {
            case .zeroToEleven, .zeroToTwentyThree: 0
            case .oneToTwelve, .oneToTwentyFour: 1
            #if os(macOS)
                @unknown default: fatalError("Unrecognized hourCycle \(hourCycle)")
            #endif
        }
    }

    private static func maxHour(for hourCycle: Locale.HourCycle) -> Double {
        switch hourCycle {
            case .zeroToEleven: 11
            case .oneToTwelve: 12
            case .zeroToTwentyThree: 23
            case .oneToTwentyFour: 24
            #if os(macOS)
                @unknown default: fatalError("Unrecognized hourCycle \(hourCycle)")
            #endif
        }
    }

    func update(calendar: Foundation.Calendar, date: Date, showSeconds: Bool) {
        let components = calendar.dateComponents([.hour, .minute, .second], from: date)

        if showSeconds {
            let secondsRange = calendar.range(of: .second, in: .minute, for: date) ?? 0..<60
            if let secondPicker {
                secondPicker.setRange(
                    min: Double(secondsRange.lowerBound),
                    max: Double(secondsRange.upperBound - 1)
                )
            } else {
                minuteSecondSeparator = Label(string: ":")
                secondPicker = SpinButton(
                    range: Double(secondsRange.lowerBound),
                    max: Double(secondsRange.upperBound - 1),
                    step: 1
                )
                secondPicker!.numeric = true
                secondPicker!.wrap = true
                secondPicker!.text = "\(components.second!)"
                insert(child: minuteSecondSeparator!, after: minutePicker)
                insert(child: secondPicker!, after: minuteSecondSeparator!)
            }
        } else {
            if let minuteSecondSeparator {
                remove(minuteSecondSeparator)
                self.minuteSecondSeparator = nil
            }
            if let secondPicker {
                remove(secondPicker)
                self.secondPicker = nil
            }
        }

        let minutesRange = calendar.range(of: .minute, in: .hour, for: date) ?? 0..<60
        minutePicker.setRange(
            min: Double(minutesRange.lowerBound),
            max: Double(minutesRange.upperBound - 1)
        )
        minutePicker.text = "\(components.minute!)"
        minutePicker.valueChanged = { [unowned self] minutePicker in
            guard
                let value = Int(exactly: minutePicker.value),
                let newDate = calendar.date(bySetting: .minute, value: value, of: date)
            else {
                return
            }
            self.onChange?(newDate)
        }

        let hoursRange = calendar.range(of: .hour, in: .day, for: date)
        self.hourCycle = (calendar.locale ?? .current).hourCycle
        let effectiveHours = hoursRange?.map {
            TimePicker.transformToRange($0, hourCycle: self.hourCycle)
        }

        hourPicker.setRange(
            min: effectiveHours?.min().map(Double.init(_:))
                ?? TimePicker.minHour(for: self.hourCycle),
            max: effectiveHours?.max().map(Double.init(_:))
                ?? TimePicker.maxHour(for: self.hourCycle)
        )

        if self.hourCycle == .oneToTwelve || self.hourCycle == .zeroToEleven {
            if let amPmPicker {
                // update strings if necessary
            } else {
                amPmPicker = DropDown(strings: [calendar.amSymbol, calendar.pmSymbol])
                add(amPmPicker!)
            }
        } else {
            if let amPmPicker {
                remove(amPmPicker)
                self.amPmPicker = nil
            }
        }

        hourPicker.text =
            "\(TimePicker.transformToRange(components.hour!, hourCycle: self.hourCycle))"
        hourPicker.valueChanged = { [unowned self] hourPicker in
            guard
                let value = Int(exactly: hourPicker.value),
                let newDate = calendar.date(bySetting: .hour, value: value, of: date)
            else {
                return
            }
            self.onChange?(newDate)
        }
    }

    private static func transformToRange(_ value: Int, hourCycle: Locale.HourCycle) -> Int {
        switch hourCycle {
            case .zeroToEleven: value % 12
            case .oneToTwelve: (value + 11) % 12 + 1
            case .zeroToTwentyThree: value % 24
            case .oneToTwentyFour: (value + 23) % 24 + 1
            #if os(macOS)
                @unknown default: fatalError("Unrecognized hourCycle \(hourCycle)")
            #endif
        }
    }
}
