import CLVGL
import Foundation
import LVGL
import SwiftCrossUI

extension App {
    public typealias Backend = LVGLBackend
}

public final class LVGLBackend: AppBackend {
    public class Widget {
        private var createWithParent: (LVObject) -> LVObject
        var widget: LVObject?

        init(createWithParent: @escaping (LVObject) -> LVObject) {
            self.createWithParent = createWithParent
            widget = nil
        }

        func postCreationAction(_ action: @escaping (LVObject) -> Void) {
            if let widget {
                action(widget)
            } else {
                let create = createWithParent
                self.createWithParent = { parent in
                    let widget = create(parent)
                    action(widget)
                    return widget
                }
            }
        }

        func create(withParent parent: LVObject) -> LVObject {
            if let widget {
                return widget
            }

            let widget = createWithParent(parent)
            self.widget = widget
            return widget
        }
    }

    public typealias Window = LVScreen

    public class Grid: Widget {
        var rowCount = 0
        var columnCount = 0
    }

    private let runLoop: LVRunLoop
    private var hasCreatedWindow = false

    public init() {
        runLoop = LVRunLoop.shared
    }

    public func runMainLoop(_ callback: @escaping () -> Void) {
        callback()
        runLoop.run()
    }

    public func createWindow(withDefaultSize defaultSize: Size?) -> LVScreen {
        guard !hasCreatedWindow else {
            fatalError("LVGLBackend doesn't support multi-windowing")
        }
        hasCreatedWindow = true
        return LVScreen.active
    }

    public func setTitle(ofWindow window: Window, to title: String) {}

    public func setResizability(ofWindow window: Window, to resizable: Bool) {}

    public func setChild(ofWindow window: Window, to child: Widget) {
        _ = child.create(withParent: window)
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

    public func show(widget: Widget) {}

    public func createVStack() -> Widget {
        let grid = Grid { parent in
            let grid = LVGrid(with: parent, rows: 0, columns: 1, padding: 0)
            grid.size = LVSize(width: 1 << 13 | 2001, height: 1 << 13 | 2001)
            grid.center()
            return grid
        }
        grid.columnCount = 1
        return grid
    }

    public func setChildren(_ children: [Widget], ofVStack container: Widget) {
        container.postCreationAction { widget in
            let container = container as! Grid
            for child in children {
                let rowCount = container.rowCount
                let grid = widget as! LVGrid
                grid.resize(rows: UInt8(rowCount + 1), columns: 1)
                // LVGL grid coordinates have column before row (weird)
                grid.set(cell: child.create(withParent: widget), at: (0, UInt8(rowCount)))
                container.rowCount += 1
            }
        }
    }

    public func setSpacing(ofVStack container: Widget, to spacing: Int) {
        container.postCreationAction { widget in
            let rowCount = (container as! Grid).rowCount
            let grid = widget as! LVGrid
            grid.resize(rows: UInt8(rowCount), columns: 1, padding: Int16(spacing))
        }
    }

    public func createHStack() -> Widget {
        let grid = Grid { parent in
            let grid = LVGrid(with: parent, rows: 1, columns: 0, padding: 0)
            grid.size = LVSize(width: 1 << 13 | 2001, height: 1 << 13 | 2001)
            grid.center()
            return grid
        }
        grid.rowCount = 1
        return grid
    }

    public func setChildren(_ children: [Widget], ofHStack container: Widget) {
        container.postCreationAction { widget in
            let container = container as! Grid
            for child in children {
                let columnCount = container.columnCount
                let grid = widget as! LVGrid
                grid.resize(rows: 1, columns: UInt8(columnCount + 1))
                // LVGL grid coordinates have column before row (weird)
                grid.set(cell: child.create(withParent: widget), at: (UInt8(columnCount), 0))
                container.columnCount += 1
            }
        }
    }

    public func setSpacing(ofHStack container: Widget, to spacing: Int) {
        container.postCreationAction { widget in
            let columnCount = (container as! Grid).columnCount
            let grid = widget as! LVGrid
            grid.resize(rows: 1, columns: UInt8(columnCount), padding: Int16(spacing))
        }
    }

    public func updateScrollContainer(_ scrollView: Widget, environment: EnvironmentValues) {}

    public func createTextView() -> Widget {
        return Widget { parent in
            let label = LVLabel(with: parent)
            return label
        }
    }

    public func updateTextView(_ textView: Widget, content: String, shouldWrap: Bool) {
        // TODO: Implement text wrap option
        textView.postCreationAction { widget in
            (widget as! LVLabel).text = content
        }
    }

    public func createButton() -> Widget {
        return Widget { parent in
            let button = LVButton(with: parent)
            let buttonLabel = LVLabel(with: button)
            buttonLabel.center()
            return button
        }
    }

    public func updateButton(_ button: Widget, label: String, action: @escaping () -> Void) {
        button.postCreationAction { widget in
            let widget = widget as! LVButton
            (widget.child(at: 0)! as! LVLabel).text = label
        }

        button.postCreationAction { widget in
            let widget = widget as! LVButton
            widget.onEvent = { event in
                if event.code == LV_EVENT_PRESSED {
                    action()
                }
            }
        }
    }
}
