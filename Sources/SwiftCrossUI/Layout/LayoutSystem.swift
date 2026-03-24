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
    static func computeStackLayout<Backend: AppBackend>(
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

        var renderedChildren: [ViewLayoutResult] = Array(
            repeating: ViewLayoutResult.leafView(size: .zero),
            count: children.count
        )

        // When the perpendicular axis is unspecified (nil), we need
        // to re-run the space distribution algorithm with our final size during
        // the commit phase. This opens the door to certain edge cases, but SwiftUI
        // has them too, and there's not a good general solution to these edge
        // cases, even if you assume that you have unlimited compute. The reason for
        // this distribution is so that flexible children get a chance to use up any
        // unused space within the final perpendicular size of the stack.
        cache.redistributeSpaceOnCommit =
            proposedSize[component: perpendicularOrientation] == nil

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

            // In this case, flexibility doesn't matter. We set the ordering to
            // nil to signal to commitStackLayout that it can ignore flexibility.
            cache.lastFlexibilityOrdering = nil
            cache.lastHiddenChildren = results.map(\.participatesInStackLayouts).map(!)

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

        // My thanks go to this great article for investigating and explaining
        // how SwiftUI determines child view 'flexibility':
        // https://www.objc.io/blog/2020/11/10/hstacks-child-ordering/
        var isHidden = [Bool](repeating: false, count: children.count)
        var minimumProposedSize = proposedSize
        minimumProposedSize[component: orientation] = 0
        var maximumProposedSize = proposedSize
        maximumProposedSize[component: orientation] = .infinity
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
            let maximum = maximumResult.size[component: orientation]
            let minimum = minimumResult.size[component: orientation]
            return maximum - minimum
        }
        let visibleChildrenCount = isHidden.filter { hidden in
            !hidden
        }.count
        let totalSpacing = Double(max(visibleChildrenCount - 1, 0) * spacing)
        let sortedChildren = zip(children.enumerated(), flexibilities)
            .sorted { first, second in
                first.1 <= second.1
            }
            .map(\.0)

        var spaceUsedAlongStackAxis: Double = 0
        var childrenRemaining = visibleChildrenCount
        for (index, child) in sortedChildren {
            // No need to render visible children.
            if isHidden[index] {
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

            var proposedChildSize = proposedSize
            proposedChildSize[component: orientation] =
                max(stackLength - spaceUsedAlongStackAxis - totalSpacing, 0)
                / Double(childrenRemaining)

            let childResult = child.computeLayout(
                proposedSize: proposedChildSize,
                environment: environment
            )

            renderedChildren[index] = childResult
            childrenRemaining -= 1

            spaceUsedAlongStackAxis += childResult.size[component: orientation]
        }

        var size = ViewSize.zero
        size[component: orientation] =
            renderedChildren.map(\.size[component: orientation]).reduce(0, +) + totalSpacing
        size[component: perpendicularOrientation] =
            renderedChildren.map(\.size[component: perpendicularOrientation]).max() ?? 0

        cache.lastFlexibilityOrdering = sortedChildren.map(\.offset)
        cache.lastHiddenChildren = isHidden

        return ViewLayoutResult(
            size: size,
            childResults: renderedChildren,
            participateInStackLayoutsWhenEmpty:
                renderedChildren.contains(where: \.participateInStackLayoutsWhenEmpty)
        )
    }

    @MainActor
    static func commitStackLayout<Backend: AppBackend>(
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
            let ordering: [Int]
            if let flexibilityOrdering = cache.lastFlexibilityOrdering {
                ordering = flexibilityOrdering
            } else {
                // The stacking axis was given an unspecified proposal,
                // rendering flexibility sorting unnecessary.
                ordering = Array(children.indices)
            }

            var spaceUsedAlongStackAxis: Double = 0
            // Avoid a trailing closure here because Swift 5.10 gets confused
            let visibleChildrenCount = cache.lastHiddenChildren.count { isHidden in
                !isHidden
            }
            let totalSpacing = Double(max(visibleChildrenCount - 1, 0) * spacing)
            var childrenRemaining = visibleChildrenCount

            // TODO: Reuse the corresponding loop from computeStackLayout if
            //   possible to avoid the possibility for a behaviour mismatch.
            for index in ordering {
                if cache.lastHiddenChildren[index] {
                    continue
                }

                var proposedChildSize = layout.size
                proposedChildSize[component: orientation] -= spaceUsedAlongStackAxis + totalSpacing
                proposedChildSize[component: orientation] /= Double(childrenRemaining)
                let result = children[index].computeLayout(
                    proposedSize: ProposedViewSize(proposedChildSize),
                    environment: environment
                )

                spaceUsedAlongStackAxis += result.size[component: orientation]
                childrenRemaining -= 1
            }
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
}
