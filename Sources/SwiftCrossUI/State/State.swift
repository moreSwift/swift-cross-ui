import Foundation
import ObservationPolyfillCore

// TODO: Document State properly, this is an important type.
// - It supports value types
// - It supports ObservableObject
// - It supports Optional<ObservableObject>

/// A property wrapper that acts as a source of truth for view state.
@propertyWrapper
public struct State<Value>: ObservableProperty {
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

    /// Accesses the underlying value of this `State`.
    public var wrappedValue: Value {
        get { implementation.wrappedValue }
        nonmutating set { implementation.wrappedValue = newValue }
    }

    /// Returns a ``Binding`` to this state.
    public var projectedValue: Binding<Value> { implementation.projectedValue }

    /// Creates a `State` given an initial value.
    ///
    /// - Parameter initialValue: The state's initial value.
    public init(wrappedValue initialValue: Value) {
        implementation = StateImpl(initialStorage: Storage(initialValue))
    }

    public func update(with environment: EnvironmentValues, previousValue: State<Value>?) {
        implementation.update(with: environment, previousValue: previousValue?.implementation)
    }
}

extension State {
    // NB: `ExpressibleByNilLiteral` is what SwiftUI checks for too.
    public init() where Value: ExpressibleByNilLiteral {
        self.init(wrappedValue: nil)
    }

    @available(
        *,
        deprecated,
        message: """
            'State' does not work correctly with non-observable classes; conform \
            your class to 'ObservableObject', use `@Observable` or use a struct instead
            """
    )
    public init(wrappedValue initialValue: Value) where Value: AnyObject {
        implementation = StateImpl(initialStorage: Storage(initialValue))
    }

    // NB: Needed to prevent deprecation warnings for `ObservableObject` types, which
    // *are* fully supported by `State`
    public init(wrappedValue initialValue: Value) where Value: ObservableObject {
        implementation = StateImpl(initialStorage: Storage(initialValue))
    }
    
    // NB: Needed to prevent deprecation warnings for `Observable` types, which
    // *are* supported
    @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
    public init(wrappedValue initialValue: Value) where Value: Observation.Observable & AnyObject {
        implementation = StateImpl(initialStorage: Storage(initialValue))
    }
    
    #if canImport(Darwin)
        // NB: Needed to prevent deprecation warnings for `Perceptible` types, which
        // *are* supported
        // Causes a compilation error on Windows and Linux where Perceptible just
        // uses Observable under the hood.
        public init(wrappedValue initialValue: Value) where Value: ObservationPolyfillCore.Observable & AnyObject {
            implementation = StateImpl(initialStorage: Storage(initialValue))
        }
    #endif
}

extension State: SnapshottableProperty {
    public func tryRestoreFromSnapshot(_ snapshot: Data) {
        guard
            let decodable = Value.self as? Codable.Type,
            let state = try? JSONDecoder().decode(decodable, from: snapshot)
        else {
            return
        }

        storage.value = state as! Value
    }

    public func snapshot() throws -> Data? {
        if let value = storage.value as? Codable {
            try JSONEncoder().encode(value)
        } else {
            nil
        }
    }
}
