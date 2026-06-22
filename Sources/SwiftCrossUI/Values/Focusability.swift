/// Enables finer-grained control of ``View/focusable``.
///
/// ``Focusability/unmodified`` maintains the existing focusability
/// of the view graph without adding or removing tab stops.
public enum Focusability: String, CaseIterable, Sendable, Codable {
    /// Does not alter focus chain; view graph behaves as it would without the modifier.
    case unmodified
    /// Prevents the view and its subtree from receiving focus by keyboard.
    case disabled
}
