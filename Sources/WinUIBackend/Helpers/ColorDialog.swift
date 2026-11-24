import WinUI 

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
