/// A column of a ``NavigationSplitView``.
public struct NavigationSplitViewColumn: Sendable, Hashable {
    /// The internal enum representation, used by backends.
    @_spi(Backends) public enum Column: Sendable, Hashable {
        case sidebar
        case content
        case detail
    }

    /// The internal enum representation, used by backends.
    @_spi(Backends) public var column: Column

    /// The leading column.
    public static let sidebar = Self(column: .sidebar)
    /// The middle column.
    public static let content = Self(column: .content)
    /// The trailing detail column.
    public static let detail = Self(column: .detail)
}
