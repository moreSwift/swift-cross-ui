import AppKit
import SwiftCrossUI

extension AppKitBackend {
    public func createSimpleButton() -> Widget {
        NSButton()
    }

    public func updateSimpleButton(
        _ button: Widget,
        label: String,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        let button = button as! NSButton
        button.attributedTitle = Self.attributedString(
            for: label,
            in: environment.with(\.multilineTextAlignment, .center)
        )
        button.appearance = environment.colorScheme.nsAppearance
        button.isEnabled = environment.isEnabled

        button.onAction = { _ in
            action()
        }
    }

    public func createButton(
        wrapping child: Widget
    ) -> NSView {
        let button = NSCustomButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setupButton()

        button.addAndSetupLabel(child)

        return button
    }

    public func updateButton(
        _ button: NSView,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        let button = button as! NSCustomButton

        button.action = action
        button.isEnabled = environment.isEnabled
        button.buttonStyle = environment.resolvedButtonStyle.kind
    }

    public func buttonPadding(in environment: EnvironmentValues) -> SIMD2<Int> {
        switch environment.resolvedButtonStyle.kind {
            case .bordered: measureBorderedButtonPadding()
            case .plain, .borderless: SIMD2<Int>(0, 0)
        }
    }

    public func defaultButtonStyle() -> ButtonStyle { .bordered }

    func measureBorderedButtonPadding() -> SIMD2<Int> {
        if let borderedButtonPadding { return borderedButtonPadding }

        let testString = "E"
        let dummyButton = NSButton()
        dummyButton.title = testString
        dummyButton.controlSize = .regular
        dummyButton.sizeToFit()

        let field = NSTextField(wrappingLabelWithString: "")
        field.stringValue = testString
        field.font = dummyButton.font
        let textSize = field.intrinsicContentSize

        let buttonSize = dummyButton.intrinsicContentSize

        let result = SIMD2(
            Int(buttonSize.width - textSize.width),
            Int(buttonSize.height - textSize.height)
        )

        borderedButtonPadding = result
        return result
    }
}

public final class NSCustomButton: NSView {
    fileprivate var action: (() -> Void)?
    fileprivate let button = NSButtonBackground()
    fileprivate var buttonStyle: ButtonStyle.Kind = .bordered {
        didSet { updateButtonAppearance() }
    }

    var isEnabled = true {
        didSet {
            if !isEnabled {
                isPressed = false
                isHighlighted = false
            }
            buttonStyle.applyModifications(self)
            needsDisplay = true
        }
    }

    // Whether left mousebutton is pressed on this view.
    private var isPressed = false

    private var highlightResetWorkItem: DispatchWorkItem?

    public var isHighlighted = false {
        didSet {
            buttonStyle.applyModifications(self)
            needsDisplay = true
        }
    }

    override public func accessibilityRole() -> NSAccessibility.Role? {
        .button
    }

    override public func accessibilityActionNames() -> [NSAccessibility.Action] {
        return [.press]
    }

    override public func accessibilityPerformPress() -> Bool {
        self.action?()
        return true
    }

    override public func accessibilityLabel() -> String? {
        // Automatically uses the label text of a Button("") {} as accessibilityLabel.
        // This should be improved via a future .accessibilityLabel(_:) modifier.
        // The ViewBuilder button init is not covered by this current solution.
        (subviews.first as? NSTextField)?.stringValue
    }

    override public func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }

    override public var acceptsFirstResponder: Bool {
        // Even though its called FullKeyboardAccess, it's actually
        // the "Keyboard navigation" setting.
        isEnabled && NSApplication.shared.isFullKeyboardAccessEnabled
    }

    override public var focusRingMaskBounds: NSRect { bounds }

    override public func becomeFirstResponder() -> Bool {
        let ok = super.becomeFirstResponder()
        if ok { noteFocusRingMaskChanged() }
        return ok
    }

    override public func resignFirstResponder() -> Bool {
        let ok = super.resignFirstResponder()
        if ok { noteFocusRingMaskChanged() }
        return ok
    }

    override public func drawFocusRingMask() {
        guard isEnabled else { return }
        buttonStyle.drawFocusRingMask(on: self)
    }

    override public func keyDown(with event: NSEvent) {
        guard
            isEnabled,
            (event.charactersIgnoringModifiers ?? "") == " "
        else {
            super.keyDown(with: event)
            return
        }

        highlightResetWorkItem?.cancel()
        isHighlighted = true
        action?()

        // Task with Task.sleep could be used in the future,
        // it has a min version requirement of macOS 13.
        let workItem = DispatchWorkItem { [weak self] in
            self?.isHighlighted = false
        }
        highlightResetWorkItem = workItem

        // 0.1 highlight duration is an estimate of what it feels like.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: workItem)
    }

    override public func viewWillMove(toWindow newWindow: NSWindow?) {
        // Reset internal state when moved (or potentially re-used in the future).
        if newWindow == nil {
            highlightResetWorkItem?.cancel()
            isHighlighted = false
            isPressed = false
        }
    }

    override public func mouseDown(with _: NSEvent) {
        guard isEnabled else { return }

        isPressed = true
        isHighlighted = true
    }

    override public func mouseDragged(with event: NSEvent) {
        guard isEnabled else { return }

        let pointInView = convert(event.locationInWindow, from: nil)

        if isPressed && bounds.contains(pointInView) {
            isHighlighted = true
        } else {
            isHighlighted = false
        }
    }

    override public func mouseUp(with event: NSEvent) {
        guard isEnabled else { return }

        let pointInView = self.convert(event.locationInWindow, from: nil)

        if bounds.contains(pointInView) {
            action?()
        }

        isPressed = false
        isHighlighted = false
    }

    private func updateButtonAppearance() {
        buttonStyle.applyModifications(self)
        noteFocusRingMaskChanged()
        self.needsDisplay = true
    }

    fileprivate func setupButton() {
        button.title = ""
        button.isBordered = true
        button.bezelStyle = .flexiblePush

        button.translatesAutoresizingMaskIntoConstraints = false

        addSubview(button)

        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    fileprivate func addAndSetupLabel(_ child: NSView) {
        addSubview(child)
        child.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            child.centerXAnchor.constraint(equalTo: centerXAnchor),
            child.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}

// This class is needed, because you cannot set
// isUserInteractionEnabled on a regular NSButton.
private final class NSButtonBackground: NSButton {
    override func hitTest(_ point: NSPoint) -> NSView? {
        return nil
    }

    override var canBecomeKeyView: Bool { false }

    override func drawFocusRingMask() {
        guard let cell else { return }
        var bounds = bounds
        if #unavailable(macOS 26) {
            // For some reason the focus ring drawing appears is offset
            // by the width of the focusring prior to macOS 26.
            // As far as I know the focus ring width is always 3.
            bounds.origin.x -= 3
            bounds.origin.y -= 3
        }
        cell.drawFocusRingMask(withFrame: bounds, in: self)
    }
}

extension ButtonStyle.Kind {
    fileprivate func applyModifications(_ button: NSCustomButton) {
        button.button.isHidden = true
        switch self {
            case .bordered:
                button.button.isHidden = false
                button.button.isEnabled = button.isEnabled
                button.button.isHighlighted = button.isHighlighted
            case .plain, .borderless:
                button.alphaValue = button.isEnabled
                    ? button.isHighlighted ? 0.80: 1.0
                    : 0.5
                // Why 50% disabled opacity was chosen:
                // A disabled SwiftUI .plain button looks visually the same as
                // an enabled one at 0.5 opacity.
                // Why 80% for active(pressed) was chosen:
                // A pressed SwiftUI .plain button looks visually the same as
                // a not pressed one at 0.8 opacity.
        }
    }

    fileprivate var shouldRenderNativeBackground: Bool {
        switch self {
            case .bordered:
                true
            case .plain, .borderless:
                false
        }
    }

    fileprivate func drawFocusRingMask(on button: NSCustomButton) {
        switch self {
            case .bordered:
                button.button.drawFocusRingMask()
            case .plain, .borderless:
                let maskPath = NSBezierPath(rect: button.bounds)
                maskPath.fill()
        }
    }
}
