import DummyBackend
@testable @_spi(Backends) import SwiftCrossUI

extension DummyBackend.Widget {
    /// Returns the first widget in the hierarchy matching a filter (depth first), or nil if no widget was found.
    func first<T: DummyBackend.Widget>(where filter: (T) -> Bool) -> T? {
        if let self = self as? T, filter(self) {
            return self
        }

        for child in getChildren() {
            let match: T? = child.first(where: filter)
            if let match {
                return match
            }
        }

        return nil
    }

    /// Returns the first widget in the hierarchy matching a filter depth first.
    ///
    /// Throws if no widget was found.
    func locateDescendant<T: DummyBackend.Widget>(where filter: (T) -> Bool) throws -> T {
        let first: T? = first(where: filter)
        guard let first else {
            throw ViewGraphHelpers.Error.failedToFindDescendant
        }
        return first
    }

    /// Returns all widgets in the hierarchy matching a filter recursively.
    func descendantsMatching<T: DummyBackend.Widget>(predicate isIncluded: (T) -> Bool) -> [T] {
        var matches = [T]()

        if let self = self as? T, isIncluded(self) {
            matches.append(self)
        }

        for child in getChildren() {
            matches.append(contentsOf: child.descendantsMatching(predicate: isIncluded))
        }

        return matches
    }
}
