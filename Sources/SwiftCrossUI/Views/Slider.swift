/// A control for selecting a value from a bounded range of numerical values.
public struct Slider: ElementaryView, View {
    /// The ideal width of a Slider.
    private static let idealWidth: Double = 100

    /// A binding to the current value.
    private var value: Binding<Double>?
    /// The slider's range of values.
    private var range: ClosedRange<Double>
    /// The number of decimal places used when displaying the value.
    private var decimalPlaces: Int

    @available(*, deprecated, renamed: "init(value:in:)")
    public init<T: BinaryInteger>(_ value: Binding<T>? = nil, minimum: T, maximum: T) {
        self.init(value: value, in: minimum...maximum)
    }

    @available(*, deprecated, renamed: "init(value:in:)")
    public init<T: BinaryFloatingPoint>(_ value: Binding<T>? = nil, minimum: T, maximum: T) {
        self.init(value: value, in: minimum...maximum)
    }

    /// Creates a slider to select a value between a minimum and maximum value.
    public init<T: BinaryInteger>(value: Binding<T>? = nil, in range: ClosedRange<T>) {
        if let value {
            self.value = Binding<Double>(
                get: {
                    return Double(value.wrappedValue)
                },
                set: { newValue in
                    value.wrappedValue = T(newValue.rounded())
                }
            )
        }
        self.range = Double(range.lowerBound)...Double(range.upperBound)
        decimalPlaces = 0
    }

    /// Creates a slider to select a value between a minimum and maximum value.
    public init<T: BinaryFloatingPoint>(value: Binding<T>? = nil, in range: ClosedRange<T>) {
        if let value {
            self.value = Binding<Double>(
                get: {
                    return Double(value.wrappedValue)
                },
                set: { newValue in
                    value.wrappedValue = T(newValue)
                }
            )
        }
        self.range = Double(range.lowerBound)...Double(range.upperBound)
        decimalPlaces = 2
    }

    func asWidget<Backend: AppBackend>(backend: Backend) -> Backend.Widget {
        return backend.createSlider()
    }

    func computeLayout<Backend: AppBackend>(
        _ widget: Backend.Widget,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        // TODO: Don't rely on naturalSize for minimum size so that we can get
        //   Slider sizes without relying on the widget.
        let naturalSize = backend.naturalSize(of: widget)

        let size = ViewSize(
            max(Double(naturalSize.x), proposedSize.width ?? Self.idealWidth),
            Double(naturalSize.y)
        )

        // TODO: Allow backends to specify their own ideal slider widths.
        return ViewLayoutResult.leafView(size: size)
    }

    func commit<Backend: AppBackend>(
        _ widget: Backend.Widget,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        backend.updateSlider(
            widget,
            minimum: range.lowerBound,
            maximum: range.upperBound,
            decimalPlaces: decimalPlaces,
            environment: environment
        ) { newValue in
            if let value, value.wrappedValue != newValue {
                value.wrappedValue = newValue
            }
        }

        if let value = value?.wrappedValue {
            backend.setValue(ofSlider: widget, to: value)
        }

        backend.setSize(of: widget, to: layout.size.vector)
    }
}
