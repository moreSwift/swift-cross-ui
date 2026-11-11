@_spi(Backends) import SwiftCrossUI

extension DummyBackend {
    public class Rectangle: Widget {
        public var color = Color.Resolved(red: 0.0, green: 0.0, blue: 0.0, opacity: 0.0)
    }
}
