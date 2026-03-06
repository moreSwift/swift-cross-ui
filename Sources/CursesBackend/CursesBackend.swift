import Foundation
import SwiftCrossUI
import TermKit

extension App {
    public typealias Backend = CursesBackend
}

public final class CursesBackend: AppBackend {
    public typealias Window = RootView
    public typealias Widget = TermKit.View

    var root: RootView
    var hasCreatedWindow = false

    public init() {
        Application.prepare()
        root = RootView()
        Application.top.addSubview(root)
    }

    public func runMainLoop(_ callback: @escaping () -> Void) {
        callback()
        Application.run()
    }

    public func createWindow(withDefaultSize defaultSize: SwiftCrossUI.Size?) -> Window {
        guard !hasCreatedWindow else {
            fatalError("CursesBackend doesn't support multi-windowing")
        }
        hasCreatedWindow = true
        return root
    }

    public func setTitle(ofWindow window: Window, to title: String) {}

    public func setResizability(ofWindow window: Window, to resizable: Bool) {}

    public func setChild(ofWindow window: Window, to child: Widget) {
        window.addSubview(child)
    }

    public func show(window: Window) {}

    public func runInMainThread(action: @escaping () -> Void) {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
            DispatchQueue.main.async {
                action()
            }
        #else
            action()
        #endif
    }

    public func showUpdate(widget: Widget) {
        widget.setNeedsDisplay()
    }

    public func createVStack() -> Widget {
        return View()
    }

    public func setChildren(_ children: [Widget], ofVStack container: Widget) {
        // TODO: Properly calculate layout
        for child in children {
            child.y = Pos.at(container.subviews.count)
            container.addSubview(child)
        }
    }

    public func setSpacing(ofVStack container: Widget, to spacing: Int) {}

    public func createHStack() -> Widget {
        return View()
    }

    public func setChildren(_ children: [Widget], ofHStack container: Widget) {
        // TODO: Properly calculate layout
        for child in children {
            child.y = Pos.at(container.subviews.count)
            container.addSubview(child)
        }
    }

    public func setSpacing(ofHStack container: Widget, to spacing: Int) {}

    public func updateScrollContainer(_ scrollView: Widget, environment: EnvironmentValues) {}

    public func createTextView() -> Widget {
        let label = Label("")
        label.width = Dim.fill()
        return label
    }

    public func updateTextView(_ textView: Widget, content: String, shouldWrap: Bool) {
        // TODO: Implement text wrap handling
        let label = textView as! Label
        label.text = content
    }

    public func createButton() -> Widget {
        let button = TermKit.Button("")
        button.height = Dim.sized(1)
        return button
    }

    public func updateButton(_ button: Widget, label: String, action: @escaping () -> Void) {
        (button as! TermKit.Button).text = label
        (button as! TermKit.Button).clicked = { _ in
            action()
        }
    }

    // TODO: Properly implement padding container. Perhaps use a conversion factor to
    //   convert the pixel values to 'characters' of padding
    public func createPaddingContainer(for child: Widget) -> Widget {
        return child
    }

    public func getChild(ofPaddingContainer container: Widget) -> Widget {
        return container
    }

    public func setPadding(
        ofPaddingContainer container: Widget,
        top: Int,
        bottom: Int,
        leading: Int,
        trailing: Int
    ) {}
}

public class RootView: TermKit.View {
    public override func processKey(event: KeyEvent) -> Bool {
        if super.processKey(event: event) {
            return true
        }

        switch event.key {
            case .controlC, .esc:
                Application.requestStop()
                return true
            default:
                return false
        }
    }
}
