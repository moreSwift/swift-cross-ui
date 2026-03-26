/// A flexible space that expands along the major axis of its containing
/// stack layout, or on both axes if not contained in a stack.
public struct Spacer: ElementaryView, View {
    /// The ideal length of a spacer.
    static let idealLength: Double = 8

    /// The minimum length this spacer can be shrunk to, along the axis of
    /// expansion.
    package var minLength: Int?

    /// Creates a spacer with a given minimum length along its axis or axes
    /// of expansion.
    ///
    /// - Parameter minLength: The spacer's minimum length.
    public init(minLength: Int? = nil) {
        self.minLength = minLength
    }

    func asWidget<Backend: AppBackend>(backend: Backend) -> Backend.Widget {
        return backend.createContainer()
    }

    func computeLayout<Backend: AppBackend>(
        _ widget: Backend.Widget,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        var size = ViewSize.zero
        let proposedLength = proposedSize[component: environment.layoutOrientation]
        size[component: environment.layoutOrientation] = max(
            Double(minLength ?? 0),
            proposedLength ?? Self.idealLength
        )

        return ViewLayoutResult(
            size: size,
            participateInStackLayoutsWhenEmpty: true,
            preferences: PreferenceValues.default
                .with(\.layoutPriority, -Double.infinity)
        )
    }

    func commit<Backend: AppBackend>(
        _ widget: Backend.Widget,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        // Spacers are invisible so we don't have to update anything.
    }
}
