/// An enum, stored in ``EnvironmentValues``, indicating
/// whether a widget should programmatically gain or lose focus.
public enum Focus: Sendable {
    case focused
    case unfocused
}

extension Optional where Wrapped == Focus {
    /// Modifies a focus override based on a focus state and the focus value
    /// associated with a widget. If the value and the state match, then the
    /// focus override gets set to `focused`,
    func modify<Value: Hashable>(with state: Value?, match: Value) -> Self {
        guard self != .focused else { return self }

        if state == match { return .focused }
        // If we return unfocus for non-nil cases, state
        // will be reset to nil by widgets commited after the one gaining focus.
        if state == nil { return .unfocused }
        return nil
    }
}
