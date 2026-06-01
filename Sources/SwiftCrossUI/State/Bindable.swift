import Foundation

/// A property wrapper that exposes bindings to writable properties on a
/// mutable model object.
///
/// Use `Bindable` when you want controls to edit data stored in an object that
/// participates in observation, such as a type annotated with `@Observable` or
/// `@Perceptible` from the
/// [Perception](https://github.com/pointfreeco/swift-perception) package.
/// Applying `@Bindable` lets you use `$` to derive bindings for the object's
/// mutable members.
///
///     @Perceptible
///     final class Profile {
///         var name = "Taylor"
///         var receivesNewsletter = false
///     }
///
///     struct ProfileEditor: View {
///         @Bindable var profile: Profile
///
///         var body: some View {
///             Form {
///                 TextField("Name", text: $profile.name)
///                 Toggle("Newsletter", isOn: $profile.receivesNewsletter)
///             }
///         }
///     }
///
/// `Bindable` can also be applied to stored properties, globals, and local
/// variables. This is useful when you already have an observable or perceptible
/// object and need bindings for only part of a view hierarchy. For example,
/// you can introduce a local `@Bindable` value inside `body`:
///
///     @Observable
///     final class TaskItem: Identifiable {
///         let id = UUID()
///         var title = ""
///     }
///
///     struct TaskListView: View {
///         @State private var tasks = [TaskItem(), TaskItem()]
///
///         var body: some View {
///             VStack {
///                 ForEach(tasks) { task in
///                     @Bindable var task = task
///                     TextField("Task", text: $task.title)
///                 }
///             }
///         }
///     }
///
/// The local `@Bindable` value supplies the binding that keeps ``TextField``
/// synchronized with the corresponding model property.
///
/// The same pattern works for objects obtained from the environment. Fetch the
/// model first, then create a local `@Bindable` wrapper and pass its projected
/// bindings where needed.
///
///     struct AccountNameView: View {
///         @Environment(Account.self) private var account
///
///         var body: some View {
///             @Bindable var account = account
///             TextField("Account name", text: $account.name)
///         }
///     }
///
@dynamicMemberLookup @propertyWrapper public struct Bindable<Value> {
    /// The wrapped object.
    public var wrappedValue: Value

    /// A bindable wrapper that uses dynamic member lookup to vend bindings for
    /// writable properties on the wrapped object.
    public var projectedValue: Bindable<Value> {
        self
    }
    
    /// Creates a bindable wrapper around an observable or perceptible object.
    ///
    /// In most cases, apply the `@Bindable` attribute to a property or local
    /// variable instead of calling this initializer directly.
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

extension Bindable where Value : AnyObject {
    /// Returns a binding for the writable property at the supplied key path.
    public subscript<Subject>(dynamicMember keyPath: ReferenceWritableKeyPath<Value, Subject>) -> Binding<Subject> {
        Binding(
            get: {
                wrappedValue[keyPath: keyPath]
            },
            set: { newValue in
                wrappedValue[keyPath: keyPath] = newValue
            }
        )
    }
    
    /// Creates a bindable wrapper around an observable or perceptible object.
    ///
    /// This initializer behaves the same as ``init(wrappedValue:)``, but reads
    /// better when constructing a bindable value inline inside another
    /// expression. For example, you can create a binding while configuring a
    /// view in place:
    ///
    ///     struct SearchSettingsView: View {
    ///         @Environment(SearchSettings.self) private var settings
    ///
    ///         var body: some View {
    ///             Toggle("Exact matches only", isOn: Bindable(settings).exactMatchesOnly)
    ///         }
    ///     }
    ///
    public init(_ wrappedValue: Value) {
        self.init(wrappedValue: wrappedValue)
    }

    /// Creates a bindable wrapper from another bindable wrapper's value.
    public init(projectedValue: Bindable<Value>) {
        self.init(wrappedValue: projectedValue.wrappedValue)
    }
}

extension Bindable : Identifiable where Value : Identifiable {

    /// The stable identity of the wrapped value.
    public var id: Value.ID {
        wrappedValue.id
    }

    /// A type representing the stable identity of the wrapped value.
    public typealias ID = Value.ID
}

extension Bindable : Sendable where Value : Sendable {}
