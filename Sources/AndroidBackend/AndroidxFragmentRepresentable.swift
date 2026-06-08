import AndroidKit
import SwiftCrossUI
import SwiftJava

@MainActor
public struct AndroidxFragmentRepresentableContext<Representable: AndroidxFragmentRepresentable> {
    public let coordinator: Representable.Coordinator
    public internal(set) var environment: EnvironmentValues
}

public protocol AndroidxFragmentRepresentable: SwiftCrossUI.View where Content == Never {
    associatedtype FragmentType: AndroidxFragment
    associatedtype Coordinator = Void

    /// Make the coordinator for this fragment.
    ///
    /// The coordinator is used when the fragment needs to communicate changes to the rest of
    /// the view hierarchy (i.e. through bindings).
    @MainActor
    func makeCoordinator() -> Coordinator

    /// Create the initial `androidx.fragment.app.Fragment` instance.
    @MainActor
    func makeFragment(context: Self.Context) -> FragmentType

    /// Update the fragment with new values.
    /// - Parameters:
    ///   - fragment: The fragment to update.
    ///   - context: The context, including the coordinator and potentially new environment
    ///     values.
    /// - Note: This may be called even when `context` has not changed.
    @MainActor
    func updateFragment(
        _ fragment: FragmentType,
        context: Self.Context
    )

    /// Compute the fragment's preferred size.
    ///
    /// The default implementation uses `fragment.getView().measure(_:_:)` to determine the
    /// fragment's preferred size.
    /// - Parameters:
    ///   - proposal: The proposed size for the fragment.
    ///   - fragment: The fragment being queried for its preferred size.
    ///   - context: The context, including the coordinator and environment values.
    /// - Returns: The fragment's preferred size.
    @MainActor
    func sizeThatFits(
        _ proposal: ProposedViewSize,
        fragment: FragmentType,
        context: Self.Context
    ) -> ViewSize

    /// Called to clean up the fragment when it's removed.
    ///
    /// The default implementation does nothing.
    /// - Parameters:
    ///   - fragment: The fragment being dismantled.
    ///   - coordinator: The coordinator.
    static func dismantleFragment(
        _ fragment: FragmentType,
        coordinator: Coordinator
    )
}

// swiftlint:disable force_try
extension AndroidxFragmentRepresentable {
    public typealias Context = AndroidxFragmentRepresentableContext<Self>

    @MainActor
    public func sizeThatFits(
        _ proposal: ProposedViewSize,
        fragment: FragmentType,
        context: Self.Context
    ) -> ViewSize {
        guard let view = fragment.getView() else {
            // onCreateView has not been called yet. onStart will trigger a relayout, but for now,
            // return a placeholder value.
            return .zero
        }

        let density = context.environment.windowScaleFactor

        // 0x80000000 = View.MeasureSpec.AT_MOST
        // 0x3FFFFFFF = View.MeasureSpec.makeMeasureSpec(Int32.max, View.MeasureSpec.UNSPECIFIED)
        let widthMeasureSpec =
            if
                let proposedWidth = proposal.width,
                proposedWidth > 0
            {
                Int32(bitPattern: 0x80000000 | UInt32(min(proposedWidth * density, 0x3FFFFFFF)))
            } else {
                0x3FFFFFFF as Int32
            }

        let heightMeasureSpec =
            if
                let proposedHeight = proposal.height,
                proposedHeight > 0
            {
                Int32(bitPattern: 0x80000000 | UInt32(min(proposedHeight * density, 0x3FFFFFFF)))
            } else {
                0x3FFFFFFF as Int32
            }

        // For some reason, the measured size often prefers to return the current size over the
        // ideal size when given AT_MOST. Set the size to WRAP_CONTENT to suppress this effect.
        let layoutParamsClass = try! JavaClass<AndroidKit.ViewGroup.LayoutParams>()
        let layoutParams = view.getLayoutParams()!
        layoutParams.width = layoutParamsClass.WRAP_CONTENT
        layoutParams.height = layoutParamsClass.WRAP_CONTENT
        view.setLayoutParams(layoutParams)

        view.measure(widthMeasureSpec, heightMeasureSpec)

        let width = Double(view.getMeasuredWidth()) / density
        let height = Double(view.getMeasuredHeight()) / density

        return ViewSize(width, height)
    }

    public static func dismantleFragment(
        _ fragment: FragmentType,
        coordinator: Coordinator
    ) {
        // no-op
    }
}

extension AndroidxFragmentRepresentable where Coordinator == Void {
    public func makeCoordinator() {}
}

@JavaClass(
    "dev.swiftcrossui.androidbackend.FragmentRepresentingView",
    extends: AndroidKit.FrameLayout.self
)
class FragmentRepresentingView: AndroidKit.FrameLayout {
    @JavaMethod
    convenience init(
        _ activity: FragmentActivity?,
        environment: JNIEnvironment? = nil
    )

    @JavaMethod
    func getSwiftContext() -> SwiftObject?

    @JavaMethod
    func setSwiftContext(_ swiftContext: SwiftObject?)

    @JavaMethod
    func set(
        fragment: AndroidxFragment!,
        manager: AndroidxFragmentManager!,
        onStartListener: SwiftAction!,
        onDestroyListener: SwiftAction!
    )

    @JavaMethod
    func getFragment() -> AndroidxFragment?
}

extension FragmentRepresentingView {
    @MainActor
    func updateAndGetSize<T: AndroidxFragmentRepresentable>(
        environment: EnvironmentValues,
        proposedSize: ProposedViewSize,
        representable: T
    ) -> ViewSize {
        var context: T.Context
        if let untypedContext = getSwiftContext()?.value() {
            context = untypedContext as! T.Context
            context.environment = environment
        } else {
            context = AndroidxFragmentRepresentableContext(
                coordinator: representable.makeCoordinator(),
                environment: environment
            )
        }

        setSwiftContext(SwiftObject(context, environment: environment.jniEnv))

        let fragment: T.FragmentType
        if let untypedFragment = getFragment() {
            fragment = untypedFragment.as(T.FragmentType.self)!
        } else {
            fragment = representable.makeFragment(context: context)
            let fragmentActivity = environment.androidActivity.as(FragmentActivity.self)!

            let onStartListener = SwiftAction(environment: environment.jniEnv) {
                let context = self.getSwiftContext()!.value() as! T.Context
                context.environment.onResize(.zero)
            }

            let coordinator = context.coordinator
            let onDestroyListener = SwiftAction(environment: environment.jniEnv) {
                T.dismantleFragment(fragment, coordinator: coordinator)
            }

            set(
                fragment: fragment,
                manager: fragmentActivity.getSupportFragmentManager(),
                onStartListener: onStartListener,
                onDestroyListener: onDestroyListener
            )
        }

        representable.updateFragment(fragment, context: context)

        return representable.sizeThatFits(proposedSize, fragment: fragment, context: context)
    }
}

extension SwiftCrossUI.View where Self: AndroidxFragmentRepresentable {
    public var body: Never {
        preconditionFailure("This should never be called")
    }

    public func children<Backend: BaseAppBackend>(
        backend _: Backend,
        snapshots _: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment _: EnvironmentValues
    ) -> any ViewGraphNodeChildren {
        EmptyViewChildren()
    }

    public func layoutableChildren<Backend: BaseAppBackend>(
        backend _: Backend,
        children _: any ViewGraphNodeChildren
    ) -> [LayoutSystem.LayoutableChild] {
        []
    }

    public func asWidget<Backend: BaseAppBackend>(
        _: any ViewGraphNodeChildren,
        backend _: Backend
    ) -> Backend.Widget {
        if let widget = FragmentRepresentingView(
            AndroidBackend.activity.as(FragmentActivity.self)!,
            environment: AndroidBackend.env
        ) as? Backend.Widget {
            return widget
        } else {
            fatalError("AndroidxFragmentRepresentable requested by \(Backend.self)")
        }
    }

    public func computeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: any ViewGraphNodeChildren,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        let widget = (widget as! AndroidBackend.Widget).as(FragmentRepresentingView.self)!
        let size = widget.updateAndGetSize(
            environment: environment,
            proposedSize: proposedSize,
            representable: self
        )
        return ViewLayoutResult.leafView(size: size)
    }

    public func commit<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: any ViewGraphNodeChildren,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        backend.setSize(of: widget, to: layout.size.vector)
    }
}
