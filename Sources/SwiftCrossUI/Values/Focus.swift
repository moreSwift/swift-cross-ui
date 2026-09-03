/// An enum, stored in ``EnvironmentValues``, indicating
/// whether a widget should programmatically gain or lose focus.
public enum Focus: Sendable {
    case focused
    case unfocused
}

extension Optional where Wrapped == Focus {
    func modify<Value: Hashable>(with state: Value?, match: Value) -> Self {
        guard self != .focused else { return self }

        if state == match { return .focused }
        if state != nil { return .unfocused }
        return nil
    }
}
