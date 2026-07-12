@_spi(Backends) import SwiftCrossUI
import UWP
import WinUI
import WindowsFoundation
import CWinRT
import WinSDK

// swiftlint:disable force_try

extension WinUIBackend: BackendFeatures.Sheets {
    public class Sheet: ContentDialog {
        var dismissHandler: (() -> Void)?
        var nestedSheet: Sheet?
        weak var parentSheet: Sheet?
        weak var window: Window?
        var isProgrammaticDismissal = false
        var isSuspendedForNestedSheet = false
        var pendingNestedPresentation: Sheet?
        var isPresenting = false
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
        sheet.window = window
        sheet.parentSheet = parentSheet

        if let parentSheet {
            parentSheet.nestedSheet = sheet
            parentSheet.pendingNestedPresentation = sheet
            parentSheet.isSuspendedForNestedSheet = true
            do {
                try parentSheet.hide()
            } catch {
                print("Error: \(error)")
                presentSheetNow(sheet, window: window)
            }
            return
        }

        presentSheetNow(sheet, window: window)
    }

    private func presentSheetNow(_ sheet: Sheet, window: Window) {
        sheet.xamlRoot = window.content.xamlRoot
        sheet.window = window
        sheet.isPresenting = true
        do {
            let promise = try sheet.showAsync()!
            promise.completed = { [weak self, weak sheet, weak window] _, status in
                guard let self, let sheet, status == .completed else {
                    return
                }

                sheet.isPresenting = false

                if sheet.isSuspendedForNestedSheet {
                    sheet.isSuspendedForNestedSheet = false
                    if
                        let nestedSheet = sheet.pendingNestedPresentation,
                        let window = sheet.window ?? window
                    {
                        sheet.pendingNestedPresentation = nil
                        self.presentSheetNow(nestedSheet, window: window)
                    }
                    return
                }

                let wasProgrammaticDismissal = sheet.isProgrammaticDismissal
                sheet.isProgrammaticDismissal = false

                if let parentSheet = sheet.parentSheet {
                    parentSheet.nestedSheet = nil
                    sheet.parentSheet = nil

                    if let window = parentSheet.window ?? window {
                        self.presentSheetNow(parentSheet, window: window)
                    }
                }

                guard !wasProgrammaticDismissal else {
                    return
                }

                sheet.dismissHandler?()
            }
        } catch {
            // WinUI only allows a single ContentDialog per XamlRoot. Nested
            // sheets suspend their parent before presenting; any error that
            // still reaches this point should be visible without crashing the
            // process.
            print("Error: \(error)")
            sheet.isPresenting = false
        }
    }

    public func dismissSheet(_ sheet: Sheet, window: Window, parentSheet: Sheet?) {
        if let nestedSheet = sheet.nestedSheet {
            dismissSheet(nestedSheet, window: window, parentSheet: sheet)
            nestedSheet.dismissHandler?()
        }

        sheet.isProgrammaticDismissal = true
        sheet.isSuspendedForNestedSheet = false
        sheet.pendingNestedPresentation = nil
        parentSheet?.nestedSheet = nil
        do {
            try sheet.hide()
        } catch {
            print("Error: \(error)")
        }
    }

    public func size(ofSheet sheet: Sheet) -> SIMD2<Int> {
        .zero
    }
}
