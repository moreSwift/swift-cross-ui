import Foundation
import Qlift
import SwiftCrossUI

extension App {
    public typealias Backend = QtBackend
}

// TODO: Remove default padding from QBoxLayout related widgets.
// TODO: Fix window size code, currently seems to get pretty ignored.

public struct QtBackend: AppBackend {
    public typealias Window = QMainWindow
    public typealias Widget = QWidget

    private class InternalState {
        var buttonClickActions: [ObjectIdentifier: () -> Void] = [:]
        var sliderChangeActions: [ObjectIdentifier: (Double) -> Void] = [:]
        var paddingContainerChildren: [ObjectIdentifier: Widget] = [:]
    }

    private var internalState: InternalState
    private let application: QApplication

    public init() {
        internalState = InternalState()
        application = QApplication()
    }

    public func runMainLoop(_ callback: @escaping () -> Void) {
        callback()
        _ = application.exec()
    }

    public func createWindow(withDefaultSize defaultSize: Size?) -> Window {
        let mainWindow = MainWindow()
        mainWindow.geometry = QRect(
            x: 0,
            y: 0,
            width: Int32(defaultSize?.width ?? 0),
            height: Int32(defaultSize?.height ?? 0)
        )
        return mainWindow
    }

    public func setTitle(ofWindow window: Window, to title: String) {
        window.windowTitle = title
    }

    public func setResizability(ofWindow window: Window, to resizable: Bool) {
        // TODO: Get window resizability working. It seems to remain resizable no matter what
        //   policy I apply.
        //  let policy: QSizePolicy.Policy = .Maximum
        //  window.sizePolicy = QSizePolicy(horizontal: policy, vertical: policy)
    }

    public func setChild(ofWindow window: Window, to child: Widget) {
        window.centralWidget = child
    }

    public func show(window: Window) {
        window.show()
    }

    public func runInMainThread(action: @escaping () -> Void) {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
            DispatchQueue.main.async {
                action()
            }
        #else
            action()
        #endif
    }

    public func show(widget: Widget) {
        widget.show()
    }

    public func createVStack() -> Widget {
        let layout = QVBoxLayout()
        let widget = QWidget()
        widget.layout = layout
        return widget
    }

    public func setChildren(_ children: [Widget], ofVStack container: Widget) {
        let container = container.layout as! QVBoxLayout
        for child in children {
            container.add(widget: child)
        }
    }

    public func setSpacing(ofVStack widget: Widget, to spacing: Int) {
        (widget.layout as! QVBoxLayout).spacing = Int32(spacing)
    }

    public func createHStack() -> Widget {
        let layout = QHBoxLayout()
        let widget = QWidget()
        widget.layout = layout
        return widget
    }

    public func setChildren(_ children: [Widget], ofHStack container: Widget) {
        let container = container.layout as! QHBoxLayout
        for child in children {
            container.add(widget: child)
        }
    }

    public func updateScrollContainer(_ scrollView: Widget, environment: EnvironmentValues) {}

    public func setSpacing(ofHStack widget: Widget, to spacing: Int) {
        (widget.layout as! QHBoxLayout).spacing = Int32(spacing)
    }

    public func createTextView() -> Widget {
        return QLabel(text: "")
    }

    public func updateTextView(_ textView: Widget, content: String, shouldWrap: Bool) {
        // TODO: Implement text wrap setting
        (textView as! QLabel).text = content
    }

    public func createButton() -> Widget {
        let button = QPushButton(text: "")

        // Internal state is required to avoid multiple subsequent calls to setAction adding
        // new handlers instead of replacing the existing handler
        button.connectClicked(receiver: nil) { [weak internalState] in
            guard let internalState else { return }
            internalState.buttonClickActions[ObjectIdentifier(button)]?()
        }

        return button
    }

    public func updateButton(_ button: Widget, label: String, action: @escaping () -> Void) {
        (button as! QPushButton).text = label
        internalState.buttonClickActions[ObjectIdentifier(button)] = action
    }

    public func createSlider() -> QWidget {
        let slider = QSlider(orientation: .Horizontal)
        slider.connectValueChanged(receiver: nil) { [weak internalState] val in
            guard let internalState else { return }
            internalState.sliderChangeActions[ObjectIdentifier(slider)]?(Double(val))
        }

        return slider
    }

    public func updateSlider(
        _ slider: Widget,
        minimum: Double,
        maximum: Double,
        decimalPlaces: Int,
        onChange: @escaping (Double) -> Void
    ) {
        let slider = slider as! QSlider
        slider.minimum = Int32(minimum)
        slider.maximum = Int32(maximum)
        internalState.sliderChangeActions[ObjectIdentifier(slider)] = onChange
    }

    public func setValue(ofSlider slider: Widget, to value: Double) {
        (slider as! QSlider).value = Int32(value)
    }

    public func createPaddingContainer(for child: Widget) -> Widget {
        let container = createVStack()
        setChildren([child], ofVStack: container)
        internalState.paddingContainerChildren[ObjectIdentifier(container)] = child
        return container
    }

    public func setPadding(
        ofPaddingContainer container: Widget,
        top: Int,
        bottom: Int,
        leading: Int,
        trailing: Int
    ) {
        (container.layout! as! QVBoxLayout).contentsMargins = QMargins(
            left: Int32(leading),
            top: Int32(top),
            right: Int32(trailing),
            bottom: Int32(bottom)
        )
    }
}

class MainWindow: QMainWindow {
    override init(parent: QWidget? = nil, flags: Qt.WindowFlags = .Widget) {
        super.init(parent: parent, flags: flags)
    }
}
