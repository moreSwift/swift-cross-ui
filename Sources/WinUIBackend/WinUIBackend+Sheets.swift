import SwiftCrossUI
import UWP
import WinUI
import WindowsFoundation
import CWinRT
import WinSDK

// swiftlint:disable force_try

extension WinUIBackend: BackendFeatures.Sheets {
    public class Sheet: ContentDialog {
        var dismissHandler: (() -> Void)?
    }

    public func createSheet(content: Widget) -> Sheet {
        let sheet = Sheet()
        sheet.content = content

        // When all buttons are unlabelled, WinUI hides the actions section of
        // the dialog automatically.
        sheet.primaryButtonText = ""
        sheet.secondaryButtonText = ""
        sheet.closeButtonText = ""

        // Sometimes the sheet will have its own default escape key handling,
        // and sometimes it won't. This accelerator is for the cases where it
        // doesn't. It's not exactly clear what determines whether this
        // accelerator is required, but from some testing it seems that sheets
        // without interactive content don't have escape key handling by default
        // (e.g. sheets with only text).
        let accelerator = WinUI.KeyboardAccelerator()
        accelerator.key = .escape
        accelerator.invoked.addHandler { [weak sheet] _, _ in
            guard let sheet else { return }
            try! sheet.hide()
            sheet.dismissHandler?()
        }
        sheet.keyboardAccelerators.append(accelerator)
        sheet.keyboardAcceleratorPlacementMode = .hidden

        // The top portion of a ContentDialog (the dialog portion) is an
        // overlay with its own background color. We hide the action portion
        // of the dialog to use it as a sheet, so we remove the overlay
        // background and simply use the dialog's background property to
        // control the background color of the sheet.
        _ = sheet.resources.insert("ContentDialogTopOverlay", nil)
        _ = sheet.resources.insert("ContentDialogSeparatorBorderBrush", nil)
        _ = sheet.resources.insert("ContentDialogMaxWidth", 1000000 as Double)
        _ = sheet.resources.insert("ContentDialogMinWidth", 0 as Double)
        _ = sheet.resources.insert("ContentDialogMaxHeight", 1000000 as Double)
        _ = sheet.resources.insert("ContentDialogMinHeight", 0 as Double)

        return sheet
    }

    public func updateSheet(
        _ sheet: Sheet,
        window: Window,
        environment: EnvironmentValues,
        size: SIMD2<Int>,
        onDismiss: @escaping () -> Void,
        cornerRadius: Double?,
        detents _: [PresentationDetent],
        dragIndicatorVisibility _: SwiftCrossUI.Visibility,
        backgroundColor: SwiftCrossUI.Color.Resolved?,
        interactiveDismissDisabled: Bool
    ) {
        sheet.width = Double(size.x)
        sheet.height = Double(size.y)
        sheet.dismissHandler = onDismiss

        if let backgroundColor {
            sheet.background = WinUI.SolidColorBrush(backgroundColor.uwpColor)
        } else {
            try! sheet.clearValue(Sheet.backgroundProperty)
        }

        sheet.requestedTheme = switch environment.colorScheme {
            case .light: .light
            case .dark: .dark
        }
    }

    public func presentSheet(
        _ sheet: Sheet,
        window: Window,
        parentSheet: Sheet?
    ) {
        sheet.xamlRoot = window.content.xamlRoot
        do {
            let promise = try sheet.showAsync()!
            promise.completed = { [weak sheet] _, status in
                guard let sheet, status == .completed else {
                    return
                }

                sheet.dismissHandler?()
            }
        } catch {
            // Force tries don't print properly in some Windows environments, and this
            // is a particularly useful error to have access to, because there are legitimate
            // edge cases under which this could be triggered
            print("Error: \(error)")
            fatalError("\(error)")
        }
    }

    public func dismissSheet(_ sheet: Sheet, window: Window, parentSheet: Sheet?) {
        print("Dismissing sheet programmatically")
        try! sheet.hide()
    }

    public func size(ofSheet sheet: Sheet) -> SIMD2<Int> {
        .zero
    }
}
