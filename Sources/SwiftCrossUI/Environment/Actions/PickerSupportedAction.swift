@MainActor
public struct PickerSupportedAction: Sendable {
    var backend: any AppBackend.Core

    public func callAsFunction(_ pickerStyle: some PickerStyle) -> Bool {
        pickerStyle.isSupported(backend: backend)
    }
}
