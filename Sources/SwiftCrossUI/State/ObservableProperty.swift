import Foundation

/// View properties that conform to ObservableProperty are automatically observed by SwiftCrossUI.
///
/// This protocol is intended to be implemented by property wrappers. You shouldn't
/// have to implement it for your own model types.
public protocol ObservableProperty: DynamicProperty {
    var didChange: Publisher { get }
}

/// View properties that conform to SnapshottableProperty can be snapshotted by
/// the hot reloading mechanism.
///
/// This protocol is intended to be implemented by property wrappers. You shouldn't
/// have to implement it for your own model types.
public protocol SnapshottableProperty: ObservableProperty {
    func tryRestoreFromSnapshot(_ snapshot: Data)
    func snapshot() throws -> Data?
}
