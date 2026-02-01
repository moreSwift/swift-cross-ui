import Foundation

// TODO: Document State properly, this is an important type.
// - It supports value types
// - It supports ObservableObject
// - It supports Optional<ObservableObject>
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

    public var wrappedValue: Value {
        get { implementation.wrappedValue }
        nonmutating set { implementation.wrappedValue = newValue }
    }

    public var projectedValue: Binding<Value> { implementation.projectedValue }

    public init(wrappedValue initialValue: Value) {
        implementation = StateImpl(initialStorage: Storage(initialValue))
    }

    public func update(with environment: EnvironmentValues, previousValue: State<Value>?) {
        implementation.update(with: environment, previousValue: previousValue?.implementation)
    }
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
