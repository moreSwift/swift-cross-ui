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
}

/// A simple app storage provider that uses `UserDefaults` to persist
/// data.
///
/// This works on all supported platforms.
public struct UserDefaultsAppStorageProvider: AppStorageProvider {
    public func persistValue<Value: Codable>(_ value: Value, forKey key: String) throws {
        let jsonData = try JSONEncoder().encode(value)
        let jsonString = String.init(data: jsonData, encoding: .utf8)
        UserDefaults.standard.set(jsonString, forKey: key)

        // NB: The UserDefaults store isn't automatically synced to disk on
        // Linux and Windows.
        // https://github.com/swiftlang/swift-corelibs-foundation/issues/4837
        #if os(Linux) || os(Windows)
            UserDefaults.standard.synchronize()
        #endif
    }

    public func retrieveValue<Value: Codable>(ofType: Value.Type, forKey key: String) -> Value? {
        guard let string = UserDefaults.standard.string(forKey: key),
            let data = string.data(using: .utf8),
            let value = try? JSONDecoder().decode(Value.self, from: data)
        else {
            return nil
        }
        return value
    }
}

extension AppStorageProvider {
    public func getValue<T: Codable & Sendable>(key: String, defaultValue: T) -> T {
        return appStorageCache.withLock { cache in
            // If this is the very first time we're reading from this key, it won't
            // be in the cache yet. In that case, we return the already-persisted value
            // if it exists, or the default value otherwise; either way, we add it to the
            // cache so subsequent accesses of `value` won't have to read from disk again.
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
