@_spi(Backends) import SwiftCrossUI

extension DummyBackend: BackendFeatures.Widgets {
    public var defaultPaddingAmount: Int { 10 }

    public func show(widget: Widget) {}

    public func tag(widget: Widget, as tag: String) {
        widget.tag = tag
    }

    public func naturalSize(of widget: Widget) -> SIMD2<Int> {
        widget.naturalSize
    }

    public func setSize(of widget: Widget, to size: SIMD2<Int>) {
        widget.size = size
    }
}
