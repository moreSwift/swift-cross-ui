import SwiftCrossUI
extension DummyBackend {
    public class Button: Widget {
        public var label: Widget?
        public var action: (() -> Void)?
        public var buttonStyle: ButtonStyle = .bordered
    }
}
