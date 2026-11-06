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
        proposedSize: ProposedViewSize = .unspecified
    ) -> SIMD2<Int> {
        let proposedWidth: Int? = proposedSize.width.map(Int.init)
        let proposedHeight: Int? = proposedSize.height.map(Int.init)

        return ViewGraphHelpers.backend.size(
            of: text,
            whenDisplayedIn: DummyBackend.TextView(),
            proposedWidth: proposedWidth,
            proposedHeight: proposedHeight,
            environment: ViewGraphHelpers.environment
        )
    }
}
