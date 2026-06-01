import UIKit
import UIKitCompatKit

#if os(iOS)
    final class SplitWidget: WrapperControllerWidget<UISplitViewController>,
        UISplitViewControllerDelegate
    {
        var resizeHandler: (() -> Void)?
        private let sidebarContainer: ContainerWidget
        private let mainContainer: ContainerWidget

        init(sidebarWidget: some WidgetProtocol, mainWidget: some WidgetProtocol) {
            // UISplitViewController requires its children to be controllers, not views
            sidebarContainer = ContainerWidget(child: sidebarWidget)
            mainContainer = ContainerWidget(child: mainWidget)

            super.init(child: UISplitViewController())

            child.delegate = self
            
            
            if #available(iOS 8.0, *) {
                child.preferredDisplayMode = .oneBesideSecondary
                child.preferredPrimaryColumnWidthFraction = 0.3
            }

            child.viewControllers = [sidebarContainer, mainContainer]
        }

        override func viewDidLoad() {
            NSLayoutConstraint.activate([
                sidebarContainer.view.leadingAnchor.constraint(
                    equalTo: sidebarContainer.child.view.leadingAnchor),
                sidebarContainer.view.trailingAnchor.constraint(
                    equalTo: sidebarContainer.child.view.trailingAnchor),
                sidebarContainer.view.topAnchor.constraint(
                    equalTo: sidebarContainer.child.view.topAnchor),
                sidebarContainer.view.bottomAnchor.constraint(
                    equalTo: sidebarContainer.child.view.bottomAnchor),
                mainContainer.view.leadingAnchor.constraint(
                    equalTo: mainContainer.child.view.leadingAnchor),
                mainContainer.view.trailingAnchor.constraint(
                    equalTo: mainContainer.child.view.trailingAnchor),
                mainContainer.view.topAnchor.constraint(
                    equalTo: mainContainer.child.view.topAnchor),
                mainContainer.view.bottomAnchor.constraint(
                    equalTo: mainContainer.child.view.bottomAnchor),
            ])

            super.viewDidLoad()
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            resizeHandler?()
        }
    }

    extension UIKitBackend {
        public func createSplitView(
            leadingChild: any WidgetProtocol,
            trailingChild: any WidgetProtocol
        ) -> any WidgetProtocol {
            precondition(
                UIDevice.current.userInterfaceIdiom != .phone,
                "NavigationSplitView is currently unsupported on iPhone and iPod touch.")

            return SplitWidget(sidebarWidget: leadingChild, mainWidget: trailingChild)
        }

        public func setResizeHandler(
            ofSplitView splitView: Widget,
            to action: @escaping () -> Void
        ) {
            let splitWidget = splitView as! SplitWidget
            splitWidget.resizeHandler = action
        }
        
        @available(iOS 8, *)
        public func sidebarWidth(ofSplitView splitView: Widget) -> Int {
            let splitWidget = splitView as! SplitWidget
            return Int(splitWidget.child.primaryColumnWidth.rounded(.toNearestOrEven))
        }
        
        @available(iOS 8, *)
        public func setSidebarWidthBounds(
            ofSplitView splitView: Widget,
            minimum minimumWidth: Int,
            maximum maximumWidth: Int
        ) {
            let splitWidget = splitView as! SplitWidget
            splitWidget.child.minimumPrimaryColumnWidth = CGFloat(minimumWidth)
            splitWidget.child.maximumPrimaryColumnWidth = CGFloat(maximumWidth)
        }
    }
#endif
