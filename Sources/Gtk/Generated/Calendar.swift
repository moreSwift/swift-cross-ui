import CGtk

/// Displays a Gregorian calendar, one month at a time.
///
/// <picture><source srcset="calendar-dark.png" media="(prefers-color-scheme: dark)"><img alt="An example GtkCalendar" src="calendar.png"></picture>
///
/// A `GtkCalendar` can be created with [ctor@Gtk.Calendar.new].
///
/// The date that is currently displayed can be altered with
/// [method@Gtk.Calendar.select_day].
///
/// To place a visual marker on a particular day, use
/// [method@Gtk.Calendar.mark_day] and to remove the marker,
/// [method@Gtk.Calendar.unmark_day]. Alternative, all
/// marks can be cleared with [method@Gtk.Calendar.clear_marks].
///
/// The selected date can be retrieved from a `GtkCalendar` using
/// [method@Gtk.Calendar.get_date].
///
/// Users should be aware that, although the Gregorian calendar is the
/// legal calendar in most countries, it was adopted progressively
/// between 1582 and 1929. Display before these dates is likely to be
/// historically incorrect.
///
/// # Shortcuts and Gestures
///
/// `GtkCalendar` supports the following gestures:
///
/// - Scrolling up or down will switch to the previous or next month.
/// - Date strings can be dropped for setting the current day.
///
/// # CSS nodes
///
/// ```
/// calendar.view
/// ├── header
/// │   ├── button
/// │   ├── stack.month
/// │   ├── button
/// │   ├── button
/// │   ├── label.year
/// │   ╰── button
/// ╰── grid
/// ╰── label[.day-name][.week-number][.day-number][.other-month][.today]
/// ```
///
/// `GtkCalendar` has a main node with name calendar. It contains a subnode
/// called header containing the widgets for switching between years and months.
///
/// The grid subnode contains all day labels, including week numbers on the left
/// (marked with the .week-number css class) and day names on top (marked with the
/// .day-name css class).
///
/// Day labels that belong to the previous or next month get the .other-month
/// style class. The label of the current day get the .today style class.
///
/// Marked day labels get the :selected state assigned.
open class Calendar: Widget {
    /// Creates a new calendar, with the current date being selected.
    public convenience init() {
        self.init(
            gtk_calendar_new()
        )
    }

    open override func didMoveToParent() {
        super.didMoveToParent()

        addSignal(name: "day-selected") { [weak self] () in
            guard let self else { return }
            self.daySelected?(self)
        }

        addSignal(name: "next-month") { [weak self] () in
            guard let self else { return }
            self.nextMonth?(self)
        }

        addSignal(name: "next-year") { [weak self] () in
            guard let self else { return }
            self.nextYear?(self)
        }

        addSignal(name: "prev-month") { [weak self] () in
            guard let self else { return }
            self.prevMonth?(self)
        }

        addSignal(name: "prev-year") { [weak self] () in
            guard let self else { return }
            self.prevYear?(self)
        }

        let handler5:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::day", handler: gCallback(handler5)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyDay?(self, param0)
        }

        let handler6:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::month", handler: gCallback(handler6)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyMonth?(self, param0)
        }

        let handler7:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::show-day-names", handler: gCallback(handler7)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyShowDayNames?(self, param0)
        }

        let handler8:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::show-heading", handler: gCallback(handler8)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyShowHeading?(self, param0)
        }

        let handler9:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::show-week-numbers", handler: gCallback(handler9)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyShowWeekNumbers?(self, param0)
        }

        let handler10:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::year", handler: gCallback(handler10)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyYear?(self, param0)
        }
    }

    /// The selected day (as a number between 1 and 31).
    @GObjectProperty(named: "day") public var day: Int

    /// The selected month (as a number between 0 and 11).
    ///
    /// This property gets initially set to the current month.
    @GObjectProperty(named: "month") public var month: Int

    /// Determines whether day names are displayed.
    @GObjectProperty(named: "show-day-names") public var showDayNames: Bool

    /// Determines whether a heading is displayed.
    @GObjectProperty(named: "show-heading") public var showHeading: Bool

    /// Determines whether week numbers are displayed.
    @GObjectProperty(named: "show-week-numbers") public var showWeekNumbers: Bool

    /// The selected year.
    ///
    /// This property gets initially set to the current year.
    @GObjectProperty(named: "year") public var year: Int

    /// Emitted when the user selects a day.
    public var daySelected: ((Calendar) -> Void)?

    /// Emitted when the user switched to the next month.
    public var nextMonth: ((Calendar) -> Void)?

    /// Emitted when user switched to the next year.
    public var nextYear: ((Calendar) -> Void)?

    /// Emitted when the user switched to the previous month.
    public var prevMonth: ((Calendar) -> Void)?

    /// Emitted when user switched to the previous year.
    public var prevYear: ((Calendar) -> Void)?

    public var notifyDay: ((Calendar, OpaquePointer) -> Void)?

    public var notifyMonth: ((Calendar, OpaquePointer) -> Void)?

    public var notifyShowDayNames: ((Calendar, OpaquePointer) -> Void)?

    public var notifyShowHeading: ((Calendar, OpaquePointer) -> Void)?

    public var notifyShowWeekNumbers: ((Calendar, OpaquePointer) -> Void)?

    public var notifyYear: ((Calendar, OpaquePointer) -> Void)?
}
