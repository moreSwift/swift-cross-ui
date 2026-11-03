import SwiftCrossUI
import WindowsFoundation
import WinUI
import UWP

extension WinUIBackend: BackendFeatures.ColorPickers {
    public func createColorPicker() -> Widget {
        let colorSwatch = createColorableRectangle()
		colorSwatch.horizontalAlignment = HorizontalAlignment.center
		colorSwatch.verticalAlignment = VerticalAlignment.center

        let button = ColorButton()
        button.content = colorSwatch

        button.buttonSizeChangedEventCleanup = button.sizeChanged
            .addHandler({ [weak colorSwatch, weak button] _, args in
                guard let args, let padding = button?.padding else { return }

                colorSwatch?.width = Double(args.newSize.width) - padding.left - padding.right
                colorSwatch?.height = Double(args.newSize.height) - padding.top - padding.bottom
            })
        // TODO: remove on deinit
        return button
    }

    public func updateColorPicker(
        _ colorPicker: Widget,
        supportsOpacity: Bool,
        environment: EnvironmentValues,
        onChange: @escaping (SwiftCrossUI.Color.Resolved) -> Void
    ) {
        let colorButton = colorPicker as! ColorButton
        colorButton.supportsOpacity = supportsOpacity
        colorButton.isEnabled = environment.isEnabled
        colorButton.onChange = { onChange(SwiftCrossUI.Color.Resolved(uwpColor: $0)) }
    }

    public func setValue(ofColorPicker colorPicker: Widget, to color: SwiftCrossUI.Color.Resolved) {
        (colorPicker as! ColorButton).setColor(to: color.uwpColor)
    }
}

// WinUI's ColorPicker class is the control that goes inside the dialog, not the button that opens it.
final class ColorButton: WinUI.Button {
    var buttonSizeChangedEventCleanup: EventCleanup?
    var supportsOpacity = true

    private var dialog: ColorDialog?
    private var color: UWP.Color?

    var onChange: ((UWP.Color) -> Void)?

    override init() {
        super.init()

        self.click.addHandler { [unowned self] _, _ in
            if self.dialog != nil { return }

            let dialog = ColorDialog { [weak self] in self?.dialog = nil }
            dialog.colorPicker.isAlphaEnabled = self.supportsOpacity
            dialog.xamlRoot = self.xamlRoot
            self.dialog = dialog

            if let color {
                dialog.colorPicker.color = color
            }

            do {
                let promise = try dialog.showAsync()!
                promise.completed = { [weak self] (operation, status) in
                    guard let self, status == .completed else {
                        return
                    }

                    defer { self.dialog = nil }

                    if self.isEnabled, let operation, let result = try? operation.getResults() {
                        switch result {
                            case .primary:
                                self.onChange?(dialog.colorPicker.color)
                            case .none:
                                break
                            default:
                                fatalError("WinUIBackend: Invalid dialog response")
                        }
                    }
                }
            } catch {
                // Force tries don't print properly in some Windows environments, and this
                // is a particularly useful error to have access to, because there are legitimate
                // edge cases under which this could be triggered
                print("Error: \(error)")
                fatalError("\(error)")
            }
        }
    }

    func setColor(to color: UWP.Color) {
        let canvas = content as! Canvas
        let brush = WinUI.SolidColorBrush()
        brush.color = color
        canvas.background = brush

        self.color = color
    }

    deinit {
        buttonSizeChangedEventCleanup?.dispose()
    }
}

final class ColorDialog: WinUI.ContentDialog {
    var colorPicker = WinUI.ColorPicker()
    var onDismiss: () -> Void

    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss

        super.init()

        self.colorPicker.orientation = .horizontal

        self.content = self.colorPicker
        self.primaryButtonText = "Submit"
        self.secondaryButtonText = ""
        self.closeButtonText = "Cancel"
    }
}
