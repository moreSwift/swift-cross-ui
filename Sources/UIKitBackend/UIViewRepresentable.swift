import SwiftCrossUI
import UIKit

/// The context associated with an instance of ``Representable``.
@MainActor
public struct UIViewRepresentableContext<Representable: UIViewRepresentable> {
    public let coordinator: Representable.Coordinator
    public internal(set) var environment: EnvironmentValues
}

/// A wrapper that you use to integrate a UIKit view into your SwiftCrossUI
/// view hierarchy.
public protocol UIViewRepresentable: View where Content == Never {
    associatedtype UIViewType: UIView
    associatedtype Coordinator = Void

    /// Create the initial UIView instance.
    @MainActor
    func makeUIView(context: Context) -> UIViewType

    /// Update the view with new values.
    /// - Parameters:
    ///   - uiView: The view to update.
    ///   - context: The context, including the coordinator and potentially new environment
    ///   values.
    /// - Note: This may be called even when `context` has not changed.
    @MainActor
    func updateUIView(_ uiView: UIViewType, context: Context)

    /// Make the coordinator for this view.
    ///
    /// The coordinator is used when the view needs to communicate changes to the rest of
    /// the view hierarchy (i.e. through bindings), and is often the view's delegate.
    @MainActor
    func makeCoordinator() -> Coordinator

    /// Compute the view's preferred size.
    ///
    /// The default implementation uses `uiView.intrinsicContentSize` and
    /// `uiView.systemLayoutSizeFitting(_:)` to determine the view's
    /// preferred size.
    /// - Parameters:
    ///   - proposal: The proposed size for the view.
    ///   - uiView: The view being queried for its preferred size.
    ///   - context: The context, including the coordinator and environment values.
    /// - Returns: The view's preferred size.
    @MainActor
    func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiView: UIViewType,
        context: Context
    ) -> ViewSize

    /// Called to clean up the view when it's removed.
    /// - Parameters:
    ///   - uiView: The view being dismantled.
    ///   - coordinator: The coordinator.
    ///
    /// This method is called after all UIKit lifecycle methods, such as
    /// `uiView.didMoveToWindow()`.
    ///
    /// The default implementation does nothing.
    static func dismantleUIView(_ uiView: UIViewType, coordinator: Coordinator)
}

extension UIViewRepresentable {
    /// Context associated with the representable view.
    public typealias Context = UIViewRepresentableContext<Self>
}

// Used both here and by UIViewControllerRepresentable
func defaultViewSize(proposal: ProposedViewSize, view: UIView) -> ViewSize {
    let intrinsicSize = view.intrinsicContentSize

    let growsHorizontally = view.contentHuggingPriority(for: .horizontal) < .defaultHigh
    let growsVertically = view.contentHuggingPriority(for: .vertical) < .defaultHigh

    let idealWidth =
        intrinsicSize.width == UIView.noIntrinsicMetric
        ? 10 : intrinsicSize.width
    let idealHeight =
        intrinsicSize.height == UIView.noIntrinsicMetric
        ? 10 : intrinsicSize.height

    // When the view doesn't grow along a dimension, we use its fittingSize
    // (rather than its intrinsicContentSize), because the intrinsicContentSize
    // of some views (such as NSButton) are too small. In NSButton's case, the
    // intrinsicContentSize doesn't include padding.
    return ViewSize(
        growsHorizontally
            ? (proposal.width ?? idealWidth)
            : idealWidth,
        growsVertically
            ? (proposal.height ?? idealHeight)
            : idealHeight
    )
}

extension UIViewRepresentable {
    public static func dismantleUIView(_: UIViewType, coordinator _: Coordinator) {
        // no-op
    }

    public func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiView: UIViewType,
        context _: Context
    ) -> ViewSize {
        defaultViewSize(proposal: proposal, view: uiView)
    }
}

extension View where Self: UIViewRepresentable {
    public var body: Never {
        preconditionFailure("This should never be called")
    }

    public func children<Backend: AppBackend>(
        backend _: Backend,
        snapshots _: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment _: EnvironmentValues
    ) -> any ViewGraphNodeChildren {
        EmptyViewChildren()
    }

    public func layoutableChildren<Backend: AppBackend>(
        backend _: Backend,
        children _: any ViewGraphNodeChildren
    ) -> [LayoutSystem.LayoutableChild] {
        []
    }

    public func asWidget<Backend: AppBackend>(
        _: any ViewGraphNodeChildren,
        backend _: Backend
    ) -> Backend.Widget {
        if let widget = ViewRepresentingWidget(representable: self) as? Backend.Widget {
            return widget
        } else {
            fatalError("UIViewRepresentable requested by \(Backend.self)")
        }
    }

    public func computeLayout<Backend: AppBackend>(
        _ widget: Backend.Widget,
        children _: any ViewGraphNodeChildren,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend _: Backend
    ) -> ViewLayoutResult {
        let representingWidget = widget as! ViewRepresentingWidget<Self>
        representingWidget.update(with: environment)

        let size = representingWidget.representable.sizeThatFits(
            proposedSize,
            uiView: representingWidget.subview,
            context: representingWidget.context!
        )

        return ViewLayoutResult.leafView(size: size)
    }

    public func commit<Backend: AppBackend>(
        _ widget: Backend.Widget,
        children: any ViewGraphNodeChildren,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        let representingWidget = widget as! ViewRepresentingWidget<Self>
        representingWidget.width = layout.size.vector.x
        representingWidget.height = layout.size.vector.y
    }
}

extension UIViewRepresentable where Coordinator == Void {
    public func makeCoordinator() {
        return ()
    }
}

final class ViewRepresentingWidget<Representable: UIViewRepresentable>: BaseViewWidget {
    var representable: Representable
    var context: Representable.Context?
    var subviewConstraints: [NSLayoutConstraint] = []

    var cachedSubview: Representable.UIViewType?

    var subview: Representable.UIViewType {
        if let cachedSubview {
            return cachedSubview
        } else {
            let view = representable.makeUIView(context: context!)

            self.addSubview(view)

            view.translatesAutoresizingMaskIntoConstraints = false
            subviewConstraints = [
                view.topAnchor.constraint(equalTo: self.topAnchor),
                view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            ]
            NSLayoutConstraint.activate(subviewConstraints)

            cachedSubview = view
            return view
        }
    }

    func update(with environment: EnvironmentValues) {
        if var context {
            context.environment = environment
            representable.updateUIView(subview, context: context)
            self.context = context
        } else {
            let context = Representable.Context(
                coordinator: representable.makeCoordinator(),
                environment: environment
            )
            self.context = context
            representable.updateUIView(subview, context: context)
        }
    }

    init(representable: Representable) {
        self.representable = representable
        super.init()
    }

    deinit {
        if let context, let cachedSubview {
            Task { @MainActor in
                Representable.dismantleUIView(cachedSubview, coordinator: context.coordinator)
            }
        }
    }
}
