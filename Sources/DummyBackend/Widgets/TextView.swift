@_spi(Backends) import SwiftCrossUI

extension DummyBackend {
    public class TextView: Widget {
        public var content: String = ""
        public var font: Font.Resolved?
        public var color = Color.Resolved(red: 0.0, green: 0.0, blue: 0.0)
    }
}
