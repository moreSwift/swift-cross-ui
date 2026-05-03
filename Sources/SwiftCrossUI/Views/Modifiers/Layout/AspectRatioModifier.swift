extension View {
    /// Modifies size proposals to match the specified aspect ratio, or the
    /// view's ideal aspect ratio if unspecified.
    ///
    /// This modifier doesn't guarantee that the view's size will maintain a
    /// constant aspect ratio, as it only changes the size proposed to the
    /// wrapped content.
    ///
    /// - Parameters:
    ///   - aspectRatio: The aspect ratio to maintain. Use `nil` to
    ///     maintain the view's ideal aspect ratio.
    ///   - contentMode: How the view should fill available space.
    /// - Returns: A view with its aspect ratio configured.
    public func aspectRatio(_ aspectRatio: Double? = nil, contentMode: ContentMode) -> some View {
        AspectRatioView(self, aspectRatio: aspectRatio, contentMode: contentMode)
    }

    /// Modifies size proposals to match the aspect ratio of the provided size.
    ///
    /// This modifier doesn't guarantee that the view's size will maintain a
    /// constant aspect ratio, as it only changes the size proposed to the
    /// wrapped content.
    ///
    /// - Parameters:
    ///   - aspectRatio: The aspect ratio to maintain, specified as a
    ///     size with the desired aspect ratio.
    ///   - contentMode: How the view should fill available space.
    /// - Returns: A view with its aspect ratio configured.
    public func aspectRatio(_ aspectRatio: SIMD2<Double>, contentMode: ContentMode) -> some View {
        AspectRatioView(
            self,
            aspectRatio: LayoutSystem.aspectRatio(of: aspectRatio),
            contentMode: contentMode
        )
    }
}

struct AspectRatioView<Child: View>: TypeSafeView {
    var body: TupleView1<Child>

    var aspectRatio: Double?
    var contentMode: ContentMode

    init(_ child: Child, aspectRatio: Double?, contentMode: ContentMode) {
        body = TupleView1(child)
        self.aspectRatio = aspectRatio
        self.contentMode = contentMode
    }

    func children<Backend: BaseAppBackend>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> TupleViewChildren1<Child> {
        body.children(backend: backend, snapshots: snapshots, environment: environment)
    }

    func asWidget<Backend: BaseAppBackend>(
        _ children: TupleViewChildren1<Child>,
        backend: Backend
    ) -> Backend.Widget {
        children.child0.widget.into()
    }

    func computeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: TupleViewChildren1<Child>,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        // We lazily compute the aspect ratio because we don't always need it.
        // For example, when both dimensions are specified we pass them unmodified.
        func computeAspectRatio() -> Double {
            if let aspectRatio {
                return aspectRatio == 0 ? 1 : aspectRatio
            } else {
                let childResult = children.child0.computeLayout(
                    with: body.view0,
                    proposedSize: .unspecified,
                    environment: environment
                )
                return LayoutSystem.aspectRatio(of: childResult.size)
            }
        }

        let proposedFrameSize: ProposedViewSize
        switch (proposedSize.width, proposedSize.height) {
            case (.some(let width), .some(let height)):
                let evaluatedAspectRatio = computeAspectRatio()
                let widthForHeight = LayoutSystem.width(
                    forHeight: height,
                    aspectRatio: evaluatedAspectRatio
                )
                let heightForWidth = LayoutSystem.height(
                    forWidth: width,
                    aspectRatio: evaluatedAspectRatio
                )
                switch contentMode {
                    case .fill:
                        proposedFrameSize = ProposedViewSize(
                            max(width, widthForHeight),
                            max(height, heightForWidth)
                        )
                    case .fit:
                        proposedFrameSize = ProposedViewSize(
                            min(width, widthForHeight),
                            min(height, heightForWidth)
                        )
                }
            case (.some(let width), .none):
                proposedFrameSize = ProposedViewSize(
                    width,
                    LayoutSystem.height(forWidth: width, aspectRatio: computeAspectRatio())
                )
            case (.none, .some(let height)):
                proposedFrameSize = ProposedViewSize(
                    LayoutSystem.width(forHeight: height, aspectRatio: computeAspectRatio()),
                    height
                )
            case (.none, .none):
                proposedFrameSize = .unspecified
        }

        return children.child0.computeLayout(
            with: body.view0,
            proposedSize: proposedFrameSize,
            environment: environment
        )
    }

    func commit<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: TupleViewChildren1<Child>,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        _ = children.child0.commit()
    }
}
