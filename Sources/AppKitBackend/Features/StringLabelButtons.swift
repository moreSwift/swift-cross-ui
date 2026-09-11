import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.StringLabelButtons {
    public func createSimpleButton() -> Widget {
        NSButton()
    }

    public func updateSimpleButton(
        _ button: Widget,
        label: String,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        let button = button as! NSButton
        button.attributedTitle = Self.attributedString(
            for: label,
            in: environment.with(\.multilineTextAlignment, .center)
        )
        button.appearance = environment.colorScheme.nsAppearance
        button.isEnabled = environment.isEnabled

        button.onAction = { _ in
            action()
        }
    }
}
