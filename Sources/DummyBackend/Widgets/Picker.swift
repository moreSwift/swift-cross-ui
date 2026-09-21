@_spi(Backends) import SwiftCrossUI

extension DummyBackend {
    public class Picker: Widget {
        let style: BackendPickerStyle
        var selectedIndex: Int?
        var options: [String] = []
        var onChange: ((Int?) -> Void)?
        var enabled = true

        init(style: BackendPickerStyle) {
            self.style = style
            super.init()
        }
    }
}
