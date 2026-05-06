/// A type safe key for ``AppStorageValues`` properties, similar in spirit
/// to ``EnvironmentKey``.
/// Properties can be accessed using the ``AppStorage`` property wrapper.
public protocol AppStorageKey<Value> {
    associatedtype Value: Codable, Sendable

    /// The name to use when persisting the key.
    static var name: String { get }
    /// The default value for the key.
    static var defaultValue: Value { get }
}
