import UIKit
@_spi(Backends) import SwiftCrossUI

final class UIButtonCheckbox: WrapperWidget<UIButton> {
    private static let image = UIImage(systemName: "checkmark")

    var state = false {
        didSet {
            if state {
                child.setImage(Self.image, for: .normal)
            } else {
                child.setImage(nil, for: .normal)
            }

            #if !os(tvOS)
                child.backgroundColor = child
                    .isEnabled && state ? .systemBlue : .secondarySystemFill
            #endif
        }
    }

    private var onChange: ((Bool) -> Void)?

    override var intrinsicContentSize: CGSize {
        let buttonSize = child.intrinsicContentSize
        let size = max(buttonSize.width, buttonSize.height)
        return CGSize(width: size, height: size)
    }

    init() {
        let child = UIButton(type: .system)
        child.contentEdgeInsets = .zero

        super.init(child: child)

        let event: UIControl.Event
        #if os(tvOS)
            event = .primaryActionTriggered
        #else
            event = .touchUpInside
            child.layer.cornerRadius = 10.0
        #endif
        child.addTarget(self, action: #selector(tapped), for: event)
    }

    func update(environment: EnvironmentValues, onChange: @escaping (Bool) -> Void) {
        child.isEnabled = environment.isEnabled
        child.imageView?.tintColor =
            environment.suggestedForegroundColor.resolve(in: environment).uiColor
        self.onChange = onChange
    }

    @objc func tapped() {
        state.toggle()
        onChange?(state)
    }
}

extension UIKitBackend {
    public func createCheckbox() -> any WidgetProtocol {
        UIButtonCheckbox()
    }

    public func updateCheckbox(
        _ checkboxWidget: any WidgetProtocol,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        let widget = checkboxWidget as! UIButtonCheckbox
        widget.update(environment: environment, onChange: onChange)
    }

    public func setState(ofCheckbox checkboxWidget: any WidgetProtocol, to state: Bool) {
        let widget = checkboxWidget as! UIButtonCheckbox

        widget.state = state
    }
}
