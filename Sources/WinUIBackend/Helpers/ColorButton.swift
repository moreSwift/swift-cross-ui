import WinUI
import UWP
import WindowsFoundation

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
