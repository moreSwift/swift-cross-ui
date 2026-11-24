@_spi(Backends) import SwiftCrossUI
import WinUI

extension WinUIBackend: BackendFeatures.TextViews {
    public func size(
        of text: String,
        whenDisplayedIn widget: Widget,
        proposedWidth: Int?,
        proposedHeight: Int?,
        environment: EnvironmentValues
    ) -> SIMD2<Int> {
        // Update the text view's environment and measure its desired line height
        updateTextView(measurementTextBlock, content: text, environment: environment)

        // Measure the text's size
        var size = Self.measure(
            measurementTextBlock,
            proposedWidth: proposedWidth,
            proposedHeight: proposedHeight
        )

        var usedHeight = size.y
        let lineHeight = environment.resolvedFont.lineHeight

        if let lineLimitSettings = environment.lineLimitSettings {
            let height = Int(
                Double(max(lineLimitSettings.limit, 1)) * lineHeight
            )

            if height < usedHeight || lineLimitSettings.reservesSpace {
                usedHeight = height
            }
        }

        // Make sure the text doesn't get shorter than a single line of text even if
        // it's empty.
        size.y = max(usedHeight, Int(lineHeight))
        return size
    }

    private static func measure(
        _ textBlock: TextBlock,
        proposedWidth: Int?,
        proposedHeight: Int?
    ) -> SIMD2<Int> {
        let allocation = WindowsFoundation.Size(
            width: proposedWidth.map(Float.init) ?? .infinity,
            height: proposedHeight.map(Float.init) ?? .infinity
        )
        try! textBlock.measure(allocation)

        let computedSize = textBlock.desiredSize
        return SIMD2(
            Int(computedSize.width),
            Int(computedSize.height)
        )
    }

    public func createTextView() -> Widget {
        let textBlock = TextBlock()
        textBlock.textWrapping = .wrap
        textBlock.textTrimming = .characterEllipsis
        textBlock.lineStackingStrategy = .blockLineHeight
        return textBlock
    }

    public func updateTextView(
        _ textView: Widget,
        content: String,
        environment: EnvironmentValues
    ) {
        let block = textView as! TextBlock
        block.text = content
        block.isTextSelectionEnabled = environment.isTextSelectionEnabled
        // TODO: Font design handling (monospace vs normal)
        environment.apply(to: block)
    }
}
