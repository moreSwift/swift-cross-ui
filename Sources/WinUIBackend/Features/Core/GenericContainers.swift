@_spi(Backends) import SwiftCrossUI
import WinUI

extension WinUIBackend: BackendFeatures.GenericContainers {
    public func createContainer() -> Widget {
        Canvas()
    }

    public func removeAllChildren(of container: Widget) {
        let container = container as! Canvas
        container.children.clear()
    }

    public func insert(_ child: Widget, into container: Widget, at index: Int) {
        let container = container as! Canvas
        container.children.insertAt(UInt32(index), child)
    }

    public func swap(childAt firstIndex: Int, withChildAt secondIndex: Int, in container: Widget) {
        // TODO: Find out if there's an efficient way to do this without WinUI
        //   getting annoyed at us for having the same element in the list twice.
        let container = container as! Canvas
        let largerIndex = UInt32(max(firstIndex, secondIndex))
        let smallerIndex = UInt32(min(firstIndex, secondIndex))
        let element1 = container.children[Int(smallerIndex)]
        let element2 = container.children[Int(largerIndex)]
        container.children.removeAt(largerIndex)
        container.children.removeAt(smallerIndex)
        container.children.insertAt(smallerIndex, element2)
        container.children.insertAt(largerIndex, element1)
    }

    public func remove(childAt index: Int, from container: Widget) {
        let container = container as! Canvas
        container.children.removeAt(UInt32(index))
    }

    public func setPosition(ofChildAt index: Int, in container: Widget, to position: SIMD2<Int>) {
        let container = container as! Canvas
        guard let child = container.children.getAt(UInt32(index)) else {
            logger.warning("child to set position of not found")
            return
        }

        Canvas.setTop(child, Double(position.y))
        Canvas.setLeft(child, Double(position.x))
    }
}
