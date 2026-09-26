import UIKit
@_spi(Backends) import SwiftCrossUI

#if os(iOS) || targetEnvironment(macCatalyst)
    final class SplitWidget: WrapperControllerWidget<UISplitViewController>,
        UISplitViewControllerDelegate
    {
        final class SidebarContainer: NavigationControllerWidget {
            unowned var splitWidget: SplitWidget!

            override func viewWillTransition(
                to size: CGSize,
                with coordinator: UIViewControllerTransitionCoordinator
            ) {
                if !splitWidget.hasCalledResizeHandler {
                    splitWidget.resizeHandler?()
                    splitWidget.hasCalledResizeHandler = true
                }
            }

            override func viewDidAppear(_ animated: Bool) {
                splitWidget.columnVisibilityChangeHandler?(.sidebar, true)
            }
        }

        final class DetailContainer: ContainerWidget {
            unowned var splitWidget: SplitWidget!

            override func viewDidDisappear(_ animated: Bool) {
                // We can't do viewWillDisappear, because contrary to its name,
                // it isn't a guarantee that the view will actually disappear;
                // the user can cancel an interactive transition

                splitWidget.columnVisibilityChangeHandler?(.detail, false)

                // viewDidAppear doesn't work when dismissing back to the
                // underlying sidebar view, so we handle the appearance
                // notification here as well
                splitWidget.columnVisibilityChangeHandler?(.sidebar, true)
            }

            override func viewDidAppear(_ animated: Bool) {
                splitWidget.columnVisibilityChangeHandler?(.detail, true)
            }
        }

        var columnVisibilityChangeHandler: ((NavigationSplitViewColumn, Bool) -> Void)?

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

        let sidebarContainer: SidebarContainer
        let detailContainer: DetailContainer

        init(sidebarWidget: some WidgetProtocol, mainWidget: some WidgetProtocol) {
            // UISplitViewController requires its children to be controllers, not views
            sidebarContainer = SidebarContainer(root: sidebarWidget)
            detailContainer = DetailContainer(child: mainWidget)

            super.init(child: UISplitViewController())

            sidebarContainer.parentWidget = self
            detailContainer.parentWidget = self
            childWidgets = [sidebarContainer, detailContainer]
            sidebarContainer.splitWidget = self
            detailContainer.splitWidget = self

            child.delegate = self

            child.preferredDisplayMode = .oneBesideSecondary
            child.preferredPrimaryColumnWidthFraction = 0.3

            child.viewControllers = [sidebarContainer]
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
            // let splitView = splitView as! SplitWidget
            // if splitView.child.isCollapsed {
            //     // TODO(stackotter): Return the correct view of the split
            //     return [.sidebar]
            // } else {
            //     return [.sidebar, .detail]
            // }

            // TODO(stackotter): Fix visible column detection (commented out code doesn't appear to work)
            return [.sidebar]
        }

        public func showColumn(
            _ column: NavigationSplitViewColumn,
            ofSplitView splitView: Widget
        ) {
            let splitView = splitView as! SplitWidget
            switch column.column {
                case .sidebar:
                    splitView.child.show(splitView.sidebarContainer, sender: nil)
                case .content:
                    // TODO(stackotter): Implement triple column split view support for iOS <14
                    fatalError("NavigationSplitViewColumn.content not supported on iOS yet")
                case .detail:
                    splitView.child.showDetailViewController(
                        splitView.detailContainer,
                        sender: nil
                    )
            }
        }

        public func internalPadding(
            ofSplitView splitView: Widget,
            column: NavigationSplitViewColumn
        ) -> SIMD2<Int> {
            let splitView = splitView as! SplitWidget

            let visibleColumns = self.visibleColumns(ofSplitView: splitView)
            if visibleColumns.count == 1 {
                // // Account for the safe area reserved for navigation controls
                // let insets: UIEdgeInsets
                // if visibleColumns.contains(.sidebar) {
                //     insets = splitView.sidebarContainer.root.view.safeAreaInsets
                // } else if visibleColumns.contains(.detail) {
                //     insets = splitView.detailContainer.root.view.safeAreaInsets
                // } else {
                //     logger.warning(
                //         """
                //         Failed to compute safe area insets of split view, couldn't \
                //         find a presented column to measure
                //         """
                //     )
                //     return .zero
                // }

                // return SIMD2(
                //     0,
                //     LayoutSystem.roundSize(Double(insets.top))
                // )

                // The code above doesn't work on the first update (where the
                // safe areas appear to be zero). Someone with more time and more
                // UIKit expertise can probably find a nicer way to measure the
                // size of the UINavigationController safe area.

                // Value obtained empirically via Xcode view hierarchy debugger
                // TODO(stackotter): Measure this value at runtime to ensure that it
                //   survives iOS redesigns and different form-factors.
                return SIMD2(0, 64)
            } else {
                return .zero
            }
        }

        public func setColumnVisibilityChangeHandler(
            ofSplitView splitView: Widget,
            to action: @escaping (NavigationSplitViewColumn, Bool) -> Void
        ) {
            let splitView = splitView as! SplitWidget
            splitView.columnVisibilityChangeHandler = action
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

        public func setColumnVisibilityChangeHandler(
            ofSplitView splitView: Widget,
            to action: @escaping (NavigationSplitViewColumn, Bool) -> Void
        ) {
            fatalError("\(Self.self): \(#function) not implemented")
        }
    }
#endif
