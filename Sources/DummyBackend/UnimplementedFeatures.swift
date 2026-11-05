@_spi(Backends) import SwiftCrossUI

// MARK: - Unimplemented Features
// FIXME: Implement them so we can test them
extension DummyBackend:
    BackendFeatures.ProgressBars
    & BackendFeatures.ProgressSpinners
    & BackendFeatures.TextEditors
{
    public func createProgressBar() -> Widget {
        fatalError("\(Self.self): \(#function) not implemented")
    }

    public func updateProgressBar(
        _ widget: Widget,
        progressFraction: Double?,
        environment: SwiftCrossUI.EnvironmentValues
    ) {
        fatalError("\(Self.self): \(#function) not implemented")
    }

    public func createProgressSpinner() -> Widget {
        fatalError("\(Self.self): \(#function) not implemented")
    }

    public func createTextEditor() -> Widget {
        fatalError("\(Self.self): \(#function) not implemented")
    }

    public func updateTextEditor(
        _ textEditor: Widget,
        environment: SwiftCrossUI.EnvironmentValues,
        onChange: @escaping (String) -> Void
    ) {
        fatalError("\(Self.self): \(#function) not implemented")
    }

    public func setContent(ofTextEditor textEditor: Widget, to content: String) {
        fatalError("\(Self.self): \(#function) not implemented")
    }

    public func getContent(ofTextEditor textEditor: Widget) -> String {
        fatalError("\(Self.self): \(#function) not implemented")
    }
}
