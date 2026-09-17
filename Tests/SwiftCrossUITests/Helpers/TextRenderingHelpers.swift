@_spi(Backends) import SwiftCrossUI
import DummyBackend

enum TextRenderingHelpers {
    @MainActor
    static var defaultFont: Font.Resolved {
        ViewGraphHelpers.environment.resolvedFont
    }

    @MainActor
    static func sizeOfText(
        _ text: String,
        textWidget: DummyBackend.Widget,
        proposedSize: ProposedViewSize = .unspecified
    ) -> SIMD2<Int> {
        var proposedWidth: Int?
        var proposedHeight: Int?

        if let width = proposedSize.width {
            proposedWidth = Int(width)
        }
        if let height = proposedSize.height {
            proposedHeight = Int(height)
        }

        return ViewGraphHelpers.backend.size(
            of: text,
            whenDisplayedIn: textWidget,
            proposedWidth: proposedWidth,
            proposedHeight: proposedHeight,
            environment: ViewGraphHelpers.environment
        )
    }
}
