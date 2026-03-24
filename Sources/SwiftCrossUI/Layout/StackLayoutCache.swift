/// The cache's properties are read-only to avoid the possibility of their
/// values getting out of sync with each other (especially when new
/// properties get introduced).
struct StackLayoutCache {
    /// The stack's children grouped by priority. May sometimes have all children
    /// in a single group due to the stack layout system determining that
    /// flexibility/priority will not have an effect on the final layout.
    let priorityGroups: [LayoutPriorityGroup]
    /// Whether each child is hidden or not. Hidden means zero size *and* doesn't
    /// want spacing of its own in the stack.
    let isHidden: [Bool]
    /// The total amount of spacing used by the stack.
    let totalSpacing: Double
    /// The total amount of space reserved. Equal to the total amount of spacing
    /// plus the sum of the minimum length of each view.
    let totalReservedSpace: Double
    /// The minimum length of each view.
    let minimumLengths: [Double]
    /// Whether to redistribute space on commit or not. `true` if and only if the
    /// stack was provided a proposed size with an unspecified perpendicular axis.
    let redistributeSpaceOnCommit: Bool

    /// The initial value of the cache (just a dummy value, shouldn't ever be used).
    static let initial = StackLayoutCache(
        priorityGroups: [],
        isHidden: [],
        totalSpacing: 0,
        totalReservedSpace: 0,
        minimumLengths: [],
        redistributeSpaceOnCommit: false
    )
}
