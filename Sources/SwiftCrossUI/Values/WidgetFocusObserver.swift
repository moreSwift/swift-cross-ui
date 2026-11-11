/// A focus state observer passed by ``View/focused(_:)`` to backends.
@MainActor
public struct WidgetFocusObserver: Sendable {
    /// A function called when the target widget gains focus.
    public let didGainFocus: () -> Void
    /// A function called when the target widget loses focus.
    public let didLoseFocus: () -> Void

    public init(
        didGainFocus: @escaping () -> Void,
        didLoseFocus: @escaping () -> Void
    ) {
        self.didGainFocus = didGainFocus
        self.didLoseFocus = didLoseFocus
    }
}
