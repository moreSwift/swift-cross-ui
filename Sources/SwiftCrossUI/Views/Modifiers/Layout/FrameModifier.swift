extension View {
    /// Positions this view within an invisible frame having the specified
    /// minimum size constraints.
    ///
    /// - Parameters:
    ///   - width: The frame's exact width. `nil` lets the view choose its own
    ///     width instead.
    ///   - height: The frame's exact height. `nil` lets the view choose its own
    ///     height instead.
    ///   - alignment: How to align the view within its container.
    @available(*, deprecated, renamed: "frame(width:height:alignment:)")
    @_disfavoredOverload
    public func frame(
        width: Int? = nil,
        height: Int? = nil,
        alignment: Alignment = .center
    ) -> some View {
        return frame(
            width: width.map(Double.init),
            height: height.map(Double.init),
            alignment: alignment
        )
    }

    public func frame(
        width: Double? = nil,
        height: Double? = nil,
        alignment: Alignment = .center
    ) -> some View {
        return StrictFrameView(
            self,
            width: width,
            height: height,
            alignment: alignment
        )
    }

    /// Positions this view within an invisible frame having the specified
    /// minimum size constraints.
    ///
    /// - Parameters:
    ///   - minWidth: The frame's minimum width. `nil` means the frame inherits
    ///     the minimum width of its content
    ///   - idealWidth: The frame's ideal width. `nil` lets the frame choose its
    ///     own ideal width instead.
    ///   - maxWidth: The frame's maximum width. `nil` means the frame inherits
    ///     the maximum width of its content
    ///   - minHeight: The frame's minimum height. `nil` means the frame inherits
    ///     the minimum height of its content
    ///   - idealHeight: The frame's ideal height. `nil` lets the frame choose its
    ///     own ideal height instead.
    ///   - maxHeight: The frame's maximum height. `nil` means the frame inherits
    ///     the maximum height of its content
    ///   - alignment: How to align the view within its container.
    @available(*, deprecated, renamed: "frame(minWidth:idealWidth:maxWidth:minHeight:idealHeight:maxHeight:alignment:)")
    @_disfavoredOverload
    public func frame(
        minWidth: Int? = nil,
        idealWidth: Int? = nil,
        maxWidth: Double? = nil,
        minHeight: Int? = nil,
        idealHeight: Int? = nil,
        maxHeight: Double? = nil,
        alignment: Alignment = .center
    ) -> some View {
        return frame(
            minWidth: minWidth.map(Double.init),
            idealWidth: idealWidth.map(Double.init),
            maxWidth: maxWidth,
            minHeight: minHeight.map(Double.init),
            idealHeight: idealHeight.map(Double.init),
            maxHeight: maxHeight,
            alignment: alignment
        )
    }

    public func frame(
        minWidth: Double? = nil,
        idealWidth: Double? = nil,
        maxWidth: Double? = nil,
        minHeight: Double? = nil,
        idealHeight: Double? = nil,
        maxHeight: Double? = nil,
        alignment: Alignment = .center
    ) -> some View {
        return FlexibleFrameView(
            self,
            minWidth: minWidth,
            idealWidth: idealWidth,
            maxWidth: maxWidth,
            minHeight: minHeight,
            idealHeight: idealHeight,
            maxHeight: maxHeight,
            alignment: alignment
        )
    }
}

/// The implementation for the ``View/frame(width:height:)`` view modifier.
struct StrictFrameView<Child: View>: TypeSafeView {
    var body: TupleView1<Child>

    /// The exact width to make the view.
    var width: Double?
    /// The exact height to make the view.
    var height: Double?
    /// The alignment of the child within the frame.
    var alignment: Alignment

    /// Wraps a child view with size constraints.
    init(_ child: Child, width: Double?, height: Double?, alignment: Alignment) {
        body = TupleView1(child)
        self.width = width
        self.height = height
        self.alignment = alignment
    }

    func children<Backend: AppBackend>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> TupleViewChildren1<Child> {
        body.children(backend: backend, snapshots: snapshots, environment: environment)
    }

    func asWidget<Backend: AppBackend>(
        _ children: TupleViewChildren1<Child>,
        backend: Backend
    ) -> Backend.Widget {
        let container = backend.createContainer()
        backend.insert(children.child0.widget.into(), into: container, at: 0)
        return container
    }

    func computeLayout<Backend: AppBackend>(
        _ widget: Backend.Widget,
        children: TupleViewChildren1<Child>,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        let width = width
        let height = height

        let childResult = children.child0.computeLayout(
            with: body.view0,
            proposedSize: ProposedViewSize(
                width ?? proposedSize.width,
                height ?? proposedSize.height
            ),
            environment: environment
        )
        let childSize = childResult.size

        let frameSize = ViewSize(
            width ?? childSize.width,
            height ?? childSize.height
        )

        return ViewLayoutResult(
            size: frameSize,
            childResults: [childResult]
        )
    }

    func commit<Backend: AppBackend>(
        _ widget: Backend.Widget,
        children: TupleViewChildren1<Child>,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        let frameSize = layout.size
        let childSize = children.child0.commit().size

        let childPosition = alignment.position(
            ofChild: childSize.vector,
            in: frameSize.vector
        )
        backend.setSize(of: widget, to: frameSize.vector)
        backend.setPosition(ofChildAt: 0, in: widget, to: childPosition)
    }
}

/// The implementation for the ``View/frame(width:height:)`` view modifier.
struct FlexibleFrameView<Child: View>: TypeSafeView {
    var body: TupleView1<Child>

    var minWidth: Double?
    var idealWidth: Double?
    var maxWidth: Double?
    var minHeight: Double?
    var idealHeight: Double?
    var maxHeight: Double?
    /// The alignment of the child within the frame.
    var alignment: Alignment

    /// Wraps a child view with size constraints.
    init(
        _ child: Child,
        minWidth: Double?,
        idealWidth: Double?,
        maxWidth: Double?,
        minHeight: Double?,
        idealHeight: Double?,
        maxHeight: Double?,
        alignment: Alignment
    ) {
        self.body = TupleView1(child)
        self.minWidth = minWidth
        self.minHeight = minHeight
        self.idealWidth = idealWidth
        self.idealHeight = idealHeight
        self.maxWidth = maxWidth
        self.maxHeight = maxHeight
        self.alignment = alignment
    }

    func children<Backend: AppBackend>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> TupleViewChildren1<Child> {
        body.children(backend: backend, snapshots: snapshots, environment: environment)
    }

    func asWidget<Backend: AppBackend>(
        _ children: TupleViewChildren1<Child>,
        backend: Backend
    ) -> Backend.Widget {
        let container = backend.createContainer()
        backend.insert(children.child0.widget.into(), into: container, at: 0)
        return container
    }

    func clampSize(_ size: ViewSize) -> ViewSize {
        var size = size
        size.width = clampWidth(size.width)
        size.height = clampHeight(size.height)
        return size
    }

    func clampHeight(_ height: Double) -> Double {
        LayoutSystem.clamp(
            height,
            minimum: minHeight,
            maximum: maxHeight
        )
    }

    func clampWidth(_ width: Double) -> Double {
        LayoutSystem.clamp(
            width,
            minimum: minWidth,
            maximum: maxWidth
        )
    }

    func computeLayout<Backend: AppBackend>(
        _ widget: Backend.Widget,
        children: TupleViewChildren1<Child>,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        var proposedFrameSize = proposedSize

        if let proposedWidth = proposedSize.width {
            proposedFrameSize.width = clampWidth(proposedWidth)
        }

        if let proposedHeight = proposedSize.height {
            proposedFrameSize.height = clampHeight(proposedHeight)
        }

        if let idealWidth, proposedSize.width == nil {
            proposedFrameSize.width = idealWidth
        }

        if let idealHeight, proposedSize.height == nil {
            proposedFrameSize.height = idealHeight
        }

        let childResult = children.child0.computeLayout(
            with: body.view0,
            proposedSize: proposedFrameSize,
            environment: environment
        )
        let childSize = childResult.size

        var frameSize = clampSize(childSize)
        if maxWidth == .infinity, let proposedWidth = proposedSize.width {
            frameSize.width = max(frameSize.width, proposedWidth)
        }

        if maxHeight == .infinity, let proposedHeight = proposedSize.height {
            frameSize.height = max(frameSize.height, proposedHeight)
        }

        return ViewLayoutResult(
            size: frameSize,
            childResults: [childResult]
        )
    }

    func commit<Backend: AppBackend>(
        _ widget: Backend.Widget,
        children: TupleViewChildren1<Child>,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        let frameSize = layout.size

        // If the child view has at least one unspecified axis which this frame
        // is constraining with a minimum or maximum, then compute its
        // layout again with the clamped frame size. This allows the view to
        // fill the space that the frame is going to take up anyway. E.g. consider,
        //
        // ScrollView {
        //     Color.blue
        //         .frame(minHeight: 100)
        // }
        //
        // Without this second layout computation, the blue rectangle would
        // take on its ideal size of 10 within a frame of height 100, instead
        // of using up the min height of the frame as developers may expect.
        //
        // This doesn't apply to unconstrained axes which we have a corresponding
        // ideal length for.
        let widthConstrained = minWidth != nil || maxWidth != nil
        let heightConstrained = minHeight != nil || maxHeight != nil
        let proposedFrameSize = children.child0.lastProposedSize
        if (proposedFrameSize.width == nil && widthConstrained)
            || (proposedFrameSize.height == nil && heightConstrained)
        {
            _ = children.child0.computeLayout(
                with: nil,
                proposedSize: ProposedViewSize(frameSize),
                environment: environment
            )
        }

        let childSize = children.child0.commit().size

        let childPosition = alignment.position(
            ofChild: childSize.vector,
            in: frameSize.vector
        )
        backend.setSize(of: widget, to: frameSize.vector)
        backend.setPosition(ofChildAt: 0, in: widget, to: childPosition)
    }
}
