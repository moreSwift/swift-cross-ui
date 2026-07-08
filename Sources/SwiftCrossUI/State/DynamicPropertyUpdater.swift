/// A cache for dynamic property updaters.
///
/// The keys are the `ObjectIdentifier`s of various `Base` types that we have
/// already computed dynamic property updaters for, and the elements are
/// corresponding cached instances of `DynamicPropertyUpdater<Base>`.
///
/// From some basic testing, this caching seems to reduce layout times by 5-10%
/// (at the time of implementation).
@MainActor
private var updaterCache: [ObjectIdentifier: Any] = [:]

/// A helper for updating the dynamic properties of a stateful struct (e.g.
/// a struct conforming to ``View`` or ``App``).
///
/// At initialisation the updater will determine the byte offset of each
/// stateful property in the struct.
struct DynamicPropertyUpdater<Base> {
    /// The offsets and types of each of `Base`'s dynamic properties.
    private var propertyOffsets: [(offset: Int, type: any DynamicProperty.Type)]

    /// Creates a new dynamic property updater which can efficiently update
    /// all dynamic properties on any value of type `Base` without creating
    /// any mirrors.
    ///
    /// - Parameters:
    ///   - base: The base value to update the dynamic properties of.
    @MainActor
    init(for value: Base) {
        self.propertyOffsets = []

        // Unlikely shortcut, but worthwhile when we can.
        guard MemoryLayout<Base>.size > 0 else { return }

        if let cachedUpdater = updaterCache[ObjectIdentifier(Base.self)] {
            self = cachedUpdater as! Self
            return
        }

        forEachField(of: value) { _, offset, fieldValue in
            if let type = type(of: fieldValue) as? any DynamicProperty.Type {
                propertyOffsets.append((offset, type))
            }
        }

        updaterCache[ObjectIdentifier(Base.self)] = self
    }

    /// Updates each dynamic property of the given value.
    func update(_ value: Base, with environment: EnvironmentValues, previousValue: Base?) {
        for (offset, type) in propertyOffsets {
            update(type)

            func update<Property: DynamicProperty>(_: Property.Type) {
                getProperty(Property.self, of: value, at: offset).update(
                    with: environment,
                    previousValue: previousValue.map {
                        getProperty(Property.self, of: $0, at: offset)
                    }
                )
            }
        }
    }
}
