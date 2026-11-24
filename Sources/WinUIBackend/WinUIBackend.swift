import CWinRT
import Foundation
@_spi(Backends) import SwiftCrossUI
import UWP
import WinAppSDK
import WinSDK
import WinUI
import WinUIInterop
@preconcurrency import WindowsFoundation
import Mutex

// Many force tries are required for the WinUI backend but we don't really want them
// anywhere else so just disable the lint rule at a file level.
// swiftlint:disable force_try

extension App {
    public typealias Backend = WinUIBackend

    public var backend: WinUIBackend {
        WinUIBackend(urlSchemes: Self.metadata?.urlSchemes?.map(\.scheme))
    }
}

public final class WinUIBackend {
    // Logging
    private struct LogLocation: Hashable, Equatable {
        let file: String
        let line: Int
        let column: Int
    }

    private var logsPerformed: Set<LogLocation> = []

    func debugLogOnce(
        _ message: String,
        file: String = #file,
        line: Int = #line,
        column: Int = #column
    ) {
        #if DEBUG
        let location = LogLocation(file: file, line: line, column: column)
        if logsPerformed.insert(location).inserted {
            logger.notice("\(message)")
        }
        #endif
    }

    public let defaultTableRowContentHeight = 20
    public let defaultTableCellVerticalPadding = 4
    var borderedButtonPadding: SIMD2<Int>?

    class InternalState {
        var buttonClickActions: [ObjectIdentifier: () -> Void] = [:]
        var toggleClickActions: [ObjectIdentifier: (Bool) -> Void] = [:]
        var switchClickActions: [ObjectIdentifier: (Bool) -> Void] = [:]
        var sliderChangeActions: [ObjectIdentifier: (Double) -> Void] = [:]
        var textFieldChangeActions: [ObjectIdentifier: (String) -> Void] = [:]
        var textFieldSubmitActions: [ObjectIdentifier: () -> Void] = [:]
    }
    var rootEnvironmentChangeHandler: (@Sendable @MainActor () -> Void)?

    var internalState: InternalState
    nonisolated(unsafe) var dispatcherQueue: WinAppSDK.DispatcherQueue?

    var windows: [Window] = []

    var measurementTextBlock: TextBlock! 

    struct Error: LocalizedError {
        var message: String

        var errorDescription: String? {
            message
        }
    }

    var incomingURLHandler: ((URL) -> Void)?

    public init(urlSchemes: [String]?) {
        internalState = InternalState()
        WinUIApplication.urlSchemes.withLock { schemes in
            schemes = urlSchemes ?? []
        }
    }

    func processActivationArguments(_ args: AppActivationArguments) {
        if args.kind == .protocol {
            if let data = args.data as? IProtocolActivatedEventArgs {
                let urlString = data.uri.absoluteUri
                if let url = URL(string: urlString) {
                    self.incomingURLHandler?(url)
                } else {
                    logger.warning("Failed to parse activation URL: \(urlString)")
                }
            } else {
                logger.warning("Failed to get activation URL")
            }
        }
    }

    /// Some elements don't get their default padding/border applied until
    /// they've been rendered. For such elements we have to compute our own
    /// adjustment factors based off values taken from WinUI's default theme.
    /// We can detect such elements because their padding property will be set
    /// to zero until first render (and atm WinUIBackend doesn't set this padding
    /// property itself so this is a safe detection method).
    @MainActor
    public static func sizeCorrection(for widget: Widget) -> SIMD2<Int> {
        let adjustment: SIMD2<Int>
        let noPadding = Thickness(left: 0, top: 0, right: 0, bottom: 0)
        let computedSize = widget.desiredSize
        if let button = widget as? WinUI.Button, button.padding == noPadding {
            // WinUI buttons have padding, but the `padding` property returns
            // zero until the button has been rendered at least once. And even
            // if you manually set the button's padding, it gets ignored by
            // `measure()` before first render.
            //
            // The default in my Windows 11 VM seems to be 11 pixels either
            // side, 5 pixels above, and 6 pixels below. I found this hardcoded
            // in the WinUI repository, so hopefully it is the same everywhere...
            // Hardcoded here: https://github.com/microsoft/microsoft-ui-xaml/blob/650b2c1bad272393400403ca323b3cb8745f95d0/src/controls/dev/CommonStyles/Button_themeresources.xaml#L116
            //
            // We'll have to find a more dynamic way of correcting for WinUI's
            // measurement weirdness at some point (which will probably involve
            // figuring out how to access the `ButtonPadding` resource value
            // from Swift).
            //
            // Buttons seem to have 1 pixel of border on each side which also
            // gets ignored before first render.
            adjustment = SIMD2(
                11 + 11 + 2,
                5 + 6 + 2
            )
        } else if let toggleButton = widget as? WinUI.ToggleButton,
            toggleButton.padding == noPadding
            {
            // See the above comment regarding Button. Very similar situation.
            adjustment = SIMD2(
                11 + 11 + 2,
                5 + 6 + 2
            )
        } else if let textField = widget as? TextBoxProtocol, textField.padding == noPadding {
            // The default padding applied to text boxes can be found here:
            // https://github.com/microsoft/microsoft-ui-xaml/blob/650b2c1bad272393400403ca323b3cb8745f95d0/src/controls/dev/CommonStyles/Common_themeresources.xaml#L12
            // However, text fields return 0x0 before rendering so our adjustment
            // just has to be the entire size of the text field. I've currently just
            // hardcoded a value obtained from one of my example apps.
            adjustment = SIMD2(64, 32)
        } else if widget is CalendarView {
            // I don't actually know why this is necessary, but without it the abbreviations for the
            // weekdays wrap, making it taller than it says it is. Value was derived by trial and
            // error.
            adjustment = SIMD2(20, 0)
        } else if
            computedSize.width == 0 && computedSize.height == 0 && widget is CalendarDatePicker
            {
            // I can't find any source on what the size of CalendarDatePicker is, but it reports 0x0
            // in at least some cases before initial render. In these cases, use a size derived
            // experimentally.
            adjustment = SIMD2(116, 32)
        } else {
            adjustment = .zero
        }
        return adjustment
    }

    func updateInputScope(
        of textField: some TextBoxProtocol,
        textContentType: TextContentType
    ) {

        let inputScope: InputScopeNameValue? =
        switch textField {
        case is TextBox:
            switch textContentType {
            case .decimal(_): .number
            case .digits(_): .digits
            case .emailAddress: .emailSmtpAddress
            case .name: .personalFullName
            case .phoneNumber: .telephoneNumber
            case .text: .default
            case .url: .url
            }
        case is PasswordBox:
            switch textContentType {
            case .digits(_): .numericPin
            case .text: .password
            default: nil
            }
        default: nil
        }
        guard let inputScope else { return }

        let inputScopeName = InputScopeName(inputScope)

        if let inputScope = textField.inputScope,
            inputScope.names.count == 1
            {
            inputScope.names[0] = inputScopeName
        } else {
            let inputScope = InputScope()
            inputScope.names.append(inputScopeName)
            textField.inputScope = inputScope
        }
    }

    /// A helper method that abstracts out the common failure case handling code
    /// from all of our file dialog related async operation completion handlers.
    static func handleAsyncOperationCompletion<T, R>(
        _ operation: AnyIAsyncOperation<T?>?,
        _ status: AsyncStatus,
        onSuccess handleSuccess: (T) -> R,
        onFailure handleFailure: () -> R
    ) -> R {
        guard let operation else {
            logger.warning(
                "operation parameter unexpectedly nil",
                metadata: [
                    "function": #function
                ]
            )
            return handleFailure()
        }

        guard
            status == .completed,
            let result = try? operation.getResults()
        else {
            if status == .error {
                logger.error(
                    "\(WindowsFoundation.Error(hr: operation.errorCode))",
                    metadata: [
                        "function": #function
                    ]
                )

                if UInt32(bitPattern: operation.errorCode) == 0x80004005 {
                    // https://github.com/microsoft/WindowsAppSDK/issues/4625#issuecomment-2281358235
                    logger.warning(
                        """
                        This may indicate that you're attempting to launch a \
                        file picker from an app launched as administrator
                        """
                    )
                }
            }
            return handleFailure()
        }

        return handleSuccess(result)
    }

    // public func createTable(rows: Int, columns: Int) -> Widget {
    //     let grid = Grid()
    //     grid.columnSpacing = 10
    //     grid.rowSpacing = 10
    //     for _ in 0..<rows {
    //         let rowDefinition = RowDefinition()
    //         rowDefinition.height = GridLength(value: 0, gridUnitType: .auto)
    //         grid.rowDefinitions.append(rowDefinition)
    //     }

    //     for _ in 0..<columns {
    //         let columnDefinition = ColumnDefinition()
    //         columnDefinition.width = GridLength(value: 0, gridUnitType: .auto)
    //         grid.columnDefinitions.append(columnDefinition)
    //     }
    //     return grid
    // }

    // public func setRowCount(ofTable table: Widget, to rows: Int) {
    //     let grid = table as! Grid
    //     grid.rowDefinitions.clear()
    //     for _ in 0..<rows {
    //         let rowDefinition = RowDefinition()
    //         rowDefinition.height = GridLength(value: 0, gridUnitType: .auto)
    //         grid.rowDefinitions.append(rowDefinition)
    //     }
    // }

    // public func setColumnCount(ofTable table: Widget, to columns: Int) {
    //     let grid = table as! Grid
    //     grid.columnDefinitions.clear()
    //     for _ in 0..<columns {
    //         let columnDefinition = ColumnDefinition()
    //         columnDefinition.width = GridLength(value: 0, gridUnitType: .auto)
    //         grid.columnDefinitions.append(columnDefinition)
    //     }
    // }

    // public func setCell(at position: CellPosition, inTable table: Widget, to widget: Widget) {
    //     let grid = table as! Grid
    //     Grid.setColumn(widget, Int32(position.column))
    //     Grid.setRow(widget, Int32(position.row))
    //     grid.children.append(widget)
    // }
}

extension EnvironmentValues {
    @MainActor
    var winUIForegroundBrush: WinUI.Brush {
        let brush = SolidColorBrush()
        brush.color = suggestedForegroundColor.resolve(in: self).uwpColor
        return brush
    }

    @MainActor
    func apply(to control: WinUI.Control) {
        let resolvedFont = resolvedFont
        control.fontSize = resolvedFont.pointSize
        control.fontWeight.weight = resolvedFont.winUIFontWeight
        control.foreground = winUIForegroundBrush
        control.isEnabled = isEnabled
        if resolvedFont.isItalic {
            control.fontStyle = .italic
        }
        switch colorScheme {
            case .light:
                control.requestedTheme = .light
            case .dark:
                control.requestedTheme = .dark
        }
    }

    @MainActor
    func apply(to textBlock: WinUI.TextBlock) {
        let resolvedFont = resolvedFont
        textBlock.fontSize = resolvedFont.pointSize
        textBlock.fontWeight.weight = resolvedFont.winUIFontWeight
        textBlock.foreground = winUIForegroundBrush
        textBlock.lineHeight = resolvedFont.lineHeight

        if resolvedFont.isItalic {
            textBlock.fontStyle = .italic
        }
    }
}

extension Font.Resolved {
    var winUIFontWeight: UInt16 {
        switch weight {
            case .ultraLight:
                100
            case .thin:
                200
            case .light:
                300
            case .regular:
                400
            case .medium:
                500
            case .semibold:
                600
            case .bold:
                700
            case .heavy:
                800
            case .black:
                900
        }
    }
}

class SwiftIInitializeWithWindow: WindowsFoundation.IUnknown {
    override class var IID: WindowsFoundation.IID {
        WindowsFoundation.IID(
            Data1: 0x3E68_D4BD,
            Data2: 0x7135,
            Data3: 0x4D10,
            Data4: (0x80, 0x18, 0x9F, 0xB6, 0xD9, 0xF3, 0x3F, 0xA1)
        )
    }

    func initialize(with hwnd: HWND) throws {
        _ = try perform(as: IInitializeWithWindow.self) { pThis in
            try CHECKED(pThis.pointee.lpVtbl.pointee.Initialize(pThis, hwnd))
        }
    }
}

extension WinUI.FrameworkElement {
    var shouldBlockNextChangedSignal: Bool {
        get {
            (self.tag as? [String: Any])?["shouldBlockNextChangedSignal"] as? Bool ?? false
        }
        set {
            var value = self.tag as? [String: Any] ?? [:]
            value["shouldBlockNextChangedSignal"] = newValue
            self.tag = value
        }
    }
}
