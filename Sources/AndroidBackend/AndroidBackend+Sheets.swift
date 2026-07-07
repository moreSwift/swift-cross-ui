import AndroidKit
@_spi(Backends) import SwiftCrossUI

extension AndroidBackend: BackendFeatures.Sheets {
    public typealias Sheet = CustomSheet

    public func createSheet(content: Widget) -> CustomSheet {
        CustomSheet(content, environment: Self.env)
    }

    public func size(ofSheet sheet: CustomSheet) -> SIMD2<Int> {
        if let content = sheet.getContent() {
            let width = helpers.getSafeWindowWidth(Self.activity)
            let widthMeasureSpec = (width & 0x3FFFFFFF) | 0x40000000
            content.measure(widthMeasureSpec, 0x3FFFFFFF)
            let density = content.getResources().getDisplayMetrics().density
            let height = Float(content.getMeasuredHeight()) / density
            return SIMD2(Int(width), Int(height.rounded(.up)))
        } else {
            return .zero
        }
    }

    public func presentSheet(_ sheet: CustomSheet, window: Window, parentSheet: CustomSheet?) {
        let fragmentManager =
            parentSheet?.getChildFragmentManager() ?? Self.activity.as(FragmentActivity.self)!
                .getSupportFragmentManager()
        sheet.show(fragmentManager, "CustomSheet")
    }

    public func dismissSheet(_ sheet: CustomSheet, window: Window, parentSheet: CustomSheet?) {
        sheet.dismiss()
    }

    public func updateSheet(
        _ sheet: CustomSheet,
        window: Window,
        environment: EnvironmentValues,
        size: SIMD2<Int>,
        onDismiss: @escaping () -> Void,
        cornerRadius: Double?,
        detents: [PresentationDetent],
        dragIndicatorVisibility: Visibility,
        backgroundColor: SwiftCrossUI.Color.Resolved?,
        interactiveDismissDisabled: Bool
    ) {
        // cornerRadius intentionally ignored, as Material doesn't appear to support dynamic corner
        // radius (it has to come from an XML file).
        // detents currently ignored, as the background color doesn't seem to behave correctly
        // when the sheet is taller than its contents.
        // TODO(bbrk24): Fix the background behavior and implement detents.
        // dragIndicatorVisibility intentionally ignored, as Android doesn't seem to have that.

        sheet.setOnDismissListener(SwiftAction(environment: Self.env, action: onDismiss))

        let backgroundColorInt =
            if let backgroundColor {
                backgroundColor.asColorInt()
            } else {
                switch environment.colorScheme {
                    case .dark:
                        // The default sheet background color in dark mode is a grayish color, not
                        // black, but there doesn't seem to be a publicly-exposed resource ID for it
                        // either. This was color-picked from an emulator.
                        Int32(bitPattern: 0xff25232b)
                    case .light:
                        // white
                        Int32(bitPattern: 0xffffffff)
                }
            }

        sheet.update(!interactiveDismissDisabled, backgroundColorInt)
    }
}
