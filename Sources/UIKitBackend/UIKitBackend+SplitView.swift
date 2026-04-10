import UIKit

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
        }

        private final class ColumnWidget: ContainerWidget {
            let columnView = ColumnView()

            override func loadView() {
                view = columnView
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
    }
#endif
