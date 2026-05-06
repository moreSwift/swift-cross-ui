/// A container for typed application-defined app storage values
public struct AppStorageValues {
    private let provider: AppStorageProvider?

    /// Only to be used by AppStorage
    internal init(provider: AppStorageProvider?) {
        self.provider = provider
    }

    public func getValue<Key: AppStorageKey>(_ key: Key.Type) -> Key.Value {
        guard let provider else { return key.defaultValue }
        return provider.getValue(key: key.name, defaultValue: key.defaultValue)
    }

    public func setValue<Key: AppStorageKey>(_ key: Key.Type, newValue: Key.Value) {
        provider?.setValue(key: key.name, newValue: newValue)
    }
}
