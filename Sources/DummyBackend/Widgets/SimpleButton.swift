@_spi(Backends) import SwiftCrossUI
extension DummyBackend {
    public class SimpleButton: Widget {
        public var label = ""
        public var font: Font.Resolved?
        public var action: (() -> Void)?
        public var menu: Menu?

        /// Menu sizes its button widget through `naturalSize(of:)`, so leaving
        /// this at zero renders zero-sized menu buttons.
        override public var naturalSize: SIMD2<Int> {
            guard let font else { return .zero }
            let labelSize = DummyBackend.textSize(
                of: label,
                displayedWith: font,
                proposedWidth: nil,
                proposedHeight: nil
            )
            let horizontalPadding = 10
            let verticalPadding = 5
            return SIMD2(
                labelSize.x + horizontalPadding * 2,
                labelSize.y + verticalPadding * 2
            )
        }
    }
}
