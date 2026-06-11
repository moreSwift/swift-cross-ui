import AppKit
import SwiftCrossUI

extension AppKitBackend {
    public func size(
        of text: String,
        whenDisplayedIn widget: Widget,
        proposedWidth: Int?,
        proposedHeight: Int?,
        environment: EnvironmentValues
    ) -> SIMD2<Int> {
        let proposedSize = NSSize(
            width: proposedWidth.map(Double.init) ?? .greatestFiniteMagnitude,
            height: proposedHeight.map(Double.init) ?? .greatestFiniteMagnitude
        )
        let rect = NSString(string: text).boundingRect(
            with: proposedSize,
            options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine],
            attributes: Self.attributes(forTextIn: environment)
        )

        var height = rect.size.height

        if let lineLimitSettings = environment.lineLimitSettings {
            let limitedHeight =
                Double(max(lineLimitSettings.limit, 1)) * environment.resolvedFont.lineHeight

            if limitedHeight < height || lineLimitSettings.reservesSpace {
                height = limitedHeight
            }
        }

        return SIMD2(
            Int(rect.size.width.rounded(.awayFromZero)),
            Int(height.rounded(.awayFromZero))
        )
    }

    public func createTextView() -> Widget {
        let field = NSTextField(wrappingLabelWithString: "")
        // Somewhat unintuitively, this changes the behaviour of the text field even
        // though it's not editable. It prevents the text from resetting to default
        // styles when clicked (yeah that happens...)
        field.allowsEditingTextAttributes = true
        field.isSelectable = false
        field.cell?.truncatesLastVisibleLine = true
        return field
    }

    public func updateTextView(
        _ textView: Widget,
        content: String,
        environment: EnvironmentValues
    ) {
        let field = textView as! NSTextField
        field.attributedStringValue = Self.attributedString(for: content, in: environment)
        if field.isSelectable && !environment.isTextSelectionEnabled {
            field.abortEditing()
        }
        field.isSelectable = environment.isTextSelectionEnabled
    }

    internal static func attributedString(
        for text: String,
        in environment: EnvironmentValues
    ) -> NSAttributedString {
        NSAttributedString(
            string: text,
            attributes: attributes(forTextIn: environment)
        )
    }

    private static func attributes(
        forTextIn environment: EnvironmentValues
    ) -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment =
            switch environment.multilineTextAlignment {
                case .leading:
                    .left
                case .center:
                    .center
                case .trailing:
                    .right
            }

        let resolvedFont = environment.resolvedFont

        // This is definitely what these properties were intended for
        paragraphStyle.minimumLineHeight = CGFloat(resolvedFont.lineHeight)
        paragraphStyle.maximumLineHeight = CGFloat(resolvedFont.lineHeight)
        paragraphStyle.lineSpacing = 0

        return [
            .foregroundColor: environment.suggestedForegroundColor.resolve(in: environment).nsColor,
            .font: font(for: resolvedFont),
            .paragraphStyle: paragraphStyle,
        ]
    }

    static func font(for font: Font.Resolved) -> NSFont {
        let size = CGFloat(font.pointSize)
        let weight = weight(for: font.weight)

        let nsFont: NSFont
        switch font.identifier.kind {
            case .system:
                switch font.design {
                    case .default:
                        nsFont = NSFont.systemFont(ofSize: size, weight: weight)
                    case .monospaced:
                        nsFont = NSFont.monospacedSystemFont(ofSize: size, weight: weight)
                }
        }

        if font.isItalic {
            return NSFontManager.shared.convert(nsFont, toHaveTrait: .italicFontMask)
        } else {
            return nsFont
        }
    }

    private static func weight(for weight: Font.Weight) -> NSFont.Weight {
        switch weight {
            case .thin:
                .thin
            case .ultraLight:
                .ultraLight
            case .light:
                .light
            case .regular:
                .regular
            case .medium:
                .medium
            case .semibold:
                .semibold
            case .bold:
                .bold
            case .black:
                .black
            case .heavy:
                .heavy
        }
    }
}
