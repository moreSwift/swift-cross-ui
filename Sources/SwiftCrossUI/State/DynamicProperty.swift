/// A property wrapper updated by the view graph before each access to
/// ``View/body``.
///
/// Conforming types should use internal mutability to implement this protocol's
/// non-`mutating` methods if required. This protocol avoids mutation to allow
/// state properties and such to be captured even though views are structs.
public protocol DynamicProperty {
    /// Updates the property.
    ///
    /// This is called by SwiftCrossUI before every access it makes to an
    /// `App.body` or `View.body`.
    ///
    /// - Parameters:
    ///   - environment: The current environment.
    ///   - previousValue: The previous value of the property. `nil` if this is
    ///     the first time an update has been made.
    func update(
        with environment: EnvironmentValues,
        previousValue: Self?
    )
}
