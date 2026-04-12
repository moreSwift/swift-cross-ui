public enum LayoutSystem {
    static func width(forHeight height: Double, aspectRatio: Double) -> Double {
        Double(height) * aspectRatio
    }

    static func height(forWidth width: Double, aspectRatio: Double) -> Double {
        Double(width) / aspectRatio
    }

    package static func roundSize(_ size: Double) -> Int {
        if size.isInfinite {
            logger.warning("LayoutSystem.roundSize(_:) called with infinite size")
        }

        let size = size.rounded(.towardZero)
        return if size >= Double(Int.max) {
            Int.max
        } else if size <= Double(Int.min) {
            Int.min
        } else {
            Int(size)
        }
    }

    static func clamp(_ value: Double, minimum: Double?, maximum: Double?) -> Double {
        var value = value
        if let minimum {
            value = max(minimum, value)
        }
        if let maximum {
            value = min(maximum, value)
        }
        return value
    }

    static func aspectRatio(of frame: ViewSize) -> Double {
        aspectRatio(of: SIMD2(frame.width, frame.height))
    }

    static func aspectRatio(of frame: SIMD2<Double>) -> Double {
        if frame.x == 0 || frame.y == 0 {
            // Even though we could technically compute an aspect ratio when the
            // ideal width is 0, it leads to a lot of annoying usecases and isn't
            // very meaningful, so we default to 1 in that case as well as the
            // division by zero case.
            return 1
        } else {
            return frame.x / frame.y
        }
    }

    public struct LayoutableChild {
        private var computeLayout:
            @MainActor (
                _ proposedSize: ProposedViewSize,
                _ environment: EnvironmentValues
            ) -> ViewLayoutResult
        private var _commit: @MainActor () -> ViewLayoutResult
        var tag: String?

        public init(
            computeLayout:
                @escaping @MainActor (ProposedViewSize, EnvironmentValues) ->
                ViewLayoutResult,
            commit: @escaping @MainActor () -> ViewLayoutResult,
            tag: String? = nil
        ) {
            self.computeLayout = computeLayout
            self._commit = commit
            self.tag = tag
        }

        init<Child: View>(
            _ node: AnyViewGraphNode<Child>,
            child: @escaping @Sendable @MainActor () -> Child?
        ) {
            self.init(
                computeLayout: { proposedSize, environment in
                    node.computeLayout(
                        with: child(),
                        proposedSize: proposedSize,
                        environment: environment
                    )
                },
                commit: {
                    node.commit()
                }
            )
        }

        @MainActor
        public func computeLayout(
            proposedSize: ProposedViewSize,
            environment: EnvironmentValues
        ) -> ViewLayoutResult {
            computeLayout(proposedSize, environment)
        }

        @MainActor
        public func commit() -> ViewLayoutResult {
            _commit()
        }
    }

    /// - Parameter inheritStackLayoutParticipation: If `true`, the stack layout
    ///   will have ``ViewSize/participateInStackLayoutsWhenEmpty`` set to `true`
    ///   if all of its children have it set to true. This allows views such as
    ///   ``Group`` to avoid changing stack layout participation (since ``Group``
    ///   is meant to appear completely invisible to the layout system).
    @MainActor
    static func computeStackLayout<Backend: BaseAppBackend>(
        container: Backend.Widget,
        children: [LayoutableChild],
        cache: inout StackLayoutCache,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend,
        inheritStackLayoutParticipation: Bool = false
    ) -> ViewLayoutResult {
        let spacing = environment.layoutSpacing
        let orientation = environment.layoutOrientation
        let perpendicularOrientation = orientation.perpendicular

        let stackLength = proposedSize[component: orientation]
        if stackLength == 0 || stackLength == .infinity || stackLength == nil || children.count == 1
        {
            var resultLength: Double = 0
            var resultWidth: Double = 0
            var results: [ViewLayoutResult] = []
            for child in children {
                let result = child.computeLayout(
                    proposedSize: proposedSize,
                    environment: environment
                )
                resultLength += result.size[component: orientation]
                resultWidth = max(resultWidth, result.size[component: perpendicularOrientation])
                results.append(result)
            }

            let visibleChildrenCount = results.count { result in
                result.participatesInStackLayouts
            }

            let totalSpacing = Double(max(visibleChildrenCount - 1, 0) * spacing)
            var size = ViewSize.zero
            size[component: orientation] = resultLength + totalSpacing
            size[component: perpendicularOrientation] = resultWidth

            // In this case, flexibility and layout priority don't matter. We set
            // the grouping to the trivial grouping so that commitStackLayout
            // effectively ignores flexibility.
            let group = LayoutPriorityGroup(
                children: Array(children.indices)[...],
                priority: 0
            )
            cache = StackLayoutCache(
                priorityGroups: [group],
                isHidden: results.map(\.participatesInStackLayouts).map(!),
                // TODO(stackotter): How does SwiftUI handle space reservation during
                //   relayouts? I feel like it probably doesn't use minimum lengths if
                //   it didn't already have to during the initial layout pass because
                //   the alternative would be expensive, but that approach would also
                //   be a bit inconsistent
                totalSpacing: totalSpacing,
                totalReservedSpace: totalSpacing,
                minimumLengths: [Double](repeating: 0, count: children.count),
                redistributeSpaceOnCommit:
                    shouldRedistributeSpaceOnCommit(
                        proposedSize: proposedSize,
                        orientation: orientation
                    )
            )

            return ViewLayoutResult(
                size: size,
                childResults: results,
                participateInStackLayoutsWhenEmpty:
                    results.contains(where: \.participateInStackLayoutsWhenEmpty),
                preferencesOverlay: nil
            )
        }

        guard let stackLength else {
            fatalError("unreachable")
        }

        cache = recomputeCache(
            children: children,
            proposedSize: proposedSize,
            environment: environment
        )

        let renderedChildren = computeLayouts(
            of: children,
            proposedLength: stackLength,
            proposedPerpendicular: proposedSize[component: perpendicularOrientation],
            cache: cache,
            environment: environment,
            ignoreHiddenChildrenEntirely: false
        )

        var size = ViewSize.zero
        size[component: orientation] =
            renderedChildren.map(\.size[component: orientation]).reduce(0, +) + cache.totalSpacing
        size[component: perpendicularOrientation] =
            renderedChildren.map(\.size[component: perpendicularOrientation]).max() ?? 0

        return ViewLayoutResult(
            size: size,
            childResults: renderedChildren,
            participateInStackLayoutsWhenEmpty:
                renderedChildren.contains(where: \.participateInStackLayoutsWhenEmpty)
        )
    }

    /// Computes whether or not we have to redistribute space on commit. Returns true
    /// if and only if the perpendicular component of the proposed size is nil.
    static func shouldRedistributeSpaceOnCommit(
        proposedSize: ProposedViewSize,
        orientation: Orientation
    ) -> Bool {
        // When the perpendicular axis is unspecified (nil), we need
        // to re-run the space distribution algorithm with our final size during
        // the commit phase. This opens the door to certain edge cases, but SwiftUI
        // has them too, and there's not a good general solution to these edge
        // cases, even if you assume that you have unlimited compute. The reason for
        // this distribution is so that flexible children get a chance to use up any
        // unused space within the final perpendicular size of the stack.
        proposedSize[component: orientation.perpendicular] == nil
    }

    /// Computes the cache from scratch for the slow path (this is our last
    /// resort if shortcuts can't be made), preparing it for subsequent layout
    /// operations.
    @MainActor
    static func recomputeCache(
        children: [LayoutableChild],
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues
    ) -> StackLayoutCache {
        let orientation = environment.layoutOrientation
        let spacing = environment.layoutSpacing

        // My thanks go to this great article for investigating and explaining
        // how SwiftUI determines child view 'flexibility':
        // https://www.objc.io/blog/2020/11/10/hstacks-child-ordering/
        var minimumProposedSize = proposedSize
        minimumProposedSize[component: orientation] = 0
        var maximumProposedSize = proposedSize
        maximumProposedSize[component: orientation] = .infinity
        var isHidden = [Bool](repeating: false, count: children.count)
        var priorities = [Double](repeating: 0, count: children.count)
        var minimums = [Double](repeating: 0, count: children.count)
        var totalReservedSpace = 0.0
        let flexibilities = children.enumerated().map { i, child in
            let minimumResult = child.computeLayout(
                proposedSize: minimumProposedSize,
                environment: environment.with(\.allowLayoutCaching, true)
            )
            let maximumResult = child.computeLayout(
                proposedSize: maximumProposedSize,
                environment: environment.with(\.allowLayoutCaching, true)
            )
            isHidden[i] = !minimumResult.participatesInStackLayouts
            priorities[i] = minimumResult.preferences.layoutPriority
            let maximum = maximumResult.size[component: orientation]
            let minimum = minimumResult.size[component: orientation]
            totalReservedSpace += minimum
            minimums[i] = minimum
            return maximum - minimum
        }
        let visibleChildrenCount = isHidden.filter { hidden in
            !hidden
        }.count
        let totalSpacing = Double(max(visibleChildrenCount - 1, 0) * spacing)
        totalReservedSpace += totalSpacing

        let sortedChildren = zip(children.indices, zip(priorities.map(-), flexibilities))
            .sorted { first, second in
                // Sort by descending priority and then by ascending flexibility
                first.1 <= second.1
            }
            .map { index, _ in
                index
            }

        var priorityGroups: [LayoutPriorityGroup] = []
        var previousPriority: Double? = nil
        var startIndex: Int?
        for (sortedIndex, originalIndex) in sortedChildren.enumerated() {
            let priority = priorities[originalIndex]
            if priority != previousPriority {
                if let startIndex, let previousPriority {
                    let group = LayoutPriorityGroup(
                        children: sortedChildren[startIndex..<sortedIndex],
                        priority: previousPriority
                    )
                    priorityGroups.append(group)
                }
                startIndex = sortedIndex
                previousPriority = priority
            }
        }

        if let startIndex, let previousPriority {
            let group = LayoutPriorityGroup(
                children: sortedChildren[startIndex..<sortedChildren.endIndex],
                priority: previousPriority
            )
            priorityGroups.append(group)
        }

        return StackLayoutCache(
            priorityGroups: priorityGroups,
            isHidden: isHidden,
            totalSpacing: totalSpacing,
            totalReservedSpace: totalReservedSpace,
            minimumLengths: minimums,
            redistributeSpaceOnCommit: shouldRedistributeSpaceOnCommit(
                proposedSize: proposedSize,
                orientation: orientation
            )
        )
    }

    @MainActor
    static func commitStackLayout<Backend: BaseAppBackend>(
        container: Backend.Widget,
        children: [LayoutableChild],
        cache: inout StackLayoutCache,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        let size = layout.size
        backend.setSize(of: container, to: size.vector)

        let alignment = environment.layoutAlignment
        let spacing = environment.layoutSpacing
        let orientation = environment.layoutOrientation
        let perpendicularOrientation = orientation.perpendicular

        if cache.redistributeSpaceOnCommit {
            _ = computeLayouts(
                of: children,
                proposedLength: layout.size[component: orientation],
                proposedPerpendicular: layout.size[component: perpendicularOrientation],
                cache: cache,
                environment: environment,
                ignoreHiddenChildrenEntirely: true
            )
        }

        let renderedChildren = children.map { $0.commit() }

        var position = Position.zero
        for (index, child) in renderedChildren.enumerated() {
            // Avoid the whole iteration if the child is hidden. If there
            // are weird positioning issues for views that do strange things
            // then this could be the cause.
            if !child.participatesInStackLayouts {
                continue
            }

            // Compute alignment
            switch alignment {
                case .leading:
                    position[component: perpendicularOrientation] = 0
                case .center:
                    let outer = size[component: perpendicularOrientation]
                    let inner = child.size[component: perpendicularOrientation]
                    position[component: perpendicularOrientation] = (outer - inner) / 2
                case .trailing:
                    let outer = size[component: perpendicularOrientation]
                    let inner = child.size[component: perpendicularOrientation]
                    position[component: perpendicularOrientation] = outer - inner
            }

            backend.setPosition(ofChildAt: index, in: container, to: position.vector)

            position[component: orientation] += child.size[component: orientation] + Double(spacing)
        }
    }

    /// The main stack layout space allocation algorithm. Used during
    /// computeLayout, and sometimes during commit when we have to redistribute
    /// space (due to an unspecified perpendicular size proposal).
    @MainActor
    static func computeLayouts(
        of children: [LayoutableChild],
        proposedLength: Double,
        proposedPerpendicular: Double?,
        cache: StackLayoutCache,
        environment: EnvironmentValues,
        ignoreHiddenChildrenEntirely: Bool
    ) -> [ViewLayoutResult] {
        var renderedChildren = [ViewLayoutResult](
            repeating: .leafView(size: .zero),
            count: children.count
        )

        let orientation = environment.layoutOrientation
        let perpendicularOrientation = orientation.perpendicular
        var spaceUsedAlongStackAxis = 0.0
        var reservedSpace = cache.totalReservedSpace
        for group in cache.priorityGroups {
            var childrenRemaining = group.children.count { index in
                !cache.isHidden[index]
            }

            for index in group.children {
                let child = children[index]

                // No need to render visible children.
                if cache.isHidden[index] {
                    if ignoreHiddenChildrenEntirely {
                        continue
                    }

                    // Update child in case it has just changed from visible to hidden,
                    // and to make sure that the view is still hidden (if it's not then
                    // it's a bug with either the view or the layout system).
                    let result = child.computeLayout(
                        proposedSize: .zero,
                        environment: environment
                    )
                    if result.participatesInStackLayouts {
                        logger.warning(
                            "hidden view became visible on second update; layout may break",
                            metadata: [
                                "view": "\(child.tag ?? "<unknown type>")"
                            ]
                        )
                    }
                    renderedChildren[index] = result
                    renderedChildren[index].participateInStackLayoutsWhenEmpty = false
                    renderedChildren[index].size = .zero
                    continue
                }

                reservedSpace -= cache.minimumLengths[index]

                var proposedChildSize = ProposedViewSize.unspecified
                proposedChildSize[component: orientation] = max(
                    proposedLength - spaceUsedAlongStackAxis - reservedSpace,
                    0
                ) / Double(childrenRemaining)
                proposedChildSize[component: perpendicularOrientation] = proposedPerpendicular

                let childResult = child.computeLayout(
                    proposedSize: proposedChildSize,
                    environment: environment
                )

                renderedChildren[index] = childResult
                childrenRemaining -= 1

                spaceUsedAlongStackAxis += childResult.size[component: orientation]
            }
        }

        return renderedChildren
    }
}
