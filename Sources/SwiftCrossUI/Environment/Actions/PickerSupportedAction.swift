@MainActor
public struct PickerSupportedAction: Sendable {
    var backend: any AppBackend.Base

    public func callAsFunction(_ pickerStyle: some PickerStyle) -> Bool {
        pickerStyle.isSupported(backend: backend)
    }
}
