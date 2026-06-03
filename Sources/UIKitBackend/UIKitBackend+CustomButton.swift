import UIKit
import SwiftCrossUI

extension UIKitBackend {
    public func createButton(wrapping widget: Widget) -> Widget {
        let widget = widget as! UIView
        let button = UICustomButton(label: widget)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        widget.isUserInteractionEnabled = false
        button.isUserInteractionEnabled = true

        return CustomButtonWidget(button: button)
    }

    public func updateButton(
        _ button: Widget,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        let button = (button as! CustomButtonWidget).child
        button.onTap = action
        button.isEnabled = environment.isEnabled
        
        if #available(iOS 15.0, tvOS 15.0, macCatalyst 15.0, *) {
            button.configuration = switch environment.resolvedButtonStyle.kind {
                case .bordered: .bordered()
                case .borderless: .borderless()
                case .plain: .plain()
            }
        }

        // Automatically sets the label text of a Button("") {} as accessibilityLabel.
        // This should be improved via a future .accessibilityLabel(_:) modifier.
        // The ViewBuilder button init is not covered by this current solution.
        if let child = (button.subviews[1] as? WrapperWidget<TextView>)?.child {
            button.accessibilityLabel = child.text
        }
    }

    public func buttonPadding(in environment: EnvironmentValues) -> SIMD2<Int> {
        let borderedPadding = SIMD2(
            Int(UICustomButton.horizontalInsets),
            Int(UICustomButton.verticalInsets)
        )

        // tvOS always gets full padding, due to highlighting using
        // the highlighted state of bordered button for all styles.
        #if os(tvOS)
            return borderedPadding
        #else
            return switch environment.resolvedButtonStyle.kind {
                case .plain, .borderless: SIMD2(0, 0)
                case .bordered: borderedPadding
            }
        #endif
    }

    public func defaultButtonStyle() -> ButtonStyle {
        .borderless
    }
}

final class CustomButtonWidget: WrapperWidget<UICustomButton> {
    init(button: UICustomButton) {
        super.init(child: button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}

final class UICustomButton: UIButton {
    var label: UIView
    
    static var horizontalInsets: CGFloat {
        guard #available(iOS 15.0, tvOS 15.0, macCatalyst 15.0, *) else {
            return 24
        }
        let insets = UIButton.Configuration.bordered().contentInsets
        return insets.leading + insets.trailing
    }
    
    static var verticalInsets: CGFloat {
        guard #available(iOS 15.0, tvOS 15.0, macCatalyst 15.0, *) else {
            return 14
        }
        let insets = UIButton.Configuration.bordered().contentInsets
        return insets.bottom + insets.top
    }
    
    public var onTap: (() -> Void)?
    
    public var buttonStyle: ButtonStyle.Kind = .borderless
    
    override public var isHighlighted: Bool {
        didSet {
            UIView.animate(
                withDuration: 0.1,
                delay: 0,
                options: [.allowUserInteraction],
                animations: { [weak self] in
                    guard let self else { return }
                    self.buttonStyle.applyModifications(self)
                },
                completion: nil
            )
        }
    }
    
    override public var isEnabled: Bool {
        didSet {
            self.buttonStyle.applyModifications(self)
        }
    }
    
    init(label: UIView) {
        self.label = label
        super.init(frame: .zero)
        addAndCenterChild(label)
        #if os(tvOS)
            addTarget(self, action: #selector(buttonTapped), for: .primaryActionTriggered)
        #else
            addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        #endif
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure custom label stays above system overlays (like highlighting)
        bringSubviewToFront(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoder input is not supported on UICustomButton")
    }
    
    @objc
    func buttonTapped() {
        onTap?()
    }
    
    func addAndCenterChild(_ child: UIView) {
        addSubview(child)
        child.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            child.centerXAnchor.constraint(equalTo: centerXAnchor),
            child.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

extension ButtonStyle.Kind {
    fileprivate func updateBackground(_ button: UICustomButton) {
        // We don't support bordered button style on older versions.
        guard #available(iOS 15.0, tvOS 15.0, macCatalyst 15.0, *) else {
            return
        }
        
        switch self {
            case .bordered:
                button.configuration = .bordered()
            case .plain, .borderless:
                // The borderless special treatment is handled in environment.
                button.configuration = .plain()
        }
    }
    
    fileprivate func applyModifications(_ button: UICustomButton) {
        guard #available(iOS 15.0, tvOS 15.0, macCatalyst 15.0, *) else {
            button.label.alpha = button.isEnabled
            ? button.isHighlighted ? 0.8: 1.0
            : 0.5
            return
        }
        switch self {
            case .bordered:
                button.label.alpha = button.isEnabled ? 1.0: 0.5
            case .plain, .borderless:
                button.label.alpha = button.isEnabled
                ? button.isHighlighted ? 0.8: 1.0
                : 0.5
                // Why 50% disabled opacity was chosen:
                // A disabled SwiftUI .plain button looks visually the same as
                // an enabled one at 0.5 opacity.
                // Why 80% for active(pressed) was chosen:
                // A pressed SwiftUI .plain button looks visually the same as
                // a not pressed one at 0.8 opacity.
        }
    }
}
