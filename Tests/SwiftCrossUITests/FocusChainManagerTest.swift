@testable import SwiftCrossUI
import Testing

// Testing the FocusChainManager protocol
// The protocol takes in suggestions from the backend UI framework
// and checks if SwiftCrossUI wants to override it, in which case it checks
// the suggestion after the previous suggestion
//
// A caveat of this Test is, that is needs to fake a focus engine,
// making it implicitly also test the faked focus engine.
@Suite("Testing FocusChainManager")
struct FocusChainManagerTest {
    @Test("Uncached, without disabling")
    func testUncachedAllEnabledSelectionCorrectness() async throws {
        let manager = Manager()
        runAllEnabledTest(on: manager)
    }

    @Test("Cached, without disabling")
    func testCachedAllEnabledSelectionCorrectness() async throws {
        let manager = CachedManager()
        runAllEnabledTest(on: manager)
    }

    @Test("Uncached, with disabling")
    func testUncachedPartiallyDisabledSelectionCorrectness() async throws {
        runOneDisabledTest(on: Manager(), disabled: 0)
        runOneDisabledTest(on: Manager(), disabled: 1)
        runOneDisabledTest(on: Manager(), disabled: 2)
    }

    @Test("Cached, with disabling")
    func testCachedPartiallyDisabledSelectionCorrectness() async throws {
        runOneDisabledTest(on: CachedManager(), disabled: 0)
        runOneDisabledTest(on: CachedManager(), disabled: 1)
        runOneDisabledTest(on: CachedManager(), disabled: 2)
    }

    private func runOneDisabledTest(on manager: Manager, disabled: Int) {
        let (focusable, hidden, noTabStop, container) = oneDisabledSetup(
            manager: manager,
            disabled: disabled
        )

        let expectedSequence: [Participant]
        switch disabled {
            case 0: expectedSequence = [focusable[1], focusable[2]]
            case 1: expectedSequence = [focusable[0], focusable[2]]
            case 2: expectedSequence = [focusable[0], focusable[1]]
            default: return
        }

        // Test Forward (Looping through twice to ensure wrap-around works)
        for _ in 0..<2 {
            for expected in expectedSequence {
                manager.selectNext()
                #expect(manager.focusedView === expected)
            }
        }

        // Change focus once more,
        // so the selected view is the first in the sequence again.
        manager.selectNext()

        // Test Backward
        for _ in 0..<2 {
            for expected in expectedSequence.reversed() {
                manager.selectPrevious()
                #expect(manager.focusedView === expected)
            }
        }
    }

    private func runAllEnabledTest(on manager: Manager) {
        let (focusable, hidden, noTabStop) = basicSetup(manager: manager)

        // Forward
        manager.selectNext()
        #expect(manager.focusedView === focusable[0])

        manager.selectNext()
        #expect(manager.focusedView === focusable[1])

        manager.selectNext()
        #expect(manager.focusedView === focusable[2])

        manager.selectNext()
        #expect(manager.focusedView === focusable[0])

        // Reverse
        manager.selectPrevious()
        #expect(manager.focusedView === focusable[2])

        manager.selectPrevious()
        #expect(manager.focusedView === focusable[1])

        manager.selectPrevious()
        #expect(manager.focusedView === focusable[0])
    }

    private func oneDisabledSetup(manager: Manager, disabled: Int) -> (
        focusable: [Participant],
        hidden: Participant,
        noTabStop: Participant,
        container: Container
    ) {
        let focusable1 = Participant()
        let focusable2 = Participant()
        let focusable3 = Participant()

        focusable1.canBeTabStop = true
        focusable2.canBeTabStop = true
        focusable3.canBeTabStop = true

        let hidden = Participant()
        hidden.isHidden = true

        let noTabStop = Participant()
        noTabStop.canBeTabStop = false

        manager.addChild(hidden)
        manager.addChild(noTabStop)

        let container = Container()
        container.focusability = .disabled

        switch disabled {
            case 0:
                container.addChild(focusable1)
                manager.addChild(container)
                manager.addChild(focusable2)
                manager.addChild(focusable3)
            case 1:
                manager.addChild(focusable1)
                container.addChild(focusable2)
                manager.addChild(container)
                manager.addChild(focusable3)
            default:
                manager.addChild(focusable1)
                manager.addChild(focusable2)
                container.addChild(focusable3)
                manager.addChild(container)
        }

        return (
            focusable: [focusable1, focusable2, focusable3],
            hidden: hidden,
            noTabStop: noTabStop,
            container: container
        )
    }

    private func basicSetup(manager: Manager) -> (
        focusable: [Participant],
        hidden: Participant,
        noTabStop: Participant
    ) {
        let focusable1 = Participant()
        let focusable2 = Participant()
        let focusable3 = Participant()

        focusable1.canBeTabStop = true
        focusable2.canBeTabStop = true
        focusable3.canBeTabStop = true

        let hidden = Participant()
        hidden.isHidden = true

        let noTabStop = Participant()

        manager.addChild(focusable1)
        manager.addChild(hidden)
        manager.addChild(focusable2)
        manager.addChild(noTabStop)
        manager.addChild(focusable3)

        return (
            focusable: [focusable1, focusable2, focusable3],
            hidden: hidden,
            noTabStop: noTabStop
        )
    }
}

fileprivate class Manager: Container, FocusChainManager {
    typealias Widget = Participant

    weak var focusedView: Widget?

    override var manager: Manager? {
        get { self }
        set {}
    }

    func closestValidStop(following view: Participant) -> Participant? {
        var current: Widget? = view
        while let node = current {
            if let parent = node.parent {
                let siblings = parent.children
                if let index = siblings.firstIndex(of: node), index < siblings.count - 1 {
                    // Search DFS starting from the next sibling
                    let remaining = Array(siblings[(index + 1)...])
                    if let found = dfsChild(children: remaining, first: true) {
                        return found
                    }
                }
            }
            current = node.parent
        }

        // Loop back to start if nothing found
        return dfsChild(children: children, first: true)
    }

    func closestValidStop(preceding view: Widget) -> Widget? {
        // 1. Try to find the previous sibling's deepest child
        var current: Widget? = view
        while let node = current {
            if let parent = node.parent {
                let siblings = parent.children
                if let index = siblings.firstIndex(of: node), index > 0 {
                    let remaining = Array(siblings[0..<index])
                    if let found = dfsChild(children: remaining, first: false) {
                        return found
                    }
                }
            }

            // 2. Move up to parent
            if let parent = node.parent {
                if parent.canBeTabStop && !parent.isHidden {
                    return parent
                }
                current = parent
            } else {
                current = nil
            }
        }

        // Loop back to end if nothing found
        return dfsChild(children: children, first: false)
    }

    func makeKey(_ widget: Widget) {
        focusedView = widget
    }

    func getParent(of widget: Widget) -> Widget? {
        widget.parent
    }

    func selectNext() {
        guard let focusedView else {
            return selectInitialView()
        }
        selectTabStop(following: focusedView)
    }

    private func selectInitialView(forwards: Bool = true) {
        guard let firstChild = forwards ? children.first: children.last else { return }

        let nextIteration: (Participant) -> Participant?
        if forwards {
            nextIteration = { self.closestValidStop(following: $0) }
        } else {
            nextIteration = { self.closestValidStop(preceding: $0) }
        }
        // If first child is a valid focus View focus immediately.
        // It can't have a container parent.
        if
            firstChild.canBeTabStop == true,
            firstChild.isHidden == false
        {
            makeKey(firstChild)
            return
        }

        // Find the first tab stop after the first child
        // Required to detect a potential loop
        guard let firstFocus = nextIteration(firstChild)
        else { return }

        if !firstFocus.hasDisabledParent() {
            makeKey(firstFocus)
            return
        }

        // Search rest
        var current: Participant? = nextIteration(firstFocus)
        while current != firstFocus, let node = current {
            if !node.hasDisabledParent() {
                makeKey(node)
                return
            }
            current = nextIteration(node)
        }
        return
    }

    func selectPrevious() {
        guard let focusedView else {
            return selectInitialView(forwards: false)
        }
        selectTabStop(preceding: focusedView)
    }

    private func dfsChild(children: [Widget], first: Bool = true) -> Widget? {
        var orderedChildren = first ? children: children.reversed()

        for child in orderedChildren {
            // we don't check for the focusability of container here
            // since a native framework needing to use FocusChainManager wouldn't
            if
                let container = child as? Container,
                let result = dfsChild(children: container.children, first: first),
                result.canBeTabStop,
                !result.isHidden
            {
                return result
            } else if child.canBeTabStop, !child.isHidden {
                return child
            }
        }
        return nil
    }
}

fileprivate class CachedManager: Manager {
    var forwardCache = [ObjectIdentifier: Participant]()
    var reverseCache = [ObjectIdentifier: Participant]()

    func cachedStop(following key: Participant) -> Participant? {
        forwardCache[ObjectIdentifier(key)]
    }

    func cachedStop(preceding key: Participant) -> Participant? {
        reverseCache[ObjectIdentifier(key)]
    }

    func setRelationship(_ widget: Participant, following previous: Participant) {
        forwardCache[ObjectIdentifier(previous)] = widget
        reverseCache[ObjectIdentifier(widget)] = previous
    }
}

fileprivate class Participant: FocusChainParticipant {
    var canBeTabStop: Bool = false

    var isHidden: Bool = false

    var children = [Participant]()

    func callOnManagerSet() {}

    unowned var manager: Manager? {
        didSet {
            callOnManagerSet()
        }
    }

    static func == (lhs: Participant, rhs: Participant) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    weak var parent: Participant?

    func addChild(_ widget: Participant) {
        widget.manager = manager
        widget.parent = self
        children.append(widget)
    }

    func hasDisabledParent() -> Bool {
        if
            let container = parent as? Container,
            container.focusability == .disabled
        {
            return true
        }
        return parent?.hasDisabledParent() ?? false
    }
}

fileprivate class Container: Participant, FocusabilityContainer {
    var focusability: SwiftCrossUI.Focusability = .unmodified

    override func callOnManagerSet() {
        for child in children {
            child.manager = manager
        }
    }
}
