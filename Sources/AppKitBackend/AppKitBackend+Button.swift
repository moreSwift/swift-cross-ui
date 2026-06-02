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
        
        button.addSubview(child)
        child.translatesAutoresizingMaskIntoConstraints = false
        button.setupConstraints()

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

    public func defaultButtonStyle() -> ButtonStyle {
        .bordered
    }
    
    func measureBorderedButtonPadding() -> SIMD2<Int> {
        let dummyButton = NSButton()
        dummyButton.title = "Test"
        dummyButton.controlSize = .regular
        dummyButton.sizeToFit()
        
        let frame = dummyButton.frame
        
        // 24 and 8 are the current results on macOS 26
        guard let cell = dummyButton.cell else { return SIMD2(24, 8) }
        let titleRect = cell.titleRect(forBounds: dummyButton.bounds)
        
        let leftPadding = max(0, titleRect.origin.x)
        let rightPadding = max(0, frame.size.width - (titleRect.origin.x + titleRect.size.width))
        
        // Alignment rect is used to bypass coordinate flipping.
        let alignmentRect = dummyButton.alignmentRect(forFrame: frame)
        let topPadding = max(0, titleRect.origin.y - alignmentRect.origin.y)
        let bottomPadding = max(0, alignmentRect.size.height - (titleRect.origin.y + titleRect.size.height))
        
        return SIMD2(Int(leftPadding + rightPadding), Int(topPadding + bottomPadding))
    }
}

public final class NSCustomButton: NSView {
    static let horizontalPadding: CGFloat = 12.0
    static let verticalPadding: CGFloat = 4.0

    fileprivate var action: (() -> Void)?
    fileprivate let cell = NSButtonCell()
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

    init() {
        cell.title = ""
        cell.isBordered = true
        cell.bezelStyle = .flexiblePush
        super.init()
    }

    public required init?(coder: NSCoder) {
        cell.title = ""
        cell.isBordered = true
        cell.bezelStyle = .flexiblePush
        super.init(coder: coder)
    }

    override public init(frame frameRect: NSRect) {
        cell.title = ""
        cell.isBordered = true
        cell.bezelStyle = .flexiblePush
        super.init(frame: frameRect)
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
        if buttonStyle.shouldRenderNativeBackground {
            cell.drawBezel(withFrame: self.bounds, in: self)
        }

        super.draw(dirtyRect)
    }

    override public var acceptsFirstResponder: Bool {
        // Even though its called FullKeyboardAccess, it actuall corresponds to
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

    fileprivate func setupConstraints() {
        guard let child = subviews.first else { return }

        NSLayoutConstraint.activate([
            child.centerXAnchor.constraint(equalTo: centerXAnchor),
            child.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}

extension ButtonStyle.Kind {
    fileprivate func applyModifications(_ button: NSCustomButton) {
        switch self {
            case .bordered:
                button.cell.isEnabled = button.isEnabled
                button.cell.isHighlighted = button.isHighlighted
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
                button.cell.drawFocusRingMask(withFrame: button.bounds, in: button)
            case .plain, .borderless:
                let maskPath = NSBezierPath(rect: button.bounds)
                maskPath.fill()
        }
    }
}
