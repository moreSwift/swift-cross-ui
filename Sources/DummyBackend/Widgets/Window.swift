@_spi(Backends) import SwiftCrossUI

extension DummyBackend {
    public class Window {
        static let defaultSize = SIMD2<Int>(400, 200)

        public var size: SIMD2<Int>
        public var id: String
        public var minimumSize: SIMD2<Int> = .zero
        public var maximumSize: SIMD2<Int>?
        public var title = "Window"
        public var resizable = true
        public var closable = true
        public var minimizable = true
        public var content: Widget?
        public var resizeHandler: ((SIMD2<Int>) -> Void)?
        public var closeHandler: (() -> Void)?
        public var phase = ScenePhase.inactive
        public var colorScheme = ColorScheme.light

        public init(defaultSize: SIMD2<Int>?, id: String) {
            size = defaultSize ?? Self.defaultSize
            self.id = id
        }
    }
}
