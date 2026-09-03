/// The information passed by ``View/focused(_:)`` to a backend.
@MainActor
public struct WidgetFocusObserver: Sendable {
    /// A function to set the ``FocusState`` to ``match``.
    public let didGainFocus: () -> Void
    /// A function to set the ``FocusState`` to unfocused.
    public let didLoseFocus: () -> Void

    public init(
        didGainFocus: @escaping () -> Void,
        didLoseFocus: @escaping () -> Void
    ) {
        self.didGainFocus = didGainFocus
        self.didLoseFocus = didLoseFocus
    }
}
