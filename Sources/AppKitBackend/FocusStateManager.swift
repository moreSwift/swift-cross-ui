import AppKit
@_spi(Backends) import SwiftCrossUI

@MainActor
class FocusStateManager: NSObject {
    private var focusObservers = [ObjectIdentifier: [WidgetFocusObserver]]()
    private struct WindowFocusState {
        var lastFocused: NSResponder?
        var shouldSkipNextFocusUpdate = false
    }
    private var windowFocusStates = [ObjectIdentifier: WindowFocusState]()

    func register(_ data: [WidgetFocusObserver], for widget: NSView) {
        focusObservers[ObjectIdentifier(widget)] = data
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard let window = object as? NSCustomWindow else { return }
        var windowFocusState = windowFocusStates[ObjectIdentifier(window)] ?? WindowFocusState()
        defer { windowFocusStates[ObjectIdentifier(window)] = windowFocusState }

        // Everytime a new view gains focused, the previous one needs its
        // FocusState set to false, because they could use different FocusStates.
        if let responder = window.firstResponder, !(responder is NSCustomWindow) {
            guard !windowFocusState.shouldSkipNextFocusUpdate else {
                windowFocusState.shouldSkipNextFocusUpdate = false
                return
            }

            if responder is NSObservableTextField || responder is NSObservableSecureTextField {
                // NSObservableTextField and NSObservableSecureTextField give focus
                // to a different view immediately after gaining focus.
                // If the inner View gaining focus isn't skipped, the FocusState would
                // reset to unfocused right after gaining, even though it is focused on screen.
                windowFocusState.shouldSkipNextFocusUpdate = true
                if let lastFocused = windowFocusState.lastFocused {
                    handleFocusChange(of: ObjectIdentifier(lastFocused), toState: false)
                }
                windowFocusState.lastFocused = responder
            } else if !windowFocusState.shouldSkipNextFocusUpdate {
                if let lastFocused = windowFocusState.lastFocused {
                    handleFocusChange(of: ObjectIdentifier(lastFocused), toState: false)
                }
                windowFocusState.lastFocused = responder
            }

            let identifier = ObjectIdentifier(responder)
            handleFocusChange(of: identifier, toState: true)
        } else if let lastFocused = windowFocusState.lastFocused {
            handleFocusChange(of: ObjectIdentifier(lastFocused), toState: false)
            windowFocusState.lastFocused = nil
        }
    }

    private func handleFocusChange(of identifier: ObjectIdentifier, toState isFocused: Bool) {
        guard let observers = focusObservers[identifier] else { return }

        if isFocused {
            for observer in observers {
                observer.didGainFocus()
            }
        } else {
            for observer in observers {
                observer.didLoseFocus()
            }
        }
    }
}
