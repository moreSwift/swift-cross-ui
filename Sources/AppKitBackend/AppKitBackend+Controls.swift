import AppKit
import SwiftCrossUI

extension AppKitBackend {
    public var supportedPickerStyles: [BackendPickerStyle] {
        [.menu, .segmented, .radioGroup]
    }
    public var supportedDatePickerStyles: [DatePickerStyle] {
        [.automatic, .graphical, .compact]
    }

    public func createButton() -> Widget {
        return NSButton(title: "", target: nil, action: nil)
    }

    public func updateButton(
        _ button: Widget,
        label: String,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        let button = button as! NSButton
        button.attributedTitle = Self.attributedString(
            for: label,
            in: environment.with(\.multilineTextAlignment, .center)
        )
        button.bezelStyle = .regularSquare
        button.appearance = environment.colorScheme.nsAppearance
        button.isEnabled = environment.isEnabled
        button.onAction = { _ in
            action()
        }
    }

    public func createSwitch() -> Widget {
        return NSSwitch()
    }

    public func updateSwitch(
        _ toggleSwitch: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        let toggleSwitch = toggleSwitch as! NSSwitch
        toggleSwitch.isEnabled = environment.isEnabled
        toggleSwitch.onAction = { toggleSwitch in
            let toggleSwitch = toggleSwitch as! NSSwitch
            onChange(toggleSwitch.state == .on)
        }
    }

    public func setState(ofSwitch toggleSwitch: Widget, to state: Bool) {
        let toggleSwitch = toggleSwitch as! NSSwitch
        toggleSwitch.state = state ? .on : .off
    }

    public func createToggle() -> Widget {
        let toggle = NSButton()
        toggle.setButtonType(.pushOnPushOff)
        return toggle
    }

    public func updateToggle(
        _ toggle: Widget,
        label: String,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        let toggle = toggle as! NSButton
        toggle.attributedTitle = Self.attributedString(
            for: label,
            in: environment.with(\.multilineTextAlignment, .center)
        )
        toggle.isEnabled = environment.isEnabled
        toggle.onAction = { toggle in
            let toggle = toggle as! NSButton
            onChange(toggle.state == .on)
        }
    }

    public func setState(ofToggle toggle: Widget, to state: Bool) {
        let toggle = toggle as! NSButton
        toggle.state = state ? .on : .off
    }

    public func createCheckbox() -> Widget {
        NSButton(checkboxWithTitle: "", target: nil, action: nil)
    }

    public func updateCheckbox(
        _ checkbox: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        let checkbox = checkbox as! NSButton
        checkbox.isEnabled = environment.isEnabled
        checkbox.onAction = { toggle in
            let checkbox = toggle as! NSButton
            onChange(checkbox.state == .on)
        }
    }

    public func setState(ofCheckbox checkbox: Widget, to state: Bool) {
        let toggle = checkbox as! NSButton
        toggle.state = state ? .on : .off
    }

    public func createSlider() -> Widget {
        return NSSlider()
    }

    public func updateSlider(
        _ slider: Widget,
        minimum: Double,
        maximum: Double,
        decimalPlaces: Int,
        environment: EnvironmentValues,
        onChange: @escaping (Double) -> Void
    ) {
        // TODO: Implement decimalPlaces
        let slider = slider as! NSSlider
        slider.minValue = minimum
        slider.maxValue = maximum
        slider.onAction = { slider in
            let slider = slider as! NSSlider
            onChange(slider.doubleValue)
        }
        slider.isEnabled = environment.isEnabled
    }

    public func setValue(ofSlider slider: Widget, to value: Double) {
        let slider = slider as! NSSlider
        slider.doubleValue = value
    }

    public func createPicker(style: BackendPickerStyle) -> Widget {
        switch style {
            case .menu:
                return NSPopUpButton()
            case .segmented:
                return NSSegmentedControl()
            case .radioGroup:
                return RadioGroup()
            default:
                let message = "unsupported picker style \(style)"
                logger.critical("\(message)")
                fatalError(message)
        }
    }

    public func updatePicker(
        _ picker: Widget,
        options: [String],
        environment: EnvironmentValues,
        onChange: @escaping (Int?) -> Void
    ) {
        if let picker = picker as? NSPopUpButton {
            picker.isEnabled = environment.isEnabled

            let menu = picker.menu!

            for (item, option) in zip(menu.items, options) {
                item.attributedTitle = Self.attributedString(for: option, in: environment)
            }

            if menu.numberOfItems < options.count {
                for i in menu.numberOfItems..<options.count {
                    let item = NSMenuItem()
                    item.attributedTitle = Self.attributedString(for: options[i], in: environment)
                    menu.addItem(item)
                }
            } else {
                for i in (options.count..<menu.numberOfItems).reversed() {
                    menu.removeItem(at: i)
                }
            }

            picker.onAction = { picker in
                let picker = picker as! NSPopUpButton
                onChange(picker.indexOfSelectedItem)
            }
            picker.bezelStyle = .regularSquare
        } else if let picker = picker as? NSSegmentedControl {
            picker.isEnabled = environment.isEnabled
            picker.segmentCount = options.count
            for (i, option) in options.enumerated() {
                picker.setLabel(option, forSegment: i)
            }
            picker.onAction = { picker in
                let picker = picker as! NSSegmentedControl
                let selectedIndex = picker.selectedSegment
                onChange(selectedIndex == -1 ? nil : selectedIndex)
            }
        } else if let picker = picker as? RadioGroup {
            picker.update(options: options, environment: environment)
            picker.onChange = onChange
        }
    }

    public func setSelectedOption(ofPicker picker: Widget, to selectedOption: Int?) {
        if let picker = picker as? NSPopUpButton {
            if let index = selectedOption {
                picker.selectItem(at: index)
            } else {
                picker.select(nil)
            }
        } else if let picker = picker as? NSSegmentedControl {
            picker.selectedSegment = selectedOption ?? -1
        } else if let picker = picker as? RadioGroup {
            picker.setSelectedIndex(to: selectedOption)
        }
    }

    public func createProgressSpinner() -> Widget {
        let container = NSView()
        let spinner = NSProgressIndicator()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.isIndeterminate = true
        spinner.style = .spinning
        spinner.startAnimation(nil)
        container.addSubview(spinner)
        return container
    }

    public func setSize(
        ofProgressSpinner widget: Widget,
        to size: SIMD2<Int>
    ) {
        guard Int(widget.frame.size.height) != size.y else { return }
        setSize(of: widget, to: size)
        let spinner = NSProgressIndicator()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.isIndeterminate = true
        spinner.style = .spinning
        spinner.startAnimation(nil)
        spinner.widthAnchor.constraint(equalToConstant: CGFloat(size.x)).isActive = true
        spinner.heightAnchor.constraint(equalToConstant: CGFloat(size.y)).isActive = true

        widget.subviews = []
        widget.addSubview(spinner)
    }

    public func createProgressBar() -> Widget {
        let progressBar = NSProgressIndicator()
        progressBar.isIndeterminate = false
        progressBar.style = .bar
        progressBar.minValue = 0
        progressBar.maxValue = 1
        return progressBar
    }

    public func updateProgressBar(
        _ widget: Widget,
        progressFraction: Double?,
        environment: EnvironmentValues
    ) {
        let progressBar = widget as! NSProgressIndicator
        progressBar.doubleValue = progressFraction ?? 0
        progressBar.appearance = environment.colorScheme.nsAppearance

        if progressFraction == nil && !progressBar.isIndeterminate {
            // Start the indeterminate animation
            progressBar.isIndeterminate = true
            progressBar.startAnimation(nil)
        } else if progressFraction != nil && progressBar.isIndeterminate {
            // Stop the indeterminate animation
            progressBar.isIndeterminate = false
            progressBar.stopAnimation(nil)
        }
    }

    // MARK: Date Pickers

    public func createDatePicker() -> NSView {
        let datePicker = CustomDatePicker()
        datePicker.delegate = datePicker.strongDelegate
        return datePicker
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

// Source: https://gist.github.com/sindresorhus/3580ce9426fff8fafb1677341fca4815
extension NSControl {
    typealias ActionClosure = ((NSControl) -> Void)
    typealias EditClosure = ((NSTextField) -> Void)

    @MainActor
    struct AssociatedKeys {
        static let onActionClosure = ObjectAssociation<ActionClosure>()
        static let onEditClosure = ObjectAssociation<EditClosure>()
    }

    @objc
    func callClosure(_ sender: NSControl) {
        onAction?(sender)
    }

    var onAction: ActionClosure? {
        get {
            return AssociatedKeys.onActionClosure[self]
        }
        set {
            AssociatedKeys.onActionClosure[self] = newValue
            action = #selector(callClosure)
            target = self
        }
    }
}

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

final class RadioGroup: NSStackView {
    private var buttons: [NSButton]
    var onChange: ((Int?) -> Void)?

    override var intrinsicContentSize: NSSize {
        buttons.reduce(
            into: NSSize(width: 0.0, height: max(0.0, spacing * Double(buttons.count - 1)))
        ) { partialResult, button in
            let buttonIntrinsicSize = button.intrinsicContentSize
            partialResult.width = max(partialResult.width, buttonIntrinsicSize.width)
            partialResult.height += buttonIntrinsicSize.height
        }
    }

    init() {
        self.buttons = []
        super.init(frame: .zero)
        self.orientation = .vertical
        self.alignment = .leading
        self.setAccessibilityRole(.radioGroup)
    }

    required init?(coder: NSCoder) {
        fatalError("not used")
    }

    func update(options: [String], environment: EnvironmentValues) {
        for i in 0..<min(buttons.count, options.count) {
            buttons[i].attributedTitle = AppKitBackend.attributedString(
                for: options[i],
                in: environment
            )
            buttons[i].isEnabled = environment.isEnabled
        }

        if options.count > buttons.count {
            for i in buttons.count..<options.count {
                let button = NSButton()
                button.attributedTitle = AppKitBackend.attributedString(
                    for: options[i],
                    in: environment
                )
                button.isEnabled = environment.isEnabled
                button.target = self
                button.action = #selector(buttonClicked(sender:))
                button.tag = i
                button.setButtonType(.radio)
                addArrangedSubview(button)
                buttons.append(button)
            }
        } else {
            for i in (options.count..<buttons.count).reversed() {
                removeView(buttons[i])
                buttons.remove(at: i)
            }
        }
    }

    func setSelectedIndex(to index: Int?) {
        if let index {
            buttons[index].state = .on
        } else {
            buttons.forEach { $0.state = .off }
        }
    }

    @objc func buttonClicked(sender: NSButton) {
        onChange?(sender.tag)
    }
}
