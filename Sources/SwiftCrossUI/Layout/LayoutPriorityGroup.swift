/// The subset of a stack's children with a particular layout priority.
struct LayoutPriorityGroup {
    /// The stack's children, referenced by index, using the index of the
    /// child based on the visual order of the stack's children (rather
    /// than the flexibility-based layout order). The children are in
    /// order of increasing flexibility.
    var children: ArraySlice<Int>
    /// The layout priority of all children within this subset.
    var priority: Double
}
