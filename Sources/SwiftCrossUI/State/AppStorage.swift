import Foundation
import Mutex

private let appStorageCache: Mutex<[String: any Codable & Sendable]> = Mutex([:])
private let appStoragePublisherCache: Mutex<[String: Publisher]> = Mutex([:])

/// Like ``State``, but persists its value to disk so that it survives betweeen
/// app launches.
@propertyWrapper
public struct AppStorage<Value: Codable & Sendable>: ObservableProperty {
    // TODO: Observe changes to persisted values made by external processes

    private final class Storage: StateStorageProtocol {
        let key: String
        let defaultValue: Value
        var downstreamObservation: Cancellable?
        var provider: (any AppStorageProvider)?

        init(key: String, defaultValue: Value) {
            self.key = key
            self.defaultValue = defaultValue
        }

        lazy var didChange: Publisher = {
            appStoragePublisherCache.withLock { cache in
                guard let publisher = cache[key] else {
                    let newPublisher = Publisher()
                    cache[key] = newPublisher
                    return newPublisher
                }
                return publisher
            }
        }()

        var value: Value {
            get {
                guard let provider else {
                    // NB: We used to call `fatalError` here, but since `StateImpl` accesses this
                    // property on initialization, we're returning the default value instead.
                    return defaultValue
                }

                return appStorageCache.withLock { cache in
                    // If this is the very first time we're reading from this key, it won't
                    // be in the cache yet. In that case, we return the already-persisted value
                    // if it exists, or the default value otherwise; either way, we add it to the
                    // cache so subsequent accesses of `value` won't have to read from disk again.
                    guard let cachedValue = cache[key] else {
                        let value =
                            provider.retrieveValue(ofType: Value.self, forKey: key) ?? defaultValue
                        cache[key] = value
                        return value
                    }

                    // Make sure that we have the right type.
                    guard let cachedValue = cachedValue as? Value else {
                        logger.warning(
                            "'@AppStorage' property is of the wrong type; using default value",
                            metadata: [
                                "key": "\(key)",
                                "providedType": "\(Value.self)",
                                "actualType": "\(type(of: cachedValue))",
                            ]
                        )
                        return defaultValue
                    }

                    return cachedValue
                }
            }

            set {
                guard let provider else {
                    fatalError(
                        """
                        @AppStorage value with key '\(key)' used before initialization. \
                        Don't use @AppStorage properties before SwiftCrossUI requests the \
                        body of the enclosing 'App' or 'View'.
                        """
                    )
                }

                appStorageCache.withLock { cache in
                    cache[key] = newValue
                    do {
                        logger.trace("persisting '\(newValue)' for '\(key)'")
                        try provider.persistValue(newValue, forKey: key)
                    } catch {
                        logger.warning(
                            "failed to encode '@AppStorage' data",
                            metadata: [
                                "value": "\(newValue)",
                                "error": "\(error.localizedDescription)",
                            ]
                        )
                    }
                }
            }
        }
    }

    private let implementation: StateImpl<Storage>
    private var storage: Storage { implementation.storage }

    /// The default value, used when no value has been persisted yet.
    let defaultValue: Value

    /// The key used to access the persisted value.
    let key: String

    public var didChange: Publisher { storage.didChange }

    public var wrappedValue: Value {
        get { implementation.wrappedValue }
        nonmutating set { implementation.wrappedValue = newValue }
    }

    public var projectedValue: Binding<Value> { implementation.projectedValue }

    public init(wrappedValue defaultValue: Value, _ key: String) {
        self.key = key
        self.defaultValue = defaultValue
        implementation = StateImpl(initialStorage: Storage(key: key, defaultValue: defaultValue))
    }

    public init(_ key: String) where Value: ExpressibleByNilLiteral {
        self.init(wrappedValue: nil, key)
    }

    public func update(with environment: EnvironmentValues, previousValue: AppStorage<Value>?) {
        implementation.update(with: environment, previousValue: previousValue?.implementation)
        storage.provider = environment.appStorageProvider
    }
}

extension AppStorage {
    @available(
        *, deprecated,
        message: "'AppStorage' does not work correctly with classes; use a struct instead"
    )
    public init(wrappedValue defaultValue: Value, _ key: String) where Value: AnyObject {
        self.key = key
        self.defaultValue = defaultValue
        implementation = StateImpl(initialStorage: Storage(key: key, defaultValue: defaultValue))
    }

    @available(
        *, deprecated,
        message: """
            'AppStorage' currently does not persist 'ObservableObject' types \
            to disk when published properties update
            """
    )
    public init(wrappedValue defaultValue: Value, _ key: String) where Value: ObservableObject {
        self.key = key
        self.defaultValue = defaultValue
        implementation = StateImpl(initialStorage: Storage(key: key, defaultValue: defaultValue))
    }
}

// MARK: - AppStorageKey

extension AppStorage {
    public init<Key: AppStorageKey<Value>>(_: Key.Type) {
        self.init(wrappedValue: Key.defaultValue, Key.name)
    }
}

/// A type safe key for ``AppStorage`` properties, similar in spirit
/// to ``EnvironmentKey``.
public protocol AppStorageKey<Value> {
    associatedtype Value: Codable

    /// The name to use when persisting the key.
    static var name: String { get }
    /// The default value for the key.
    static var defaultValue: Value { get }
}
