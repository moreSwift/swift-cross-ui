import SwiftCrossUI
import UIKit
import UIKitCompatKit

extension UIKitBackend {
    static func attributedString(
        text: String,
        environment: EnvironmentValues,
        defaultForegroundColor: UIColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1) //Changed for now
    ) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment =
            switch environment.multilineTextAlignment {
                case .center:
                    .center
                case .leading:
                    .natural
                case .trailing:
                    //UITraitCollection.current.layoutDirection == .rightToLeft ? .left : .right
                    .center //I don't know how to fix this right now
            }
        paragraphStyle.lineBreakMode = .byWordWrapping

        // This is definitely what these properties were intended for
        let resolvedFont = environment.resolvedFont
        paragraphStyle.minimumLineHeight = CGFloat(resolvedFont.lineHeight)
        paragraphStyle.maximumLineHeight = CGFloat(resolvedFont.lineHeight)
        paragraphStyle.lineSpacing = 0

        return NSAttributedString(
            string: text,
            attributes: [
                .font: resolvedFont.uiFont,
                .foregroundColor: environment.foregroundColor?.uiColor ?? defaultForegroundColor,
                .paragraphStyle: paragraphStyle,
            ]
        )
    }

    public func createTextView() -> Widget {
        let widget = WrapperWidget<UILabel>()
        widget.child.numberOfLines = 0
        return widget
    }

    public func updateTextView(
        _ textView: Widget,
        content: String,
        environment: EnvironmentValues
    ) {
        let wrapper = textView as! WrapperWidget<UILabel>
        
        if #available(iOS 13.0, *) {
            wrapper.child.overrideUserInterfaceStyle = environment.colorScheme.userInterfaceStyle
        }
        
        wrapper.child.attributedText = UIKitBackend.attributedString(
            text: content,
            environment: environment
        )
    }

    public func size(
        of text: String,
        whenDisplayedIn widget: Widget,
        proposedFrame: SIMD2<Int>?,
        environment: EnvironmentValues
    ) -> SIMD2<Int> {
        let attributedString = UIKitBackend.attributedString(text: text, environment: environment)
        let boundingSize =
            if let proposedFrame {
                CGSize(width: CGFloat(proposedFrame.x), height: .greatestFiniteMagnitude)
            } else {
                CGSize(width: .greatestFiniteMagnitude, height: environment.resolvedFont.lineHeight)
            }
        let size = attributedString.boundingRect(
            with: boundingSize,
            options: proposedFrame == nil ? [] : [.usesLineFragmentOrigin],
            context: nil
        )
        return SIMD2(
            Int(size.width.rounded(.awayFromZero)),
            Int(size.height.rounded(.awayFromZero))
        )
    }

    public func createImageView() -> Widget {
        WrapperWidget<UIImageView>()
    }

    public func updateImageView(
        _ imageView: Widget,
        rgbaData: [UInt8],
        width: Int,
        height: Int,
        targetWidth: Int,
        targetHeight: Int,
        dataHasChanged: Bool,
        environment: EnvironmentValues
    ) {
        guard dataHasChanged else { return }
        let wrapper = imageView as! WrapperWidget<UIImageView>
        let ciImage = CIImage(
            bitmapData: Data(rgbaData),
            bytesPerRow: width * 4,
            size: CGSize(width: CGFloat(width), height: CGFloat(height)),
            format: .RGBA8,
            colorSpace: .init(name: "sRGB" as CFString) //temporary modification lol
        )
        wrapper.child.image = .init(ciImage: ciImage)
    }
}
