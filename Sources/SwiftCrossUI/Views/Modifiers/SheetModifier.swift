extension View {
    /// Presents a conditional modal overlay. `onDismiss` gets invoked when the sheet is dismissed.
    ///
    /// On most platforms sheets appear as form-style modals. On tvOS, sheets
    /// appear as full screen overlays (non-opaque).
    ///
    /// `onDismiss` isn't called when the sheet gets dismissed programmatically
    /// (i.e. by setting `isPresented` to `false`).
    ///
    /// `onDismiss` gets called *after* the sheet has been dismissed by the
    /// underlying UI framework, and *before* `isPresented` gets set to false.
    ///
    /// - Parameters:
    ///   - isPresented: A binding controlling whether the sheet is presented.
    ///   - onDismiss: An action to perform when the sheet is dismissed
    ///     by the user.
    public func sheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> SheetContent
    ) -> some View {
        SheetModifier(
            isPresented: isPresented,
            body: TupleView1(self),
            onDismiss: onDismiss,
            sheetContent: content
        )
    }
}

struct SheetModifier<Content: View, SheetContent: View>: TypeSafeView {
    typealias Children = SheetModifierViewChildren<Content, SheetContent>

    var isPresented: Binding<Bool>
    var body: TupleView1<Content>
    var onDismiss: (() -> Void)?
    var sheetContent: () -> SheetContent

    var sheet: Any?

    func children<Backend: AppBackend>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> Children {
        let bodyViewGraphNode = ViewGraphNode(
            for: body.view0,
            backend: backend,
            environment: environment
        )
        let bodyNode = AnyViewGraphNode(bodyViewGraphNode)

        return SheetModifierViewChildren(
            childNode: bodyNode,
            sheetContentNode: nil,
            sheet: nil
        )
    }

    func asWidget<Backend: AppBackend>(
        _ children: Children,
        backend: Backend
    ) -> Backend.Widget {
        children.childNode.widget.into()
    }

    func computeLayout<Backend: AppBackend>(
        _ widget: Backend.Widget,
        children: Children,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        children.childNode.computeLayout(
            with: body.view0,
            proposedSize: proposedSize,
            environment: environment
        )
    }

    func commit<Backend: AppBackend>(
        _ widget: Backend.Widget,
        children: Children,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        _ = children.childNode.commit()

        if isPresented.wrappedValue && children.sheet == nil {
            let sheetViewGraphNode = ViewGraphNode(
                for: sheetContent(),
                backend: backend,
                environment: environment
            )
            let sheetContentNode = AnyViewGraphNode(sheetViewGraphNode)
            children.sheetContentNode = sheetContentNode

            let sheet = backend.createSheet(
                content: children.sheetContentNode!.widget.into()
            )

            let dismissAction = DismissAction(action: { [isPresented] in
                isPresented.wrappedValue = false
            })

            let sheetEnvironment =
                environment
                .with(\.dismiss, dismissAction)
                .with(\.sheet, sheet)

            _ = children.sheetContentNode!.computeLayout(
                with: sheetContent(),
                proposedSize: .unspecified,
                environment: sheetEnvironment
            )
            let result = children.sheetContentNode!.commit()

            let window = environment.window! as! Backend.Window
            let preferences = result.preferences
            backend.updateSheet(
                sheet,
                window: window,
                // We intentionally use the outer environment rather than
                // sheetEnvironment here, because this is meant to be the sheet's
                // environment, not that of its content.
                environment: environment,
                size: result.size.vector,
                onDismiss: { handleDismiss(children: children) },
                cornerRadius: preferences.presentationCornerRadius,
                detents: preferences.presentationDetents ?? [],
                dragIndicatorVisibility:
                    preferences.presentationDragIndicatorVisibility ?? .automatic,
                backgroundColor: preferences.presentationBackground?.resolve(in: environment),
                interactiveDismissDisabled: preferences.interactiveDismissDisabled ?? false
            )

            let parentSheet = environment.sheet.map { $0 as! Backend.Sheet }
            backend.presentSheet(
                sheet,
                window: window,
                parentSheet: parentSheet
            )
            children.sheet = sheet
            children.window = window
            children.parentSheet = parentSheet
        } else if !isPresented.wrappedValue && children.sheet != nil {
            backend.dismissSheet(
                children.sheet as! Backend.Sheet,
                window: children.window! as! Backend.Window,
                parentSheet: children.parentSheet.map { $0 as! Backend.Sheet }
            )
            children.sheet = nil
            children.window = nil
            children.parentSheet = nil
            children.sheetContentNode = nil
        }
    }

    func handleDismiss(children: Children) {
        onDismiss?()
        children.sheet = nil
        children.window = nil
        children.parentSheet = nil
        children.sheetContentNode = nil
        isPresented.wrappedValue = false
    }
}

class SheetModifierViewChildren<Child: View, SheetContent: View>: ViewGraphNodeChildren {
    var widgets: [AnyWidget] {
        [childNode.widget]
    }

    var erasedNodes: [ErasedViewGraphNode] {
        var nodes: [ErasedViewGraphNode] = [ErasedViewGraphNode(wrapping: childNode)]
        if let sheetContentNode {
            nodes.append(ErasedViewGraphNode(wrapping: sheetContentNode))
        }
        return nodes
    }

    var childNode: AnyViewGraphNode<Child>
    var sheetContentNode: AnyViewGraphNode<SheetContent>?
    var sheet: Any?
    var window: Any?
    var parentSheet: Any?

    init(
        childNode: AnyViewGraphNode<Child>,
        sheetContentNode: AnyViewGraphNode<SheetContent>?,
        sheet: Any?
    ) {
        self.childNode = childNode
        self.sheetContentNode = sheetContentNode
        self.sheet = sheet
    }
}
