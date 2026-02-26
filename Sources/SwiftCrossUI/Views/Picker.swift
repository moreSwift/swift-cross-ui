/// A control for selecting from a set of values.
public struct Picker<Value: Equatable>: View {
    /// The options to be offered by the picker.
    private var options: [Value]
    /// The picker's selected option.
    private var value: Binding<Value?>

    @Environment(\.self) var environment

    /// Creates a new picker with the given options and a binding for the selected value.
    public init(of options: [Value], selection value: Binding<Value?>) {
        self.options = options
        self.value = value
    }

    public var body: some View {
        AnyView(
            environment.pickerStyle.makeView(
                options: options,
                selection: value,
                environment: environment
            )
        )
    }
}
