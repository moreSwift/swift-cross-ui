import Foundation

/// A view that displays a variable amount of children.
public struct ForEach<Items: Collection, ID: Hashable, Child> {
    /// A variable-length collection of elements to display.
    var elements: Items
    /// A method to display the elements as views.
    var child: (Items.Element) -> Child
    /// The path to the property used as Identifier
    var idKeyPath: KeyPath<Items.Element, ID>?
}

extension ForEach: TypeSafeView, View where Child: View {
    typealias Children = ForEachViewChildren<Items, ID, Child>

    /// Creates a view that creates child views on demand based on a collection
    /// of data.
    ///
    /// One instance of `child` will be rendered for every element in
    /// `elements`.
    ///
    /// - Parameters:
    ///   - elements: The collection to build an array of views from.
    ///   - keyPath: A key path to the element type's ID.
    ///   - child: A view builder that returns an appropriate view for
    ///     each element of `elements`.
    public init(
        _ elements: Items,
        id keyPath: KeyPath<Items.Element, ID>,
        @ViewBuilder _ child: @escaping (Items.Element) -> Child
    ) {
        self.elements = elements
        self.child = child
        self.idKeyPath = keyPath
    }

    public var body: EmptyView {
        return EmptyView()
    }

    func children<Backend: AppBackend>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> Children {
        return Children(
            from: self,
            backend: backend,
            idKeyPath: idKeyPath,
            snapshots: snapshots,
            environment: environment
        )
    }

    func asWidget<Backend: AppBackend>(
        _ children: Children,
        backend: Backend
    ) -> Backend.Widget {
        let container = backend.createContainer()
        if idKeyPath == nil {
            // Deprecated code path. We've centralised the new implementation
            // into computeLayout and commit.
            for (index, node) in children.nodes.enumerated() {
                backend.insert(node.widget.into(), into: container, at: index)
            }
        }
        return container
    }

    func computeLayout<Backend: AppBackend>(
        _ widget: Backend.Widget,
        children: Children,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        func insertChild(_ child: Backend.Widget, atIndex index: Int) {
            children.queuedChanges.append(.insertChild(AnyWidget(child), index))
        }

        func removeChild(atIndex index: Int) {
            children.queuedChanges.append(.removeChild(index))
        }

        func swap(childAt firstIndex: Int, withChildAt secondIndex: Int) {
            children.queuedChanges.append(.swapChildren(firstIndex, secondIndex))
        }

        // Use the previous update Method when no keyPath is set on a
        // [Hashable] Collection to optionally keep the old behaviour.
        guard let idKeyPath else {
            return deprecatedUpdate(
                widget,
                children: children,
                proposedSize: proposedSize,
                environment: environment,
                backend: backend
            )
        }

        var oldIdentifiers = children.identifiers
        let newIdentifiers = elements.map { $0[keyPath: idKeyPath] }

        // If the identifiers of our elements have changed, then we must rearrange
        // our nodes and widgets so that child view states remain with their
        // corresponding identifiers.
        if oldIdentifiers != newIdentifiers {
            var oldIdentifierMap = children.identifierMap
            var oldNodes = children.nodes
            var seenIdentifiers = Set<ID>()
            var oldNodesReused = 0
            children.nodes = []
            children.identifierMap = [:]
            children.identifiers = []
            children.layoutableChildren = []

            var offset = 0
            var duplicateCount = 0
            for (index, element) in elements.enumerated() {
                let identifier = newIdentifiers[index]
                let childContent = child(element)
                let node: AnyViewGraphNode<Child>

                if !seenIdentifiers.insert(identifier).inserted {
                    // We cannot keep view state attached to the correct ForEach element
                    // when there are duplicate identifiers. Any elements with unique
                    // identifiers are guaranteed to keep functioning correctly. Elements
                    // with non-unique identifiers will get their corresponding view graph
                    // nodes recreated each time the identifiers of our elements change,
                    // unless they are the first element with the shared identifier, in which
                    // case they will inherit the view graph node of the previous first element
                    // with that same identifier.
                    logger.warning(
                        "duplicate identifier in ForEach; view state may not act as you would expect",
                        metadata: ["identifier": "\(identifier)"]
                    )
                    duplicateCount += 1
                }

                if let oldIndex = oldIdentifierMap.removeValue(forKey: identifier) {
                    // If the identifier already has a corresponding node, reuse it.
                    node = oldNodes[oldIndex]
                    oldNodesReused += 1

                    // If the node's corresponding widget isn't already at the correct
                    // position (accounting for insertions), then swap it with the widget
                    // at the target position and update our accounting accordinly.
                    if index != offset + oldIndex {
                        // When talking about current widget indices, we add `offset` to oldIndex.
                        // When talking about old element indices, we subtract `offset` from index.
                        swap(childAt: offset + oldIndex, withChildAt: index)
                        oldNodes.swapAt(oldIndex, index - offset)
                        oldIdentifierMap[oldIdentifiers[index - offset]] = oldIndex
                        oldIdentifiers.swapAt(oldIndex, index - offset)
                    }
                } else {
                    // If the identifier is new, create a node for it and insert its
                    // widget at the correct position.
                    node = AnyViewGraphNode(
                        for: childContent,
                        backend: backend,
                        environment: environment
                    )
                    insertChild(node.widget.into(), atIndex: index)

                    // `offset` tracks how many elements have been inserted, which we
                    // use to adjust old indices. All nodes before the one we just
                    // inserted are already at their final position, so we never have
                    // to adjust old indices that point to before our latest insertion, otherwise
                    // such a simple adjustment wouldn't be possible.
                    offset += 1
                }

                children.nodes.append(node)
                children.identifierMap[identifier] = index
                children.identifiers.append(identifier)
                children.layoutableChildren.append(
                    LayoutSystem.LayoutableChild(node) { child(element) }
                )
            }

            // TODO: We should be able to reuse unused widgets in newly created nodes.
            // Remove unused widgets, starting from the end of the container for
            // cheaper removals.
            let removalCount = oldNodes.count - oldNodesReused
            if removalCount > 0 {
                for i in (0..<removalCount).reversed() {
                    removeChild(atIndex: children.nodes.count + i)
                }
            }
        }

        // Recompute layoutable children if the last commit cleared them
        if children.layoutableChildren.isEmpty && !children.nodes.isEmpty {
            children.layoutableChildren = zip(children.nodes, elements).map { (node, element) in
                LayoutSystem.LayoutableChild(node) { child(element) }
            }
        }

        return LayoutSystem.computeStackLayout(
            container: widget,
            children: children.layoutableChildren,
            cache: &children.stackLayoutCache,
            proposedSize: proposedSize,
            environment: environment,
            backend: backend
        )
    }

    @MainActor
    func deprecatedUpdate<Backend: AppBackend>(
        _ widget: Backend.Widget,
        children: Children,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        @inline(__always)
        func insertChild(_ child: Backend.Widget, atIndex index: Int) {
            children.queuedChanges.append(.insertChild(AnyWidget(child), index))
        }

        @inline(__always)
        func removeChild(atIndex index: Int) {
            children.queuedChanges.append(.removeChild(index))
        }

        let elementsStartIndex = elements.startIndex

        // TODO: The way we're reusing nodes for technically different elements means that if
        //   Child has state of its own then it could get pretty confused thinking that its state
        //   changed whereas it was actually just moved to a new slot in the array. Probably not
        //   a huge issue, but definitely something to keep an eye on.
        var layoutableChildren: [LayoutSystem.LayoutableChild] = []
        for (i, node) in children.nodes.enumerated() {
            guard i < elements.count else {
                break
            }
            let index = elements.index(elementsStartIndex, offsetBy: i)
            if children.isFirstUpdate {
                insertChild(node.widget.into(), atIndex: i)
            }
            let layoutableChild = LayoutSystem.LayoutableChild(node) { child(elements[index]) }
            layoutableChildren.append(layoutableChild)
        }
        children.isFirstUpdate = false

        let nodeCount = children.nodes.count
        let remainingElementCount = elements.count - nodeCount
        if remainingElementCount > 0 {
            let startIndex = elements.index(elementsStartIndex, offsetBy: nodeCount)
            for i in 0..<remainingElementCount {
                let element = elements[elements.index(startIndex, offsetBy: i)]
                let node = AnyViewGraphNode(
                    for: child(element),
                    backend: backend,
                    environment: environment
                )
                insertChild(node.widget.into(), atIndex: children.nodes.count)
                children.nodes.append(node)
                let layoutableChild = LayoutSystem.LayoutableChild(node) { child(element) }
                layoutableChildren.append(layoutableChild)
            }
        } else if remainingElementCount < 0 {
            let unusedCount = -remainingElementCount
            for i in 0..<unusedCount {
                removeChild(atIndex: nodeCount - i - 1)
            }
            children.nodes.removeLast(unusedCount)
        }

        return LayoutSystem.computeStackLayout(
            container: widget,
            children: layoutableChildren,
            cache: &children.stackLayoutCache,
            proposedSize: proposedSize,
            environment: environment,
            backend: backend
        )
    }

    func commit<Backend: AppBackend>(
        _ widget: Backend.Widget,
        children: Children,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        for change in children.queuedChanges {
            switch change {
                case .insertChild(let child, let index):
                    backend.insert(child.into(), into: widget, at: index)
                case .removeChild(let index):
                    backend.remove(childAt: index, from: widget)
                case .swapChildren(let firstIndex, let secondIndex):
                    backend.swap(childAt: firstIndex, withChildAt: secondIndex, in: widget)
            }
        }
        children.queuedChanges = []

        LayoutSystem.commitStackLayout(
            container: widget,
            children: children.layoutableChildren,
            cache: &children.stackLayoutCache,
            layout: layout,
            environment: environment,
            backend: backend
        )

        // Reset layoutable children cache so that we recompute them during the
        // next update cycle. This is important at the moment because the `child`
        // closure and `elements` array may have changed. In future we'll separate
        // view body recomputation from the computeLayout step, which should simplify
        // things.
        children.layoutableChildren = []
    }
}

/// Stores the child nodes of a ``ForEach`` view.
///
/// Also handles the ``ForEach`` view's widget unlike most ``ViewGraphNodeChildren``
/// implementations. This logic could mostly be moved into ``ForEach`` but it would still
/// be accessing ``ForEachViewChildren/storage`` so it'd just introduce an extra layer of
/// property accesses. It also means that the complexity is in a single type instead of
/// split across two.
///
/// Most of the complexity comes from resizing the list widget and moving around elements
/// when elements are added/removed.
class ForEachViewChildren<
    Items: Collection,
    ID: Hashable,
    Child: View
>: ViewGraphNodeChildren {
    /// The nodes for all current children of the ``ForEach`` view.
    var nodes: [AnyViewGraphNode<Child>] = []

    /// A map from element identifier to node index.
    var identifierMap: [ID: Int]

    /// The identifiers corresponding to ``nodes``.
    var identifiers: [ID]

    /// Changes queued during computeLayout.
    var queuedChanges: [Change] = []

    /// A queued widget operation to perform during `ForEach.commit`.
    enum Change: CustomStringConvertible {
        case insertChild(AnyWidget, Int)
        case removeChild(Int)
        case swapChildren(Int, Int)

        var description: String {
            switch self {
                case .insertChild(let widget, let index):
                    "Insert widget \(ObjectIdentifier(widget.widget as AnyObject)) at \(index)"
                case .removeChild(let index):
                    "Remove widget at \(index)"
                case .swapChildren(let firstIndex, let secondIndex):
                    "Swap widgets at \(firstIndex) and \(secondIndex)"
            }
        }
    }

    /// Only used by ``ForEach/deprecatedUpdate(_:children:proposedSize:environment:backend:)``.
    var isFirstUpdate = true

    /// A cache of the view's children, used when the ForEach's element
    /// identifiers haven't changed since the previous layout computation.
    var layoutableChildren: [LayoutSystem.LayoutableChild] = []

    var widgets: [AnyWidget] {
        nodes.map(\.widget)
    }

    // TODO: This pattern of erasing by wrapping in a temporary class seems
    //   inefficient. Could ErasedViewGraphNode maybe be a struct instead?
    var erasedNodes: [ErasedViewGraphNode] {
        nodes.map(ErasedViewGraphNode.init(wrapping:))
    }

    var stackLayoutCache = StackLayoutCache.initial

    init<Backend: AppBackend>(
        from view: ForEach<Items, ID, Child>,
        backend: Backend,
        idKeyPath: KeyPath<Items.Element, ID>?,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) {
        identifierMap = [:]
        identifiers = []

        if idKeyPath == nil {
            // Deprecated code path. I'm not touching this anymore cause it's
            // gonna get deleted before any proper release.
            nodes = view.elements
                .map(view.child)
                .enumerated()
                .map { (index, child) in
                    let snapshot = index < snapshots?.count ?? 0 ? snapshots?[index] : nil
                    return ViewGraphNode(
                        for: child,
                        backend: backend,
                        snapshot: snapshot,
                        environment: environment
                    )
                }
                .map(AnyViewGraphNode.init(_:))
        } else {
            nodes = []
        }
    }
}

extension ForEach where ID == Int {
    /// Creates a view that creates child views on demand based on a collection of data.
    @available(
        *, deprecated, renamed: "init(_:id:_:)",
        message:
            "ForEach requires an explicit 'id' parameter for non-Identifiable elements to correctly persist state across view updates"
    )
    @_disfavoredOverload
    public init(
        _ elements: Items,
        @ViewBuilder _ child: @escaping (Items.Element) -> Child
    ) {
        self.elements = elements
        self.child = child
        self.idKeyPath = nil
    }
}

extension ForEach where Child == [MenuItem], ID == Int {
    /// Creates a view that creates child views on demand based on a collection of data.
    @available(
        *,
        deprecated,
        message:
            "ForEach requires an explicit 'id' parameter for non-Identifiable elements to correctly persist state across view updates"
    )
    @_disfavoredOverload
    public init(
        menuItems elements: Items,
        @MenuItemsBuilder _ child: @escaping (Items.Element) -> [MenuItem]
    ) {
        self.elements = elements
        self.child = child
        self.idKeyPath = nil
    }
}

extension ForEach where Child == [MenuItem] {
    /// Creates a view that creates child views on demand based on a collection of data.
    public init(
        menuItems elements: Items,
        id keyPath: KeyPath<Items.Element, ID>,
        @MenuItemsBuilder _ child: @escaping (Items.Element) -> [MenuItem]
    ) {
        self.elements = elements
        self.child = child
        self.idKeyPath = keyPath
    }
}

extension ForEach where Items.Element: Identifiable, Child == [MenuItem], ID == Items.Element.ID {
    /// Creates a view that creates child views on demand based on a collection of data.
    public init(
        menuItems elements: Items,
        @MenuItemsBuilder _ child: @escaping (Items.Element) -> [MenuItem]
    ) {
        self.elements = elements
        self.child = child
        self.idKeyPath = \.id
    }
}

extension ForEach where Items.Element: Identifiable, ID == Items.Element.ID {
    /// Creates a view that creates child views on demand based on a collection of identifiable data.
    public init(
        _ elements: Items,
        child: @escaping (Items.Element) -> Child
    ) {
        self.elements = elements
        self.child = child
        self.idKeyPath = \.id
    }
}
