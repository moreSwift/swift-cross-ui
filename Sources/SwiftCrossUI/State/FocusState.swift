import Foundation

/// A property wrapper type that can read and write a value that SwiftCrossUI updates
/// as the placement of focus within the scene changes.
@propertyWrapper
public struct FocusState<Value: Hashable>: ObservableProperty {
    private final class Storage: StateStorageProtocol {
        var value: Value
        var didChange = Publisher()
        var downstreamObservation: Cancellable?

        init(_ value: Value) {
            self.value = value
        }
    }

    private let implementation: StateImpl<Storage>

    private var storage: Storage { implementation.storage }

    public var didChange: Publisher { storage.didChange }

    public var wrappedValue: Value {
        get { implementation.wrappedValue }
        nonmutating set { implementation.wrappedValue = newValue }
    }

    public var projectedValue: FocusState.Binding {
        return FocusState.Binding(
            get: {
                implementation.projectedValue.wrappedValue
            },
            set: { newValue in
                implementation.projectedValue.wrappedValue = newValue
            },
            reset: {
                implementation.projectedValue.wrappedValue = emptyState
            }
        )
    }

    let emptyState: Value

    public init() where Value == Bool {
        emptyState = false
        implementation = StateImpl(initialStorage: Storage(false))
    }

    public init<T>() where Value == T?, T: Hashable {
        emptyState = nil
        implementation = StateImpl(initialStorage: Storage(nil))
    }

    public func update(with environment: EnvironmentValues, previousValue: FocusState<Value>?) {
        implementation.update(with: environment, previousValue: previousValue?.implementation)
    }

    /// A property wrapper type that can read and write a value that indicates the current focus location.
    @propertyWrapper
    public class Binding {
        public var wrappedValue: Value {
            get {
                getValue()
            }
            set {
                setValue(newValue)
            }
        }

        /// The stored getter.
        private let getValue: () -> Value
        /// The stored setter.
        private let setValue: (Value) -> Void
        /// The stored resetter.
        private let resetValue: () -> Void

        /// Creates a binding with a custom getter, setter and resetter. To create a binding from
        /// a `@FocusState` property use its projected value instead: e.g. `$myFocusStateProperty`
        /// will give you a binding for reading and writing `myFocusStateProperty` (assuming that
        /// `myFocusStateProperty` is marked with `@FocusState` at its declaration site).
        public init(
            get: @escaping () -> Value,
            set: @escaping (Value) -> Void,
            reset: @escaping () -> Void
        ) {
            self.getValue = get
            self.setValue = set
            self.resetValue = reset
        }

        func reset() {
            resetValue()
        }

        public var projectedValue: FocusState.Binding {
            return self
        }

        /// Returns a new binding that will perform an action whenever it is used to set
        /// the source of truth's value.
        public func onChange(_ action: @escaping (Value) -> Void) -> FocusState.Binding {
            return FocusState.Binding(
                get: getValue,
                set: { newValue in
                    self.setValue(newValue)
                    action(newValue)
                },
                reset: {
                    self.resetValue()
                    action(self.getValue())
                }
            )
        }
    }
}
