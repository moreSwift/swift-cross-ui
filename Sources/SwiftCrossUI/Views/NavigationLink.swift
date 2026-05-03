// TODO: This documentation could probably be clarified a bit more (potentially with
//   some practical examples).
/// A navigation primitive that appends a value to the current navigation path on click.
///
/// Unlike Apple's SwiftUI API, a `NavigationLink` can be outside of a `NavigationStack`
/// as long as they share the same `NavigationPath`.
public struct NavigationLink: View {
    public var body: some View {
        Button(label) {
            path.wrappedValue.append(value)
        }
    }

    /// The label to display on the button.
    private let label: String
    /// The value to append to the navigation path when clicked.
    private let value: any Codable
    /// The navigation path to append to when clicked.
    private let path: Binding<NavigationPath>

    /// Creates a navigation link that presents the view corresponding to a value.
    /// The link is handled by whatever ``NavigationStack`` is sharing the same
    /// navigation path.
    ///
    /// - Parameters:
    ///   - label: The label to display on the button.
    ///   - value: The value to append to the navigation path when clicked.
    ///   - path: The navigation path to append to when clicked.
    public init(_ label: String, value: some Codable, path: Binding<NavigationPath>) {
        self.label = label
        self.value = value
        self.path = path
    }
}
