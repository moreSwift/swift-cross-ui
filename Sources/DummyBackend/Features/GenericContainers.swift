@_spi(Backends) import SwiftCrossUI

extension DummyBackend: BackendFeatures.GenericContainers {
    public func createContainer() -> Widget {
        Container()
    }

    public func removeAllChildren(of container: Widget) {
        (container as! Container).children = []
    }

    public func insert(_ child: Widget, into container: Widget, at index: Int) {
        (container as! Container).children.insert((child, .zero), at: index)
    }

    public func swap(childAt firstIndex: Int, withChildAt secondIndex: Int, in container: Widget) {
        (container as! Container).children.swapAt(firstIndex, secondIndex)
    }

    public func setPosition(ofChildAt index: Int, in container: Widget, to position: SIMD2<Int>) {
        (container as! Container).children[index].position = position
    }

    public func remove(childAt index: Int, from container: Widget) {
        let container = container as! Container
        container.children.remove(at: index)
    }
}
