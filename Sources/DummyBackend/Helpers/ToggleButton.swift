@_spi(Backends) import SwiftCrossUI

extension DummyBackend {
    public class ToggleButton: Widget {
        public var label = ""
        public var font: Font.Resolved?
        public var toggleHandler: ((Bool) -> Void)?
        public var state = false
    }
}
