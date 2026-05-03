extension BackendFeatures {
    /// Core backend methods for generic widget containers. These are required for a
    /// functional backend.
    @MainActor
    public protocol GenericContainers: Widgets {
        /// Creates a container in which children can be laid out by SwiftCrossUI
        /// using exact pixel positions.
        ///
        /// - Returns: A container widget.
        func createContainer() -> Widget

        /// Removes all children of the given container.
        ///
        /// - Parameter container: The container to remove the children of.
        func removeAllChildren(of container: Widget)

        /// Inserts a child into a given container at a given index.
        ///
        /// - Parameters:
        ///   - child: The child to insert.
        ///   - container: The container to insert the child into.
        ///   - index: The index to insert the child at.
        func insert(_ child: Widget, into container: Widget, at index: Int)

        /// Swaps the child at firstIndex with the child at secondIndex.
        ///
        /// May crash if either index is out of bounds.
        ///
        /// - Parameters:
        ///   - firstIndex: The index of the first child to swap.
        ///   - secondIndex: The index of the second child to swap.
        ///   - container: The container holding the children.
        func swap(childAt firstIndex: Int, withChildAt secondIndex: Int, in container: Widget)

        /// Sets the position of the specified child in a container.
        ///
        /// - Parameters:
        ///   - index: The index of the child to set the position of.
        ///   - container: The container holding the child.
        ///   - position: The new position.
        func setPosition(ofChildAt index: Int, in container: Widget, to position: SIMD2<Int>)

        /// Removes the child at the given index from the given container.
        ///
        /// - Parameters:
        ///   - index: The index of the child to remove.
        ///   - container: The container to remove the child from.
        func remove(childAt index: Int, from container: Widget)
    }
}
