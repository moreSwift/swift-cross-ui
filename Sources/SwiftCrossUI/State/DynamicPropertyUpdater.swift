/// A cache for dynamic property updaters.
///
/// The keys are the `ObjectIdentifier`s of various `Base` types that we have
/// already computed dynamic property updaters for, and the elements are
/// corresponding cached instances of `DynamicPropertyUpdater<Base>`.
///
/// From some basic testing, this caching seems to reduce layout times by 5-10%
/// (at the time of implementation).
@MainActor
var updaterCache: [ObjectIdentifier: Any] = [:]

/// A helper for updating the dynamic properties of a stateful struct (e.g.
/// a struct conforming to ``View`` or ``App``).
///
/// Dynamic properties are those that conform to ``DynamicProperty``, e.g. those
/// annotated with the ``State`` property wrapper.
///
/// At initialisation, the updater will attempt to determine the byte offset of
/// each stateful property in the struct. This is guaranteed to succeed if every
/// dynamic property in the provided struct instance contains internal mutable
/// storage, because the storage pointers will provide unique byte sequences.
/// Otherwise, offset discovery will fail when two dynamic properties share the
/// same pattern in memory. When offset discovery fails the updater will fall
/// back to using `Mirror`s each time `update` gets called, which can be 1500x
/// times slower when the view has 0 state properties, and 9x slower when the
/// view has 4 properties, with the factor slowly dropping as the number of
/// properties increases.
struct DynamicPropertyUpdater<Base> {
    typealias PropertyUpdater = (
        _ old: Base?,
        _ new: Base,
        _ environment: EnvironmentValues
    ) -> Void

    /// The updaters for each of `Base`'s dynamic properties.
    ///
    /// If `nil`, then we failed to compute the updaters.
    let propertyUpdaters: [PropertyUpdater]?

    /// Creates a new dynamic property updater which can efficiently update
    /// all dynamic properties on any value of type `Base` without creating
    /// any mirrors after the initial creation of the updater.
    ///
    /// - Parameters:
    ///   - base: The base value to update the dynamic properties of.
    ///   - mirror: An existing mirror of `base`. If not provided, a mirror will
    ///     be created.
    @MainActor
    init(for base: Base, mirror: Mirror? = nil) {
        // Unlikely shortcut, but worthwhile when we can.
        if MemoryLayout<Base>.size == 0 {
            self.propertyUpdaters = []
            return
        }

        if let cachedUpdater = updaterCache[ObjectIdentifier(Base.self)],
            let cachedUpdater = cachedUpdater as? Self
        {
            self = cachedUpdater
            return
        }

        var propertyUpdaters: [PropertyUpdater] = []

        let mirror = mirror ?? Mirror(reflecting: base)
        for child in mirror.children {
            let label = child.label ?? "<unlabelled>"
            let value = child.value

            guard let value = value as? any DynamicProperty else {
                continue
            }

            guard let updater = Self.getUpdater(for: value, base: base, label: label) else {
                // We have failed to create the required property updaters. Fallback
                // to using Mirrors to update all properties.
                logger.warning(
                    """
                    failed to produce DynamicPropertyUpdater; falling back to \
                    slower Mirror-based property updating approach
                    """,
                    metadata: ["type": "\(Base.self)"]
                )
                self.propertyUpdaters = nil

                // We intentionally return without caching the updaters here so
                // that we if this failure is a fluke we can recover on a
                // subsequent attempt for the same type. It may turn out that in
                // practice types that fail are ones that always fail, in which
                // case we should update this code to add the current updater to
                // the cache.
                return
            }

            propertyUpdaters.append(updater)
        }

        self.propertyUpdaters = propertyUpdaters

        updaterCache[ObjectIdentifier(Base.self)] = self
    }

    /// Updates each dynamic property of the given value.
    func update(_ value: Base, with environment: EnvironmentValues, previousValue: Base?) {
        guard let propertyUpdaters else {
            // Fall back to our old dynamic property updating approach which involves a lot of
            // Mirror overhead. This should be rare.
            Self.updateFallback(of: value, previousValue: previousValue, environment: environment)
            return
        }

        for updater in propertyUpdaters {
            updater(previousValue, value, environment)
        }
    }

    /// Gets an updater for the property of base with the given value. If multiple
    /// properties exist matching the byte pattern of `value`, then `nil` is returned.
    ///
    /// The returned updater is reusable and doesn't use Mirror.
    private static func getUpdater<T: DynamicProperty>(
        for value: T,
        base: Base,
        label: String
    ) -> PropertyUpdater? {
        guard let keyPath = DynamicKeyPath(forProperty: value, of: base, label: label) else {
            return nil
        }

        let updater = { (old: Base?, new: Base, environment: EnvironmentValues) in
            let property = keyPath.get(new)
            property.update(
                with: environment,
                previousValue: old.map(keyPath.get)
            )
        }

        return updater
    }

    /// Updates the dynamic properties of a value given a previous instance of the
    /// type (if one exists) and the current environment.
    private static func updateFallback<T>(
        of value: T,
        previousValue: T?,
        environment: EnvironmentValues
    ) {
        let newMirror = Mirror(reflecting: value)
        let previousMirror = previousValue.map(Mirror.init(reflecting:))
        if let previousChildren = previousMirror?.children {
            let propertySequence = zip(newMirror.children, previousChildren)
            for (newProperty, previousProperty) in propertySequence {
                guard
                    let newValue = newProperty.value as? any DynamicProperty,
                    let previousValue = previousProperty.value as? any DynamicProperty
                else {
                    continue
                }

                updateDynamicPropertyFallback(
                    newProperty: newValue,
                    previousProperty: previousValue,
                    environment: environment,
                    enclosingTypeName: "\(T.self)",
                    propertyName: newProperty.label
                )
            }
        } else {
            for property in newMirror.children {
                guard let newValue = property.value as? any DynamicProperty else {
                    continue
                }

                updateDynamicPropertyFallback(
                    newProperty: newValue,
                    previousProperty: nil,
                    environment: environment,
                    enclosingTypeName: "\(T.self)",
                    propertyName: property.label
                )
            }
        }
    }

    /// Updates a dynamic property. Required to unmask the concrete type of the
    /// property. Since the two properties can technically be two different
    /// types, Swift correctly wouldn't allow us to assume they're both the
    /// same. So we unwrap one and then dynamically check whether the other
    /// matches using a type cast.
    private static func updateDynamicPropertyFallback<Property: DynamicProperty>(
        newProperty: Property,
        previousProperty: (any DynamicProperty)?,
        environment: EnvironmentValues,
        enclosingTypeName: String,
        propertyName: String?
    ) {
        let castedPreviousProperty: Property?
        if let previousProperty {
            guard let previousProperty = previousProperty as? Property else {
                fatalError(
                    """
                    Supposedly unreachable... previous and current types of \
                    \(enclosingTypeName).\(propertyName ?? "<unknown property>") \
                    don't match.
                    """
                )
            }

            castedPreviousProperty = previousProperty
        } else {
            castedPreviousProperty = nil
        }

        newProperty.update(
            with: environment,
            previousValue: castedPreviousProperty
        )
    }
}
