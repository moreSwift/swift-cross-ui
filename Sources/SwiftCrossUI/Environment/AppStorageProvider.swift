import Foundation

/// The default app storage provider for apps which don't specify a
/// custom one.
///
/// This uses `UserDefaults` on all platforms.
public typealias DefaultAppStorageProvider = UserDefaultsAppStorageProvider

/// A type that can be used to persist ``AppStorage`` values to disk.
public protocol AppStorageProvider: Sendable {
    /// Persists the given value.
    ///
    /// - Parameters:
    ///   - value: The value to persist.
    ///   - key: The key to assign the value to.
    func persistValue<Value: Codable>(_ value: Value, forKey key: String) throws
    /// Retrieves the value for the given key.
    ///
    /// - Parameters:
    ///   - type: The type that you expect the value to be.
    ///   - key: The key to retrieve the value from.
    /// - Returns: The persisted value for `key`, if it exists and is of the
    ///   expected type; otherwise, `nil`.
    func retrieveValue<Value: Codable>(ofType type: Value.Type, forKey key: String) -> Value?
    /// Listens for changes to app storage.
    ///
    /// This should call `action` when any of the app's persisted values changes.
    /// This is called early in app startup.
    ///
    /// - Parameters:
    ///   - action: The action to perform when a persisted value changes, taking
    ///     the key that changed as a parameter.
    func listenToChanges(_ action: @MainActor @Sendable @escaping (String) -> Void)
}

extension AppStorageProvider {
    public func getValue<T: Codable & Sendable>(key: String, defaultValue: T) -> T {
        return appStorageCache.withLock { cache in
            // If this is the very first time we're reading from this key (or if a change was
            // detected and the provider invalidated the cache), it won't be in the cache yet.
            // In that case, we return the already-persisted value if it exists, or the default
            // value otherwise; either way, we add it to the cache so subsequent accesses of
            // `value` won't have to read from disk again.
            guard let cachedValue = cache[key] else {
                let value =
                    self.retrieveValue(ofType: T.self, forKey: key) ?? defaultValue
                cache[key] = value
                return value
            }

            // Make sure that we have the right type.
            guard let cachedValue = cachedValue as? T else {
                logger.warning(
                    "'@AppStorage' property is of the wrong type; using default value",
                    metadata: [
                        "key": "\(key)",
                        "providedType": "\(T.self)",
                        "actualType": "\(type(of: cachedValue))",
                    ]
                )
                return defaultValue
            }

            return cachedValue
        }
    }

    public func setValue<T: Codable & Sendable>(key: String, newValue: T) {
        appStorageCache.withLock { cache in
            cache[key] = newValue
            do {
                logger.trace("persisting '\(newValue)' for '\(key)'")
                try self.persistValue(newValue, forKey: key)
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
