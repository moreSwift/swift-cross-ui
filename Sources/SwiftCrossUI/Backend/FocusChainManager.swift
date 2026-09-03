/// A protocol to simplify support for focus management in certain UI frameworks.
///
/// Use this protocol if the underlying backend does not natively support
/// hierarchical focus control or if you need to override default tab-cycle behavior.
///
/// To use:
/// 1. Conform your coordinator to ``FocusChainManager``.
/// 2. Implement ``makeKey(_:)`` to trigger the framework's focus mechanism.
/// 3. Call ``selectTabStop(following:)`` or ``selectTabStop(preceding:)`` when
///    the framework requests a focus change (e.g., via Tab or Shift-Tab).
public protocol FocusChainManager {
    associatedtype Widget: FocusChainParticipant

    /// Returns the widget following a given widget in the focus chain, suggested by the UI framework.
    /// This widget will be validated for visibility and focusability by the caller.
    /// Used by FocusChainManager's helper methods.
    func closestValidStop(following view: Widget) -> Widget?

    /// Returns the widget preceding a given widget in the focus chain, suggested by the UI framework.
    /// This widget will be validated for visibility and focusability by the caller.
    /// Used by FocusChainManager's helper methods.
    func closestValidStop(preceding view: Widget) -> Widget?

    /// Makes a widget the "key view" or "first responder".
    func makeKey(_ widget: Widget)

    /// Returns the immediate parent.
    func getParent(of widget: Widget) -> Widget?
}

/// A protocol implemented by focus containers of backends that can't
/// natively toggle focusability of views.
/// Respected by ``FocusChainManager``.
public protocol FocusabilityContainer {
    /// Whether the container and its children can gain focus by keyboard navigation.
    var focusability: Focusability { get }
}

/// A protocol which backend widgets must conform to in order for
/// a backend to use them with a ``FocusChainManager``.
public protocol FocusChainParticipant: Equatable {
    /// Whether a widget participates in the focus chain, i.e. if it can gain focus via keyboard navigation.
    var canBeTabStop: Bool { get }
    /// Whether a widget is hidden. Hidden widgets are skipped while selecting the next target.
    var isHidden: Bool { get }
}

extension FocusChainManager {
    public func findNextAllowedFocusTarget(
        suggestion: Widget,
        forward: Bool = true
    ) -> Widget? {
        var currentCandidate: Widget? = suggestion
        var visited: [Widget] = []

        while let next = currentCandidate {
            // Exit to not get stuck in a loop
            // when arriving back an already visited widget.
            guard !visited.contains(next) else {
                break
            }
            visited.append(next)

            if
                !isDescendantOfDisabledParent(next),
                next.canBeTabStop,
                !next.isHidden
            { return next }

            if forward {
                currentCandidate = closestValidStop(following: next)
            } else {
                currentCandidate = closestValidStop(preceding: next)
            }
        }

        return nil
    }

    /// Traverses the view graph upwards until it finds a ``FocusabilityContainer`` with
    /// ``FocusabilityContainer/focusability`` set to ``Focusability.disabled`` or reaches the root.
    /// Returns `true` if the widget is contained by a disabled ``FocusabilityContainer``.
    private func isDescendantOfDisabledParent(_ widget: Widget) -> Bool {
        var current = getParent(of: widget)

        while let next = current {
            if let next = next as? FocusabilityContainer,
               next.focusability == .disabled
            {
                return true
            }
            current = getParent(of: next)
        }

        return false
    }

    /// Moves focus to the closest focusable widget following the currently focused widget.
    /// The widget must be attached to a window.
    public func selectTabStop(following widget: Widget) {
        guard
            let next = closestValidStop(following: widget),
            let result = findNextAllowedFocusTarget(suggestion: next)
        else { return }

        makeKey(result)
    }

    /// Moves focus to the closest focusable widget preceding the currently focused widget.
    /// The widget must be attached to a window.
    public func selectTabStop(preceding widget: Widget) {
        guard
            let previous = closestValidStop(preceding: widget),
            let result = findNextAllowedFocusTarget(
                suggestion: previous,
                forward: false
            )
        else { return }

        makeKey(result)
    }
}
