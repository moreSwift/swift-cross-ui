@_spi(Backends) import SwiftCrossUI

extension DummyBackend: BackendFeatures.TextViews {
    public func size(
        of text: String,
        whenDisplayedIn widget: Widget,
        proposedWidth: Int?,
        proposedHeight: Int?,
        environment: EnvironmentValues
    ) -> SIMD2<Int> {
        Self.textSize(
            of: text,
            displayedWith: environment.resolvedFont,
            proposedWidth: proposedWidth,
            proposedHeight: proposedHeight,
            lineLimit: environment.lineLimitSettings
        )
    }

    /// Single source of truth for DummyBackend's character-metric text sizing.
    nonisolated static func textSize(
        of text: String,
        displayedWith font: Font.Resolved,
        proposedWidth: Int?,
        proposedHeight: Int?,
        lineLimit: LineLimit? = nil,
    ) -> SIMD2<Int> {
        let lineHeight = Int(font.lineHeight)
        let characterHeight = Int(font.pointSize)
        let characterWidth = characterHeight * 2 / 3

        guard let proposedWidth else {
            return SIMD2(
                characterWidth * text.count,
                lineHeight
            )
        }

        let charactersPerLine = max(1, proposedWidth / characterWidth)
        var lineCount = (text.count + charactersPerLine - 1) / charactersPerLine
        if let proposedHeight {
            lineCount = min(max(1, proposedHeight / lineHeight), lineCount)
        }

        if let lineLimit {
            lineCount = min(lineCount, lineLimit.limit)
            if lineLimit.reservesSpace {
                lineCount = max(lineCount, lineLimit.limit)
            }
        }

        return SIMD2(
            characterWidth * min(charactersPerLine, text.count),
            lineHeight * lineCount
        )
    }

    public func createTextView() -> Widget {
        TextView()
    }

    public func updateTextView(
        _ textView: Widget,
        content: String,
        environment: EnvironmentValues
    ) {
        let textView = textView as! TextView
        textView.content = content
        textView.color = environment.suggestedForegroundColor.resolve(in: environment)
        textView.font = environment.resolvedFont
    }
}
