import Foundation

public struct DatePickerComponents: OptionSet, Sendable {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    public init() {
        self.rawValue = 0
    }

    // These magic numbers are the same as SwiftUI. It's actually a bitfield:
    //
    //                        smhdMy--
    //                   date 00011100
    //          hourAndMinute 01100000
    //    hourMinuteAndSecond 11100000
    //
    // Like SwiftUI, not all combinations are valid (SwiftUI fatalErrors if you try to get creative
    // with your choice of flags), and hourMinuteAndSecond intentionally includes hourAndMinute.

    public static let date = DatePickerComponents(rawValue: 0x1C)
    public static let hourAndMinute = DatePickerComponents(rawValue: 0x60)

    @available(iOS, unavailable)
    @available(visionOS, unavailable)
    @available(macCatalyst, unavailable)
    public static let hourMinuteAndSecond = DatePickerComponents(rawValue: 0xE0)
}

public enum DatePickerStyle: Sendable, Hashable {
    /// A date input that adapts to the current platform and context.
    case automatic

    /// A date input that shows a calendar grid.
    @available(iOS 14, macCatalyst 14, *)
    case graphical

    /// A smaller date input. This may be a text field, or a button that opens a calendar pop-up.
    @available(iOS 13.4, macCatalyst 13.4, *)
    case compact

    /// A set of scrollable inputs that can be used to select a date.
    @available(iOS 13.4, macCatalyst 13.4, *)
    @available(macOS, unavailable)
    case wheel
}

@available(tvOS, unavailable)
public struct DatePicker<Label: View> {
    private var label: Label
    private var selection: Binding<Date>
    private var range: ClosedRange<Date>
    private var components: DatePickerComponents
    private var style: DatePickerStyle = .automatic

    /// Displays a date input.
    /// - Parameters:
    ///   - selection: The currently-selected date.
    ///   - range: The range of dates to display. The backend takes this as a hint but it is not
    ///     necessarily enforced. As such this parameter should be treated as an aid to validation
    ///     rather than a replacement for it.
    ///   - displayedComponents: Which parts of the date/time to display in the input.
    ///   - label: The view to be shown next to the date input.
    public nonisolated init(
        selection: Binding<Date>,
        in range: ClosedRange<Date> = Date.distantPast...Date.distantFuture,
        displayedComponents: DatePickerComponents = [.hourAndMinute, .date],
        @ViewBuilder label: () -> Label
    ) {
        self.label = label()
        self.selection = selection
        self.range = range
        self.components = displayedComponents
    }

    /// Displays a date input.
    /// - Parameters:
    ///   - label: The text to be shown next to the date input.
    ///   - selection: The currently-selected date.
    ///   - range: The range of dates to display. The backend takes this as a hint but it is not
    ///     necessarily enforced. As such this parameter should be treated as an aid to validation
    ///     rather than a replacement for it.
    ///   - displayedComponents: Which parts of the date/time to display in the input.
    public nonisolated init(
        _ label: String,
        selection: Binding<Date>,
        in range: ClosedRange<Date> = Date.distantPast...Date.distantFuture,
        displayedComponents: DatePickerComponents = [.hourAndMinute, .date]
    ) where Label == Text {
        self.label = Text(label)
        self.selection = selection
        self.range = range
        self.components = displayedComponents
    }

    public typealias Components = DatePickerComponents
}

@available(tvOS, unavailable)
extension DatePicker: View {
    public var body: some View {
        HStack {
            label

            DatePickerImplementation(selection: selection, range: range, components: components)
        }
    }
}

@available(tvOS, unavailable)
internal struct DatePickerImplementation: ElementaryView {
    @Binding private var selection: Date
    private var range: ClosedRange<Date>
    private var components: DatePickerComponents

    init(selection: Binding<Date>, range: ClosedRange<Date>, components: DatePickerComponents) {
        self._selection = selection
        self.range = range
        self.components = components
    }

    let body = EmptyView()

    func asWidget<Backend: AppBackend>(backend: Backend) -> Backend.Widget {
        backend.createDatePicker()
    }

    func computeLayout<Backend: AppBackend>(
        _ widget: Backend.Widget,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        backend.updateDatePicker(
            widget,
            environment: environment,
            date: selection,
            range: range,
            components: components,
            onChange: { selection = $0 }
        )

        // I reject your proposedSize and substitute my own
        let naturalSize = backend.naturalSize(of: widget)
        return ViewLayoutResult.leafView(size: ViewSize(naturalSize))
    }

    func commit<Backend: AppBackend>(
        _ widget: Backend.Widget,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        backend.setSize(of: widget, to: layout.size.vector)
    }
}
