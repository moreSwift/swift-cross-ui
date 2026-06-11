import CGtk3

@propertyWrapper public struct GObjectProperty<Value: GValueRepresentable> {
    @available(*, unavailable)
    public var wrappedValue: Value {
        get { fatalError("This wrapper only works on instance properties of GObjectRepresentable") }
        // swiftlint:disable:next unused_setter_value
        set { fatalError("This wrapper only works on instance properties of GObjectRepresentable") }
    }

    var name: String

    public init(named: String) {
        self.name = named
    }

    public static subscript<EnclosingSelf: GObjectRepresentable>(
        _enclosingInstance instance: EnclosingSelf,
        wrapped _: ReferenceWritableKeyPath<EnclosingSelf, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Self>
    ) -> Value {
        get {
            instance.getProperty(named: instance[keyPath: storageKeyPath].name)
        }
        set {
            instance.setProperty(named: instance[keyPath: storageKeyPath].name, newValue: newValue)
        }
    }
}
