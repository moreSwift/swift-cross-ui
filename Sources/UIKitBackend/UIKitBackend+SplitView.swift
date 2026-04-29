import UIKit
import SwiftCrossUI

class CustomSplitViewController: UISplitViewController {
    override func touchesBegan(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        print("Touched split view controller")
    }
}

#if os(iOS) || targetEnvironment(macCatalyst)
    final class SplitWidget: WrapperControllerWidget<UISplitViewController>,
        UISplitViewControllerDelegate
    {
        private final class ColumnView: UIView {
            unowned var splitWidget: SplitWidget!

            @available(*, unavailable)
            required init?(coder: NSCoder) {
                fatalError("init(coder:) is not used for this view")
            }

            init() {
                super.init(frame: .zero)
            }

            override func layoutSubviews() {
                super.layoutSubviews()
                if !splitWidget.hasCalledResizeHandler {
                    splitWidget.resizeHandler?()
                    splitWidget.hasCalledResizeHandler = true
                }
            }

            override func touchesBegan(
                _ touches: Set<UITouch>,
                with event: UIEvent?
            ) {
                print("Touched column view")
                print(bounds)
                print(subviews[0].bounds)
                print("Subview:", ObjectIdentifier(subviews[0]))
                print("ColumnView:", ObjectIdentifier(self))
            }
        }

        private final class ColumnWidget: ContainerWidget {
            let columnView = ColumnView()

            override func loadView() {
                view = columnView
            }

            override func touchesBegan(
                _ touches: Set<UITouch>,
                with event: UIEvent?
            ) {
                print("Touched column widget")
                print(children)
            }

            override init(child: some WidgetProtocol) {
                super.init(child: child)
            }

            override func viewDidLoad() {
            }
        }

        var resizeHandler: (() -> Void)? {
            didSet {
                hasCalledResizeHandler = false
            }
        }

        // This is just a flag so that we don't call resizeHandler twice in one pass through the run loop.
        var hasCalledResizeHandler = false {
            willSet {
                if newValue {
                    DispatchQueue.main.async { [weak self] in
                        self?.hasCalledResizeHandler = false
                    }
                }
            }
        }

        private let sidebarContainer: ColumnWidget
        private let mainContainer: ColumnWidget

        init(sidebarWidget: some WidgetProtocol, mainWidget: some WidgetProtocol) {
            // UISplitViewController requires its children to be controllers, not views
            print("Adding sidebar widget:", ObjectIdentifier(sidebarWidget))
            sidebarContainer = ColumnWidget(child: sidebarWidget)
            mainContainer = ColumnWidget(child: mainWidget)

            super.init(child: UISplitViewController())

            sidebarContainer.parentWidget = self
            mainContainer.parentWidget = self
            childWidgets = [sidebarContainer, mainContainer]
            sidebarContainer.columnView.splitWidget = self
            mainContainer.columnView.splitWidget = self

            child.delegate = self

            child.preferredDisplayMode = .oneBesideSecondary
            child.preferredPrimaryColumnWidthFraction = 0.3

            child.viewControllers = [sidebarContainer, mainContainer]
        }

        override func viewDidLoad() {
            print("Constraining \(ObjectIdentifier(sidebarContainer.view)) and \(ObjectIdentifier(sidebarContainer.child.view))")
            NSLayoutConstraint.activate([
                sidebarContainer.view.leadingAnchor.constraint(
                    equalTo: sidebarContainer.child.view.leadingAnchor
                ),
                sidebarContainer.view.trailingAnchor.constraint(
                    equalTo: sidebarContainer.child.view.trailingAnchor
                ),
                sidebarContainer.view.topAnchor.constraint(
                    equalTo: sidebarContainer.child.view.topAnchor
                ),
                sidebarContainer.view.bottomAnchor.constraint(
                    equalTo: sidebarContainer.child.view.bottomAnchor
                ),
                mainContainer.view.leadingAnchor.constraint(
                    equalTo: mainContainer.child.view.leadingAnchor
                ),
                mainContainer.view.trailingAnchor.constraint(
                    equalTo: mainContainer.child.view.trailingAnchor
                ),
                mainContainer.view.topAnchor.constraint(
                    equalTo: mainContainer.child.view.topAnchor
                ),
                mainContainer.view.bottomAnchor.constraint(
                    equalTo: mainContainer.child.view.bottomAnchor
                ),
            ])

            super.viewDidLoad()
        }
    }

    extension UIKitBackend {
        public func createSplitView(
            leadingChild: any WidgetProtocol,
            trailingChild: any WidgetProtocol
        ) -> any WidgetProtocol {
            return SplitWidget(sidebarWidget: leadingChild, mainWidget: trailingChild)
        }

        public func setResizeHandler(
            ofSplitView splitView: Widget,
            to action: @escaping () -> Void
        ) {
            let splitWidget = splitView as! SplitWidget
            splitWidget.resizeHandler = action

            // UIApplication.shared.keyWindow!.rootViewController = splitView.controller
        }

        public func sidebarWidth(ofSplitView splitView: Widget) -> Int {
            let splitWidget = splitView as! SplitWidget
            return Int(splitWidget.child.primaryColumnWidth.rounded(.toNearestOrEven))
        }

        public func setSidebarWidthBounds(
            ofSplitView splitView: Widget,
            minimum minimumWidth: Int,
            maximum maximumWidth: Int
        ) {
            let splitWidget = splitView as! SplitWidget
            splitWidget.child.minimumPrimaryColumnWidth = CGFloat(minimumWidth)
            splitWidget.child.maximumPrimaryColumnWidth = CGFloat(maximumWidth)
        }

        public func visibleColumns(
            ofSplitView splitView: Widget
        ) -> Set<NavigationSplitViewColumn> {
            // TODO(stackotter): Make a proper implementation
            [.sidebar]
        }
    }
#else
    extension UIKitBackend {
        public func createSplitView(
            leadingChild: Widget,
            trailingChild: Widget
        ) -> Widget {
            fatalError("\(Self.self): \(#function) not implemented")
        }

        public func setResizeHandler(
            ofSplitView splitView: Widget,
            to action: @escaping () -> Void
        ) {
            fatalError("\(Self.self): \(#function) not implemented")
        }

        public func sidebarWidth(ofSplitView splitView: Widget) -> Int {
            fatalError("\(Self.self): \(#function) not implemented")
        }

        public func setSidebarWidthBounds(
            ofSplitView splitView: Widget,
            minimum minimumWidth: Int,
            maximum maximumWidth: Int
        ) {
            fatalError("\(Self.self): \(#function) not implemented")
        }

        public func visibleColumns(
            ofSplitView splitView: Widget
        ) -> Set<NavigationSplitViewColumn> {
            fatalError("\(Self.self): \(#function) not implemented")
        }
    }
#endif
