/// A simple wrapper used to implement internal mutability. Mostly used by
/// dynamic property wrappers (see ``DynamicProperty``).
final class Box<V> {
    var value: V

    init(_ value: V) {
        self.value = value
    }
}
