/// A flexible space that expands along the major axis of its containing
/// stack layout, or on both axes if not contained in a stack.
public struct Spacer: ElementaryView, View {
    /// The minimum length this spacer can be shrunk to, along the axis of
    /// expansion.
    public var minLength: Int?

    /// Creates a spacer with a given minimum length along its axis or axes
    /// of expansion.
    public init(minLength: Int? = nil) {
        self.minLength = minLength
    }

    public func asWidget<Backend: AppBackend>(
        backend: Backend
    ) -> Backend.Widget {
        return backend.createContainer()
    }

    public func update<Backend: AppBackend>(
        _ widget: Backend.Widget,
        proposedSize: SIMD2<Int>,
        environment: EnvironmentValues,
        backend: Backend,
        dryRun: Bool
    ) -> ViewUpdateResult {
        let minLength = minLength ?? 0

        let size: SIMD2<Int>
        let minimumWidth: Int
        let minimumHeight: Int
        let maximumWidth: Double?
        let maximumHeight: Double?
        switch environment.layoutOrientation {
            case .horizontal:
                size = SIMD2(max(minLength, proposedSize.x), 0)
                minimumWidth = minLength
                minimumHeight = 0
                maximumWidth = nil
                maximumHeight = 0
            case .vertical:
                size = SIMD2(0, max(minLength, proposedSize.y))
                minimumWidth = 0
                minimumHeight = minLength
                maximumWidth = 0
                maximumHeight = nil
        }

        if !dryRun {
            backend.setSize(of: widget, to: size)
        }
        return ViewUpdateResult.leafView(
            size: ViewSize(
                size: size,
                idealSize: SIMD2(minimumWidth, minimumHeight),
                minimumWidth: minimumWidth,
                minimumHeight: minimumHeight,
                maximumWidth: maximumWidth,
                maximumHeight: maximumHeight
            )
        )
    }
}
