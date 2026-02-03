import Foundation

public struct ViewGraphSnapshotter: ErasedViewGraphNodeTransformer {
    public struct NodeSnapshot: CustomDebugStringConvertible, Equatable {
        var viewTypeName: String
        /// Property names mapped to encoded JSON objects
        var state: [String: Data]
        var children: [NodeSnapshot]

        public var debugDescription: String {
            var description = "\(viewTypeName)"
            if !state.isEmpty {
                description += "\n| state: {"
                for (propertyName, data) in state {
                    let encodedState = String(data: data, encoding: .utf8) ?? "<invalid utf-8>"
                    description += "\n|   \(propertyName): \(encodedState),"
                }
                description += "\n| }"
            }

            if !children.isEmpty {
                var childDescriptions: [String] = []
                for (i, child) in children.enumerated() {
                    let linePrefix: String
                    if i == children.count - 1 {
                        linePrefix = "    "
                    } else {
                        linePrefix = "|   "
                    }
                    let childDescription = child.debugDescription
                        .split(separator: "\n")
                        .joined(separator: "\n\(linePrefix)")
                    childDescriptions.append("|-> \(childDescription)")
                }
                description += "\n"
                description += childDescriptions.joined(separator: "\n")
            }

            return description
        }

        public func isValid<V: View>(for viewType: V.Type) -> Bool {
            name(of: V.self) == viewTypeName
        }

        public func restore<V: View>(to view: V) {
            guard isValid(for: V.self) else {
                return
            }

            Self.updateState(of: view, withSnapshot: state)
        }

        private static func updateState<V: View>(of view: V, withSnapshot state: [String: Data]) {
            let mirror = Mirror(reflecting: view)
            for property in mirror.children {
                guard
                    let stateProperty = property as? any SnapshottableProperty,
                    let propertyName = property.label,
                    let encodedState = state[propertyName]
                else {
                    continue
                }
                stateProperty.tryRestoreFromSnapshot(encodedState)
            }
        }
    }

    public init() {}

    public func transform<U: View, Backend: AppBackend>(
        node: ViewGraphNode<U, Backend>
    ) -> NodeSnapshot {
        Self.snapshot(of: AnyViewGraphNode(node))
    }

    public static func snapshot<V: View>(of node: AnyViewGraphNode<V>) -> NodeSnapshot {
        var stateSnapshot: [String: Data] = [:]
        let mirror = Mirror(reflecting: node.getView())
        for property in mirror.children {
            guard
                let propertyName = property.label,
                let property = property as? any SnapshottableProperty,
                let encodedState = try? property.snapshot()
            else {
                continue
            }
            stateSnapshot[propertyName] = encodedState
        }

        let nodeChildren = node.getChildren().erasedNodes
        let snapshotter = ViewGraphSnapshotter()
        let childSnapshots = nodeChildren.map { child in
            child.transform(with: snapshotter)
        }

        return NodeSnapshot(
            viewTypeName: name(of: V.self),
            state: stateSnapshot,
            children: childSnapshots
        )
    }

    public static nonisolated func name<V: View>(of viewType: V.Type) -> String {
        String(String(describing: V.self).split(separator: "<")[0])
    }

    /// Attempts to match a list of snapshots to a list of views. Uses assumptions about
    /// a few common types of changes which occur when using hot reloading (e.g. adding/removing
    /// single-child modifier views, adding an extra view between two siblings, etc). At
    /// the end of the day, this task is impossible to do in general (by definition), so
    /// this function is expected to just slowly improve over time to suit the majority of
    /// use-cases.
    static func match(
        _ snapshots: [NodeSnapshot],
        to viewTypeNames: [String]
    ) -> [NodeSnapshot?] {
        var sortedSnapshots: [NodeSnapshot?] = Array(repeating: nil, count: viewTypeNames.count)

        var skippedSnapshots: [NodeSnapshot] = []
        var usedIndices: Set<Int> = []
        for snapshot in snapshots {
            var foundView = false
            for (i, viewTypeName) in viewTypeNames.enumerated() where !usedIndices.contains(i) {
                if snapshot.viewTypeName == viewTypeName {
                    sortedSnapshots[i] = snapshot
                    foundView = true
                    usedIndices.insert(i)
                    break
                }
            }
            if !foundView {
                skippedSnapshots.append(snapshot)
            }
        }

        if sortedSnapshots == [nil] {
            let viewTypeName = viewTypeNames[0]
            var children = snapshots
            while children.count == 1 {
                let child = children[0]
                if child.viewTypeName == viewTypeName {
                    return [child]
                } else {
                    children = child.children
                }
            }
            if snapshots.count == 1 {
                return snapshots
            }
        }

        return sortedSnapshots
    }
}
