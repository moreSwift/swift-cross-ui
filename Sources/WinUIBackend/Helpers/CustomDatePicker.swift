import Foundation
import WinUI
import WindowsFoundation

@MainActor
final class CustomDatePicker: StackPanel {
    override init() {
        super.init()
        self.spacing = 10
    }

    deinit {
        timeChangedEvent?.dispose()
        dateChangedEvent?.dispose()
    }

    enum DateViewType {
        case calendarView(CalendarView)
        case calendarDatePicker(CalendarDatePicker)
        case datePicker(WinUI.DatePicker)

        var asControl: Control {
            switch self {
                case .calendarView(let calendarView): calendarView
                case .calendarDatePicker(let calendarDatePicker): calendarDatePicker
                case .datePicker(let datePicker): datePicker
            }
        }

        enum Discriminator {
            case calendarView
            case calendarDatePicker
            case datePicker
        }

        var discriminator: Discriminator {
            switch self {
                case .calendarView(_): .calendarView
                case .calendarDatePicker(_): .calendarDatePicker
                case .datePicker(_): .datePicker
            }
        }
    }

    private var dateView: DateViewType?
    private var timeView: TimePicker?
    private var date = Date()
    private var calendar = Calendar.current
    private var needsUpdate = false
    var onChange: ((Date) -> Void)?
    private var timeChangedEvent: EventCleanup?
    private var dateChangedEvent: EventCleanup?

    func toggleTimeView(shown: Bool) {
        guard shown != (self.timeView != nil) else { return }

        if shown {
            let timeView = TimePicker()
            children.append(timeView)
            self.timeView = timeView
            timeChangedEvent = timeView.timeChanged.addHandler { [unowned self] _, change in
                guard let change else { return }
                self.date =
                    calendar.startOfDay(for: date)
                        + Double(change.newTime.duration) / ticksPerSecond
                self.onChange?(self.date)
            }
            needsUpdate = true
        } else {
            timeChangedEvent?.dispose()
            timeChangedEvent = nil
            children.removeAtEnd()
            self.timeView = nil
        }
    }

    func setEnabled(to isEnabled: Bool) {
        dateView?.asControl.isEnabled = isEnabled
        timeView?.isEnabled = isEnabled
    }

    func changeDateView(to newDiscriminator: DateViewType.Discriminator?) {
        guard newDiscriminator != dateView?.discriminator else { return }

        dateChangedEvent?.dispose()
        if dateView != nil {
            children.removeAt(0)
        }

        switch newDiscriminator {
            case .calendarView:
                let calendarView = CalendarView()
                dateView = .calendarView(calendarView)
                children.insertAt(0, calendarView)
                orientation = .vertical
                dateChangedEvent = calendarView.selectedDatesChanged.addHandler {
                    [unowned self] _, _ in

                    guard calendarView.selectedDates.size > 0 else {
                        let (dateTime, _) = foundationDateToComponents(self.date)
                        calendarView.selectedDates.append(dateTime)
                        return
                    }

                    self.date = componentsToFoundationDate(
                        dateTime: calendarView.selectedDates.getAt(0),
                        timeSpan: timeView?.selectedTime
                    )

                    if calendarView.selectedDates.size > 1 {
                        self.needsUpdate = true
                    }

                    self.onChange?(self.date)
                }
                needsUpdate = true
            case .calendarDatePicker:
                let calendarDatePicker = CalendarDatePicker()
                dateView = .calendarDatePicker(calendarDatePicker)
                children.insertAt(0, calendarDatePicker)
                orientation = .horizontal
                dateChangedEvent = calendarDatePicker.dateChanged.addHandler {
                    [unowned self] _, change in

                    guard let newDate = change?.newDate else { return }
                    self.date = componentsToFoundationDate(
                        dateTime: newDate,
                        timeSpan: timeView?.selectedTime
                    )
                    self.onChange?(self.date)
                }
                needsUpdate = true
            case .datePicker:
                let datePicker = WinUI.DatePicker()
                dateView = .datePicker(datePicker)
                children.insertAt(0, datePicker)
                orientation = .horizontal
                dateChangedEvent = datePicker.selectedDateChanged.addHandler {
                    [unowned self] _, _ in

                    guard let selectedDate = datePicker.selectedDate else { return }
                    self.date = componentsToFoundationDate(
                        dateTime: selectedDate,
                        timeSpan: timeView?.selectedTime
                    )
                    self.onChange?(self.date)
                }
                needsUpdate = true
            case nil:
                break
        }
    }

    func setDateRange(to range: ClosedRange<Date>) {
        guard let dateView else { return }

        let (startDate, _) = foundationDateToComponents(range.lowerBound)
        let (endDate, _) = foundationDateToComponents(range.upperBound)

        switch dateView {
            case .calendarView(let calendarView):
                calendarView.minDate = startDate
                calendarView.maxDate = endDate
            case .calendarDatePicker(let calendarDatePicker):
                calendarDatePicker.minDate = startDate
                calendarDatePicker.maxDate = endDate
            case .datePicker(let datePicker):
                datePicker.minYear = startDate
                datePicker.maxYear = endDate
        }
    }

    func updateIfNeeded(date: Date, calendar: Calendar) {
        if !needsUpdate && date == self.date && calendar == self.calendar { return }
        defer { needsUpdate = false }

        self.date = date
        self.calendar = calendar

        let (dateTime, timeSpan) = foundationDateToComponents(date)

        switch dateView {
            case .calendarView(let calendarView):
                calendarView.calendarIdentifier = identifier(for: calendar)
                switch calendarView.selectedDates.size {
                    case 0:
                        calendarView.selectedDates.append(dateTime)
                    case 1:
                        calendarView.selectedDates.setAt(0, dateTime)
                    default:
                        calendarView.selectedDates.clear()
                        calendarView.selectedDates.setAt(0, dateTime)
                }
            case .calendarDatePicker(let calendarDatePicker):
                calendarDatePicker.calendarIdentifier = identifier(for: calendar)
                calendarDatePicker.date = dateTime
            case .datePicker(let datePicker):
                datePicker.selectedDate = dateTime
            case nil:
                break
        }

        if let timeView {
            timeView.selectedTime = timeSpan
        }
    }

    private func identifier(for calendar: Calendar) -> String {
        switch calendar.identifier {
            case .chinese: return "ChineseLunarCalendar"
            case .gregorian, .iso8601: return "GregorianCalendar"
            case .hebrew: return "HebrewCalendar"
            case .islamicTabular: return "HijriCalendar"
            case .islamicUmmAlQura: return "UmAlQuraCalendar"
            case .japanese: return "JapaneseCalendar"
            case .persian: return "PersianCalendar"
            case .republicOfChina: return "TaiwanCalendar"
            #if compiler(>=6.2)
                case .vietnamese: return "VietnameseLunarCalendar"
            #endif
            case let id:
                print("Unsupported calendar identifier '\(id)'. Falling back to Gregorian.")
                return "GregorianCalendar"
        }
    }

    // Magic numbers taken from https://stackoverflow.com/a/5471380/6253337
    private let ticksPerSecond: Double = 10_000_000
    private let unixEpochInUniversalTime: Int64 = 116_444_736_000_000_000

    private func foundationDateToComponents(_ date: Date) -> (DateTime, TimeSpan) {
        let timeInterval = date.timeIntervalSince(calendar.startOfDay(for: date))

        return (
            DateTime(
                universalTime: Int64(
                    date.timeIntervalSince1970 * ticksPerSecond + Double(unixEpochInUniversalTime)
                )
            ),
            TimeSpan(duration: Int64(timeInterval * ticksPerSecond))
        )
    }

    private func componentsToFoundationDate(dateTime: DateTime, timeSpan: TimeSpan?) -> Date {
        let baseDate = Date(
            timeIntervalSince1970: Double(dateTime.universalTime - unixEpochInUniversalTime)
                / ticksPerSecond
        )

        if let timeSpan {
            let time = Double(timeSpan.duration) / ticksPerSecond
            return calendar.startOfDay(for: baseDate) + time
        } else {
            return baseDate
        }
    }

    func naturalSize() -> SIMD2<Int> {
        let timeViewSize =
            if timeView != nil {
                // Width is 242, as shown in the WinUI repository:
                // https://github.com/marcelwgn/microsoft-ui-xaml/blob/ff21f9b212cea2191b959649e45e52486c8465aa/src/controls/dev/CommonStyles/TimePicker_themeresources.xaml#L116
                // Height is experimentally 29 which I don't see anywhere in that file.
                SIMD2(242, 29)
            } else {
                SIMD2<Int>.zero
            }

        let dateViewSize =
            if let dateControl = dateView?.asControl {
                WinUIBackend.naturalSize(of: dateControl)
            } else {
                SIMD2<Int>.zero
            }

        if orientation == .horizontal {
            return SIMD2(
                x: timeViewSize.x + dateViewSize.x + Int(self.spacing),
                y: max(timeViewSize.y, dateViewSize.y)
            )
        } else {
            return SIMD2(
                x: max(timeViewSize.x, dateViewSize.x),
                y: timeViewSize.y + dateViewSize.y + Int(self.spacing)
            )
        }
    }
}
