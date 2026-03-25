@MainActor
public struct PickerSupportedAction: Sendable {
    var backend: any AppBackend_Core

    public func callAsFunction(_ pickerStyle: some PickerStyle) -> Bool {
        pickerStyle.isSupported(backend: backend)
    }
}
