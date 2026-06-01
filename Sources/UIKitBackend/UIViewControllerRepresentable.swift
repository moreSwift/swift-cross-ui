import SwiftCrossUI
import UIKit
import UIKitCompatKit

public struct UIViewControllerRepresentableContext<Coordinator> {
    public let coordinator: Coordinator
    public internal(set) var environment: EnvironmentValues
}

public protocol UIViewControllerRepresentable: View
where Content == Never {
    associatedtype UIViewControllerType: UIViewController
    associatedtype Coordinator = Void

    /// Create the initial UIViewController instance.
    func makeUIViewController(context: UIViewControllerRepresentableContext<Coordinator>)
        -> UIViewControllerType

    /// Update the view with new values.
    /// - Note: This may be called even when `context` has not changed.
    /// - Parameters:
    ///   - uiViewController: The controller to update.
    ///   - context: The context, including the coordinator and potentially new environment
    ///   values.
    func updateUIViewController(
        _ uiViewController: UIViewControllerType,
        context: UIViewControllerRepresentableContext<Coordinator>)

    /// Make the coordinator for this controller.
    ///
    /// The coordinator is used when the controller needs to communicate changes to the rest of
    /// the view hierarchy (i.e. through bindings).
    func makeCoordinator() -> Coordinator

    /// Compute the view's size.
    ///
    /// The default implementation uses `uiViewController.view.intrinsicContentSize` and
    /// `uiViewController.view.systemLayoutSizeFitting(_:)` to determine the return value.
    /// - Parameters:
    ///   - proposal: The proposed frame for the view to render in.
    ///   - uiViewController: The controller being queried for its view's preferred size.
    ///   - context: The context, including the coordinator and environment values.
    /// - Returns: Information about the view's size. The ``SwiftCrossUI/ViewSize/size``
    ///   property is what frame the view will actually be rendered with if the current layout
    ///   pass is not a dry run, while the other properties are used to inform the layout
    ///   engine how big or small the view can be. The ``SwiftCrossUI/ViewSize/idealSize``
    ///   property should not vary with the `proposal`, and should only depend on the view's
    ///   contents. Pass `nil` for the maximum width/height if the view has no maximum size
    ///   (and therefore may occupy the entire screen).
    func determineViewSize(
        for proposal: SIMD2<Int>, uiViewController: UIViewControllerType,
        context: UIViewControllerRepresentableContext<Coordinator>
    ) -> ViewSize

    /// Called to clean up the view when it's removed.
    ///
    /// The default implementation does nothing.
    /// - Parameters:
    ///   - uiViewController: The controller being dismantled.
    ///   - coordinator: The coordinator.
    static func dismantleUIViewController(
        _ uiViewController: UIViewControllerType, coordinator: Coordinator)
}

extension UIViewControllerRepresentable {
    public static func dismantleUIViewController(
        _: UIViewControllerType, coordinator _: Coordinator
    ) {
        // no-op
    }

    public func determineViewSize(
        for proposal: SIMD2<Int>, uiViewController: UIViewControllerType,
        context: UIViewControllerRepresentableContext<Coordinator>
    ) -> ViewSize {
        defaultViewSize(proposal: proposal, view: uiViewController.view)
    }
}

extension View
where Self: UIViewControllerRepresentable {
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

    public func update<Backend: AppBackend>(
        _ widget: Backend.Widget,
        children _: any ViewGraphNodeChildren,
        proposedSize: SIMD2<Int>,
        environment: EnvironmentValues,
        backend _: Backend,
        dryRun: Bool
    ) -> ViewUpdateResult {
        let representingWidget = widget as! ControllerRepresentingWidget<Self>
        representingWidget.update(with: environment)

        let size =
            representingWidget.representable.determineViewSize(
                for: proposedSize,
                uiViewController: representingWidget.subcontroller,
                context: representingWidget.context!
            )

        if !dryRun {
            representingWidget.width = size.size.x
            representingWidget.height = size.size.y
        }

        return ViewUpdateResult.leafView(size: size)
    }
}

extension UIViewControllerRepresentable
where Coordinator == Void {
    public func makeCoordinator() {
        return ()
    }
}

final class ControllerRepresentingWidget<Representable: UIViewControllerRepresentable>:
    BaseControllerWidget
{
    var representable: Representable
    var context: UIViewControllerRepresentableContext<Representable.Coordinator>?

    lazy var subcontroller: Representable.UIViewControllerType = {
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

        return subcontroller
    }()

    func update(with environment: EnvironmentValues) {
        if context == nil {
            context = .init(coordinator: representable.makeCoordinator(), environment: environment)
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
        if let context {
            Representable.dismantleUIViewController(subcontroller, coordinator: context.coordinator)
        }
    }
}
