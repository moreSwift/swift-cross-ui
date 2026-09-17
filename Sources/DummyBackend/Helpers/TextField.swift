@_spi(Backends) import SwiftCrossUI

extension DummyBackend {
    public class TextField: Widget {
        public var isSecure: Bool
        public var value = ""
        public var placeholder = ""
        public var font: Font.Resolved?
        public var changeHandler: ((String) -> Void)?
        public var submitHandler: (() -> Void)?

        init(isSecure: Bool) {
            self.isSecure = isSecure
        }
    }
}
