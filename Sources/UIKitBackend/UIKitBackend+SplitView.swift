import UIKit
@_spi(Backends) import SwiftCrossUI

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
        final class ColumnWidget: NavigationControllerWidget {
            unowned var splitWidget: SplitWidget!

            override func touchesBegan(
                _ touches: Set<UITouch>,
                with event: UIEvent?
            ) {
                print("Touched column widget")
                print(children)
            }

            override func viewWillTransition(
                to size: CGSize,
                with coordinator: UIViewControllerTransitionCoordinator
            ) {
                if !splitWidget.hasCalledResizeHandler {
                    splitWidget.resizeHandler?()
                    splitWidget.hasCalledResizeHandler = true
                }
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

        let sidebarContainer: ColumnWidget
        let mainContainer: ColumnWidget

        init(sidebarWidget: some WidgetProtocol, mainWidget: some WidgetProtocol) {
            // UISplitViewController requires its children to be controllers, not views
            print("Adding sidebar widget:", ObjectIdentifier(sidebarWidget))
            sidebarContainer = ColumnWidget(root: sidebarWidget)
            mainContainer = ColumnWidget(root: mainWidget)

            super.init(child: UISplitViewController())

            sidebarContainer.parentWidget = self
            mainContainer.parentWidget = self
            childWidgets = [sidebarContainer, mainContainer]
            sidebarContainer.splitWidget = self
            mainContainer.splitWidget = self

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
                    print("Showing sidebar")
                    splitView.child.show(splitView.sidebarContainer, sender: nil)
                case .content:
                    // TODO(stackotter): Implement triple column split view support for iOS <14
                    fatalError("NavigationSplitViewColumn.content not supported on iOS <14 yet")
                case .detail:
                    print("Showing detail")
                    splitView.child.showDetailViewController(
                        splitView.mainContainer,
                        sender: nil
                    )
            }
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
