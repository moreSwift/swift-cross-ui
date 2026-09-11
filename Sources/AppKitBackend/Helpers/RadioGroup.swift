import AppKit
import SwiftCrossUI

final class RadioGroup: NSStackView {
    private var buttons: [NSButton]
    var onChange: ((Int?) -> Void)?

    override var intrinsicContentSize: NSSize {
        buttons.reduce(
            into: NSSize(width: 0.0, height: max(0.0, spacing * Double(buttons.count - 1)))
        ) { partialResult, button in
            let buttonIntrinsicSize = button.intrinsicContentSize
            partialResult.width = max(partialResult.width, buttonIntrinsicSize.width)
            partialResult.height += buttonIntrinsicSize.height
        }
    }

    init() {
        self.buttons = []
        super.init(frame: .zero)
        self.orientation = .vertical
        self.alignment = .leading
        self.setAccessibilityRole(.radioGroup)
    }

    required init?(coder: NSCoder) {
        fatalError("not used")
    }

    func update(options: [String], environment: EnvironmentValues) {
        for i in 0..<min(buttons.count, options.count) {
            buttons[i].attributedTitle = AppKitBackend.attributedString(
                for: options[i],
                in: environment
            )
            buttons[i].isEnabled = environment.isEnabled
        }

        if options.count > buttons.count {
            for i in buttons.count..<options.count {
                let button = NSButton()
                button.attributedTitle = AppKitBackend.attributedString(
                    for: options[i],
                    in: environment
                )
                button.isEnabled = environment.isEnabled
                button.target = self
                button.action = #selector(buttonClicked(sender:))
                button.tag = i
                button.setButtonType(.radio)
                addArrangedSubview(button)
                buttons.append(button)
            }
        } else {
            for i in (options.count..<buttons.count).reversed() {
                removeView(buttons[i])
                buttons.remove(at: i)
            }
        }
    }

    func setSelectedIndex(to index: Int?) {
        if let index {
            buttons[index].state = .on
        } else {
            buttons.forEach { $0.state = .off }
        }
    }

    @objc func buttonClicked(sender: NSButton) {
        onChange?(sender.tag)
    }
}
