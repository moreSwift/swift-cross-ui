import UIKit
import UIKitCompatKit

final class RootViewController: UIViewController {
    unowned var backend: UIKitBackend
    var resizeHandler: ((CGSize) -> Void)?
    private var childWidget: (any WidgetProtocol)?

    #if os(visionOS)
        init(backend: UIKitBackend) {
            self.backend = backend
            super.init(nibName: nil, bundle: nil)

            registerForTraitChanges([UITraitUserInterfaceStyle.self]) {
                (self: RootViewController, _: UITraitCollection) in
                self.backend.onTraitCollectionChange?()
            }
        }
    #else
        init(backend: UIKitBackend) {
            self.backend = backend
            super.init(nibName: nil, bundle: nil)
        }
        
        
        @available(iOS 8.0, *)
        override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)
            backend.onTraitCollectionChange?()
        }
    #endif

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not used for the root view controller")
    }

    override func loadView() {
        super.loadView()
        if #available(iOS 13, *) {
            if traitCollection.userInterfaceStyle != .dark {
                view.backgroundColor = .white
            }
        } else {
            view.backgroundColor = .white
        }
    }
    
    
    @available(iOS 8.0, *)
    override func viewWillTransition(
        to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        resizeHandler?(size)
    }

    func setChild(to child: some WidgetProtocol) {
        childWidget?.removeFromParentWidget()
        child.removeFromParentWidget()

        let childController = child.controller
        view.addSubview(child.view)
        if let childController {
            addChild(childController)
            childController.didMove(toParent: self)
        }
        childWidget = child

        NSLayoutConstraint.activate([
            child.view.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            child.view.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor),
        ])
    }
}

extension UIKitBackend {
    public typealias Window = UIWindow

    public func createWindow(withDefaultSize _: SIMD2<Int>?) -> Window {
        var window: UIWindow

        if !Self.hasReturnedAWindow {
            Self.hasReturnedAWindow = true
            window = Self.mainWindow ?? UIWindow()
        } else {
            window = UIWindow()
        }

        window.rootViewController = RootViewController(backend: self)
        return window
    }

    public func setTitle(ofWindow window: Window, to title: String) {
        // I don't think this achieves much of anything but might as well
        window.rootViewController!.title = title
    }

    public func setChild(ofWindow window: Window, to child: Widget) {
        let viewController = window.rootViewController as! RootViewController
        viewController.setChild(to: child)
    }

    public func size(ofWindow window: Window) -> SIMD2<Int> {
        // For now, Views have no way to know where the safe area insets are, and the edges
        // of the screen could be obscured (e.g. covered by the notch). In the future we
        // might want to let users decide what to do, but for now, lie and say that the safe
        // area insets aren't even part of the window.
        // If/when this is updated, ``RootViewController`` and ``WidgetProtocolHelpers`` will
        // also need to be updated.
        let size = window.safeAreaLayoutGuide.layoutFrame.size
        return SIMD2(Int(size.width), Int(size.height))
    }

    public func setResizeHandler(
        ofWindow window: Window,
        to action: @escaping (_ newSize: SIMD2<Int>) -> Void
    ) {
        let viewController = window.rootViewController as! RootViewController
        viewController.resizeHandler = { size in
            action(SIMD2(Int(size.width), Int(size.height)))
        }
    }

    public func show(window: Window) {
        window.makeKeyAndVisible()
    }

    public func activate(window: Window) {
        window.makeKeyAndVisible()
    }

    public func isWindowProgrammaticallyResizable(_ window: Window) -> Bool {
        #if os(visionOS)
            true
        #else
            false
        #endif
    }

    public func setResizability(ofWindow window: Window, to resizable: Bool) {
        print("UIKitBackend: ignoring \(#function) call")
    }

    public func setSize(ofWindow window: Window, to newSize: SIMD2<Int>) {
        #if os(visionOS)
            window.bounds.size = CGSize(width: CGFloat(newSize.x), height: CGFloat(newSize.y))
        #else
            print(
                "UIKitBackend: ignoring \(#function) call. Current window size: \(window.bounds.width) x \(window.bounds.height); proposed size: \(newSize.x) x \(newSize.y)"
            )
        #endif
    }

    public func setMinimumSize(ofWindow window: Window, to minimumSize: SIMD2<Int>) {
        // if windowScene is nil, either the window isn't shown or it must be fullscreen
        // if sizeRestrictions is nil, the device doesn't support setting a minimum window size
        if #available(iOS 13, *) {
            window.windowScene?.sizeRestrictions?.minimumSize = CGSize(
                width: CGFloat(minimumSize.x), height: CGFloat(minimumSize.y))
        } else {
            // iOS 12: windowScene/sizeRestrictions not available
            // Optional: enforce min size in your layout logic
            print("UIKitBackend: setMinimumSize ignored on iOS < 13")
        }
    }
}
