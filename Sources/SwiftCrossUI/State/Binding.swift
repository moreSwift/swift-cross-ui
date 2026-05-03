/// A value that can read and write a value owned by a source of truth.
///
/// You can create a binding in several different ways:
/// - by accessing the ``projectedValue`` (via leading `$` syntax) on a piece of
///   ``State`` or another `Binding`:
///   ```swift
///   @State var name = "John Appleseed"
///   TextField("Name", text: $name)
///   ```
/// - by _projecting_ a property of an existing binding with dynamic member
///   lookup (``subscript(dynamicMember:)``):
///   ```swift
///   @Binding var account: Account
///   TextField("Email", text: $account.email)
///   Toggle("Notifications", isOn: $account.notificationsEnabled)
///   ```
/// - by calling ``init(get:set:)`` with a custom getter and setter:
///   ```swift
///   let binding = Binding(
///       get: { endpoint.getData() },
///       set: { endpoint.setData(to: $0) }
///   )
///   ```
///
/// That last one reveals something important about bindings: while they can be
/// thought of as writable references to their sources of truth, in reality
/// they're nothing more than getter-setter pairs. A binding can have any
/// arbitrary getter and setter, and the two functions don't even have to be
/// related. However, SwiftCrossUI's reactivity relies on a binding's getter
/// and setter acting in a consistent manner; see  ``init(get:set:)`` for more
/// info.
@dynamicMemberLookup
@propertyWrapper
public struct Binding<Value> {
    /// The binding's wrapped value.
    public var wrappedValue: Value {
        get {
            getValue()
        }
        nonmutating set {
            setValue(newValue)
        }
    }

    /// The binding itself.
    ///
    /// This is a handy helper so that you can use ``Binding`` properties like
    /// you would with ``State`` properties.
    public var projectedValue: Binding<Value> {
        self
    }

    /// The stored getter.
    private let getValue: () -> Value
    /// The stored setter.
    private let setValue: (Value) -> Void

    /// Creates a binding with a custom getter and setter.
    ///
    /// To create a binding from a ``State`` property, use its projected value
    /// instead: e.g. `$myStateProperty` will give you a binding for reading and
    /// writing `myStateProperty`.
    ///
    /// - Important: SwiftCrossUI's reactivity relies on a binding's getter and
    ///   setter consistently reading and updating the same source of truth ---
    ///   calling `get` immediately after calling `set` should always return the
    ///   same value (barring data races). Views will not update as you expect
    ///   if you break this assumption.
    ///
    /// - Parameters:
    ///   - get: The binding's getter.
    ///   - set: The binding's setter.
    public init(get: @escaping () -> Value, set: @escaping (Value) -> Void) {
        self.getValue = get
        self.setValue = set
    }

    /// Converts a `Binding<Value?>` into a `Binding<Value>?`, returning `nil`
    /// if the `wrappedValue` of `other` is `nil`.
    ///
    /// - Parameter other: A binding with an optional value.
    /// - Returns: An optional binding with a non-optional value.
    public init?(_ other: Binding<Value?>) {
        if let initialValue = other.wrappedValue {
            self.init(
                get: {
                    other.wrappedValue ?? initialValue
                },
                set: { newValue in
                    other.wrappedValue = newValue
                }
            )
        } else {
            return nil
        }
    }

    /// Projects a property of a binding.
    ///
    /// - Parameter keyPath: A key path from this binding's value type.
    /// - Returns: A binding to the property referenced by `keyPath`.
    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, T>) -> Binding<T> {
        get {
            Binding<T>(
                get: {
                    self.wrappedValue[keyPath: keyPath]
                },
                set: { newValue in
                    self.wrappedValue[keyPath: keyPath] = newValue
                }
            )
        }
    }

    /// Returns a new binding that will perform an action whenever it is used to set
    /// the source of truth's value.
    ///
    /// - Parameter action: The action to perform.
    /// - Returns: A binding that calls `action` with the new value after
    ///   setting it.
    public func onChange(_ action: @escaping (Value) -> Void) -> Binding<Value> {
        return Binding<Value>(
            get: getValue,
            set: { newValue in
                self.setValue(newValue)
                action(newValue)
            }
        )
    }
}
