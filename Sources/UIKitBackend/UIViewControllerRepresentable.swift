import SwiftCrossUI
import UIKit

/// The context associated with an instance of ``Representable``.
@MainActor
public struct UIViewControllerRepresentableContext<
    Representable: UIViewControllerRepresentable
> {
    public let coordinator: Representable.Coordinator
    public internal(set) var environment: EnvironmentValues
}

/// A wrapper that you use to integrate a UIKit view controller into your
/// SwiftCrossUI view hierarchy.
public protocol UIViewControllerRepresentable: View where Content == Never {
    associatedtype UIViewControllerType: UIViewController
    associatedtype Coordinator = Void

    /// Create the initial UIViewController instance.
    @MainActor
    func makeUIViewController(context: Context) -> UIViewControllerType

    /// Update the view with new values.
    /// - Note: This may be called even when `context` has not changed.
    /// - Parameters:
    ///   - uiViewController: The controller to update.
    ///   - context: The context, including the coordinator and environment values.
    @MainActor
    func updateUIViewController(
        _ uiViewController: UIViewControllerType,
        context: Context
    )

    /// Make the coordinator for this controller.
    ///
    /// The coordinator is used when the controller needs to communicate changes to the rest of
    /// the view hierarchy (i.e. through bindings).
    @MainActor
    func makeCoordinator() -> Coordinator

    /// Compute the controller's view's preferred size for the given proposal.
    ///
    /// The default implementation uses `uiViewController.view.intrinsicContentSize` and
    /// `uiViewController.view.systemLayoutSizeFitting(_:)` to determine the view's
    /// preferred size.
    /// - Parameters:
    ///   - proposal: The proposed size for the view.
    ///   - uiViewController: The controller being queried for its view's preferred size.
    ///   - context: The context, including the coordinator and environment values.
    /// - Returns: The view's preferred size.
    @MainActor
    func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiViewController: UIViewControllerType,
        context: Context
    ) -> ViewSize

    /// Called to clean up the view when it's removed.
    ///
    /// The default implementation does nothing.
    /// - Parameters:
    ///   - uiViewController: The controller being dismantled.
    ///   - coordinator: The coordinator.
    static func dismantleUIViewController(
        _ uiViewController: UIViewControllerType,
        coordinator: Coordinator
    )
}

extension UIViewControllerRepresentable {
    /// Context associated with the representable controller.
    public typealias Context = UIViewControllerRepresentableContext<Self>
}

extension UIViewControllerRepresentable {
    public static func dismantleUIViewController(
        _: UIViewControllerType,
        coordinator _: Coordinator
    ) {
        // no-op
    }

    public func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiViewController: UIViewControllerType,
        context: Context
    ) -> ViewSize {
        defaultViewSize(proposal: proposal, view: uiViewController.view)
    }
}

extension View where Self: UIViewControllerRepresentable {
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
        if let widget = ControllerRepresentingWidget(representable: self) as? Backend.Widget {
            return widget
        } else {
            fatalError("UIViewControllerRepresentable requested by \(Backend.self)")
        }
    }

    public func computeLayout<Backend: AppBackend>(
        _ widget: Backend.Widget,
        children _: any ViewGraphNodeChildren,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend _: Backend
    ) -> ViewLayoutResult {
        let representingWidget = widget as! ControllerRepresentingWidget<Self>
        representingWidget.update(with: environment)

        let size = representingWidget.representable.sizeThatFits(
            proposedSize,
            uiViewController: representingWidget.subcontroller,
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
        let representingWidget = widget as! ControllerRepresentingWidget<Self>
        representingWidget.width = layout.size.vector.x
        representingWidget.height = layout.size.vector.y
    }
}

extension UIViewControllerRepresentable where Coordinator == Void {
    public func makeCoordinator() {
        return ()
    }
}

final class ControllerRepresentingWidget<
    Representable: UIViewControllerRepresentable
>: BaseControllerWidget {
    var representable: Representable
    var context: Representable.Context?

    var _subcontroller: Representable.UIViewControllerType?

    var subcontroller: Representable.UIViewControllerType {
        if let _subcontroller {
            return _subcontroller
        } else {
            let subcontroller = representable.makeUIViewController(context: context!)

            view.addSubview(subcontroller.view)
            addChild(subcontroller)

            subcontroller.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                subcontroller.view.topAnchor.constraint(equalTo: view.topAnchor),
                subcontroller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                subcontroller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                subcontroller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])

            subcontroller.didMove(toParent: self)

            _subcontroller = subcontroller
            return subcontroller
        }
    }

    func update(with environment: EnvironmentValues) {
        if context == nil {
            context = Representable.Context(
                coordinator: representable.makeCoordinator(),
                environment: environment
            )
        } else {
            context!.environment = environment
            representable.updateUIViewController(subcontroller, context: context!)
        }
    }

    init(representable: Representable) {
        self.representable = representable
        super.init()
    }

    deinit {
        if let context, let _subcontroller {
            Task { @MainActor in
                Representable.dismantleUIViewController(
                    _subcontroller,
                    coordinator: context.coordinator
                )
            }
        }
    }
}
