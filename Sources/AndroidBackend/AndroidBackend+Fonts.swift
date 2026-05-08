import AndroidKit
import SwiftCrossUI
import SwiftJava

extension AndroidKit.TextView {
    @JavaMethod
    func setTypeface(_ tf: AndroidKit.Typeface?)
}

// swiftlint:disable force_try
extension AndroidBackend {
    struct TextStyle {
        var color: Int32
        var fontSizePixels: Float
        var lineHeightPixels: Int32
        var typeface: AndroidKit.Typeface

        func apply(to textView: AndroidKit.TextView) {
            let typedValue = try! JavaClass<AndroidKit.TypedValue>()

            textView.setTypeface(typeface)
            textView.setTextColor(color)
            textView.setTextSize(typedValue.COMPLEX_UNIT_PX, fontSizePixels)
            textView.setLineHeight(lineHeightPixels)
        }
    }

    func getTextStyle(from environment: EnvironmentValues) -> TextStyle {
        let resolvedFont = environment.resolvedFont

        let typefaceClass = try! JavaClass<AndroidKit.Typeface>()

        let baseTypeface =
            switch resolvedFont.design {
                case .default: typefaceClass.DEFAULT
                case .monospaced: typefaceClass.MONOSPACE
            }

        let weightInt: Int32 =
            switch resolvedFont.weight {
                case .ultraLight: 100
                case .thin: 200
                case .light: 300
                case .regular: 400
                case .medium: 500
                case .semibold: 600
                case .bold: 700
                case .heavy: 800
                case .black: 900
            }

        let typeface = typefaceClass.create(baseTypeface, weightInt, resolvedFont.isItalic)!

        let colorInt = environment.suggestedForegroundColor.resolve(in: environment).asColorInt()

        return TextStyle(
            color: colorInt,
            fontSizePixels: Float(resolvedFont.pointSize),
            lineHeightPixels: Int32(resolvedFont.lineHeight),
            typeface: typeface
        )
    }

    public func resolveTextStyle(
        _ textStyle: SwiftCrossUI.Font.TextStyle
    ) -> SwiftCrossUI.Font.TextStyle.Resolved {
        // Android seems to only have four distinct built-in font sizes. These ratios were chosen
        // to more closely match iOS while still respecting system font size preferences.
        let textSize =
            switch textStyle {
                case .largeTitle: helpers.getLargeTextSize(Self.activity) * 1.53
                case .title: helpers.getLargeTextSize(Self.activity) * 1.29
                case .title2: helpers.getLargeTextSize(Self.activity)
                case .title3: helpers.getTitleTextSize(Self.activity)
                case .headline: helpers.getMediumTextSize(Self.activity)
                case .subheadline: helpers.getSmallTextSize(Self.activity) * 1.15
                case .body: helpers.getMediumTextSize(Self.activity)
                case .callout: helpers.getMediumTextSize(Self.activity) * 0.941
                case .caption: helpers.getSmallTextSize(Self.activity) * 0.923
                case .caption2: helpers.getSmallTextSize(Self.activity) * 0.846
                case .footnote: helpers.getSmallTextSize(Self.activity)
            }
        
        // Android's default system styles all seem to have line height = font size, which doesn't
        // match any other platform and can be a bit cramped. The 1.15 here is somewhat arbitrary
        // but makes it match other platforms a bit more closely.
        let lineHeight = Double(textSize) * 1.15

        // TODO(bbrk24): Update this once everything else uses dp
        return SwiftCrossUI.Font.TextStyle.Resolved(
            pointSize: Double(textSize),
            weight: textStyle == .headline ? .semibold : .regular,
            emphasizedWeight: .semibold,
            lineHeight: lineHeight
        )
    }
}
