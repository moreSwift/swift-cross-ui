extension View {
    /// Controls the focusability of a view.
    /// Only affects out of the box interactable Views.
    ///
    /// Doesn't have an effect on UIKitBackend and WinUIBackend.
    public func focusable(_ focusability: Focusability = .unmodified) -> some View {
        FocusModifier(body: TupleView1(self), focusability: focusability)
    }

    /// Conditionally disables the focus indicator.
    public func focusEffectDisabled(_ disabled: Bool = true) -> some View {
        EnvironmentModifier(self) { environment in
            environment.with(\.focusEffectDisabled, disabled)
        }
    }

    /// Modifies this view by binding its focus state to the given state value.
    ///
    /// Supported by ``AppKitBackend``, ``GtkBackend`` and ``WinUIBackend``.
    ///
    /// Setting to `nil` on ``WinUIBackend`` causes the first focusable widget to gain focus
    /// due to WinUI not supporting setting an "unfocused" state.
    public func focused<Value: Hashable>(
        _ focusBinding: FocusState<Value?>.Binding,
        equals match: Value
    ) -> some View {
        EnvironmentModifier(self) { environment in
            environment.with(
                \.focusObservers,
                environment.focusObservers + [
                    FocusData(
                        type: Value.self,
                        match: match,
                        set: {
                            focusBinding.wrappedValue = match
                        },
                        reset: {
                            focusBinding.reset()
                        },
                        matches: focusBinding.wrappedValue == match,
                        shouldUnfocus: focusBinding.wrappedValue == nil
                    )
                ]
            )
        }
    }

    /// Modifies this view by binding its focus state to the given Boolean state value.
    ///
    /// Supported by ``AppKitBackend``, ``GtkBackend`` and ``WinUIBackend``.
    ///
    /// Setting to `false` on ``WinUIBackend`` causes the first focusable widget to gain focus
    /// due to WinUI not supporting setting an "unfocused" state.
    public func focused(
        _ focusBinding: FocusState<Bool>.Binding
    ) -> some View {
        EnvironmentModifier(self) { environment in
            environment.with(
                \.focusObservers,
                environment.focusObservers + [
                    FocusData(
                        type: Bool.self,
                        match: true,
                        set: {
                            focusBinding.wrappedValue = true
                        },
                        reset: {
                            focusBinding.reset()
                        },
                        matches: focusBinding.wrappedValue == true,
                        shouldUnfocus: focusBinding.wrappedValue == false
                    )
                ]
            )
        }
    }
}

struct FocusModifier<Content: View>: TypeSafeView {
    typealias Children = TupleView1<Content>.Children

    var body: TupleView1<Content>
    var focusability: Focusability

    func children<Backend: BaseAppBackend>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> Children {
        body.children(
            backend: backend,
            snapshots: snapshots,
            environment: environment
        )
    }

    @CastBackend<BackendFeatures.FocusDisabling>(backendGenericName: "NewBackend")
    func asWidget<Backend: BaseAppBackend>(
        _ children: Children,
        backend: Backend
    ) -> Backend.Widget {
        let container = backend.createFocusContainer()

        backend.insert(children.child0.widget.into(), into: container, at: 0)

        return container as! Backend.Widget
    }

    func computeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: Children,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        children.child0.computeLayout(
            with: body.view0,
            proposedSize: proposedSize,
            environment: environment
        )
        .with(\.shouldSetFocusData, true)
    }

    @CastBackend<BackendFeatures.FocusDisabling>(backendGenericName: "NewBackend")
    func commit<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: Children,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        let size = children.child0.commit().size.vector
        backend.setSize(of: widget, to: size)

        backend.updateFocusContainer(widget, focusability: focusability)
    }
}
