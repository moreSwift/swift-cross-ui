/// A property wrapper used to access environment values within a ``View`` or
/// ``App``.
///
/// Must not be used before the view graph accesses the view or app's `body`
/// (so, don't access it from an initializer).
///
/// ```swift
/// struct ContentView: View {
///     @Environment(\.colorScheme) var colorScheme
///
///     var body: some View {
///         Text("Current color scheme: \(colorScheme)")
///             .background(colorScheme == .light ? Color.black : Color.white)
///     }
/// }
/// ```
///
/// The environment also contains UI-related actions, such as the
/// ``EnvironmentValues/chooseFile`` action used to present 'Open file' dialogs.
///
/// ```swift
/// struct ContentView: View {
///     @Environment(\.chooseFile) var chooseFile
///
///     var body: some View {
///         Button("Open") {
///             Task {
///                 guard let file = await chooseFile() else {
///                     print("No file chosen")
///                     return
///                 }
///
///                 print("The user chose: \(file.path)")
///             }
///         }
///     }
/// }
/// ```
@propertyWrapper
public struct Environment<Value>: DynamicProperty {
    private var mode: Mode
    /// The underlying value.
    ///
    /// `nil` if ``update(with:previousValue:)`` has not yet been called.
    private var value: Box<Value?>

    public func update(
        with environment: EnvironmentValues,
        previousValue: Self?
    ) {
        switch mode {
            case .keyPath(let keyPath):
                value.value = environment[keyPath: keyPath]
            case .observableObject:
                if let type = Value.self as? any ObservableObject.Type {
                    value.value = (environment[observable: type] as! Value)
                }
        }
    }

    /// The environment value that this property refers to.
    public var wrappedValue: Value {
        guard let value = value.value else {
            fatalError(
                """
                Environment value at \(mode.pathDescription) used before initialization. Don't \
                use @Environment properties before SwiftCrossUI requests the \
                view's body.
                """
            )
        }
        return value
    }

    /// Initializes an ``Environment`` property wrapper.
    ///
    /// - Parameter keyPath: A key path to the enviornment value to access.
    public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
        self.value = Box(nil)
        self.mode = .keyPath(keyPath)
    }

    public init(_ type: Value.Type) where Value: ObservableObject {
        self.value = Box(nil)
        self.mode = .observableObject
    }

    private enum Mode {
        /// A key path to the enviornment value to access.
        case keyPath(KeyPath<EnvironmentValues, Value>)
        /// An observable object.
        case observableObject

        var pathDescription: String {
            switch self {
                case .keyPath(let keyPath):
                    "\(keyPath)"
                case .observableObject:
                    "\(Value.self).self"
            }
        }
    }
}
