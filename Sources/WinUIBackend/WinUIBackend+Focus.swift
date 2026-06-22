import CWinRT
import Foundation
import SwiftCrossUI
import UWP
import WinAppSDK
import WinSDK
import WinUI
import WinUIInterop
import WindowsFoundation

// MARK: - FocusState

class FocusStateManager {
    private var focusData = [ObjectIdentifier: Set<FocusData>]()
    private var lastFocused: ObjectIdentifier? = nil
    var observersSetup = Set<ObjectIdentifier>()

    func register(_ data: [FocusData], for widget: WinUIBackend.Widget) {
        guard !(widget is Canvas) else { return }

        let id = ObjectIdentifier(widget)
        focusData[id] = Set(data)

        guard id != lastFocused else {
            if widget.focusState != .unfocused,
               data.contains(where: \.shouldUnfocus),
               let root = widget.xamlRoot.content
            {
                _ = try? root.focus(.programmatic)
            }
            return
        }

        if data.contains(where: \.matches),
           widget.visibility == .visible
        {
            // .keyboard is used instead of .programmatic
            // so WinUI displays the focus ring
            _ = try? widget.focus(.keyboard)
        }
    }

    func handleFocusChange(of identifier: ObjectIdentifier, toState isFocused: Bool) {
        guard let data = focusData[identifier] else { return }
        if isFocused {
            lastFocused = identifier
            data.forEach { binding in
                binding.set()
            }
        } else {
            lastFocused = nil
            data.forEach { binding in
                binding.reset()
            }
        }
    }
}

extension WinUIBackend {
    public func registerFocusObservers(
        _ data: [FocusData],
        on widget: WinUIBackend.Widget
    ) {
        guard !(widget is Canvas) else { return }
        let id = ObjectIdentifier(widget)

        focusManager.register(data, for: widget)
        if !focusManager.observersSetup.contains(id) {
            widget.gotFocus.addHandler { [weak self] _, _ in
                guard let self else { return }
                self.focusManager.handleFocusChange(
                    of: id,
                    toState: true
                )
            }

            widget.lostFocus.addHandler { [weak self] _, _ in
                guard let self else { return }
                self.focusManager.handleFocusChange(
                    of: id,
                    toState: false
                )
            }

            focusManager.observersSetup.insert(id)
        }
    }

    public func createFocusContainer() -> WinUIBackend.Widget {
        return FocusContainer()
    }

    public func updateFocusContainer(
        _ widget: WinUIBackend.Widget,
        focusability: Focusability
    ) {
        guard let container = widget as? FocusContainer else { return }
        container.focusability = focusability
    }

    public func setFocusEffectDisabled(on widget: WinUIBackend.Widget, disabled: Bool) {
        widget.useSystemFocusVisuals = !disabled
    }
}

class FocusContainer: Canvas, FocusabilityContainer {
    public var focusability: Focusability = .unmodified
}
