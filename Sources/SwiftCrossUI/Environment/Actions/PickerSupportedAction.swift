@MainActor
public struct PickerSupportedAction: Sendable {
    var backend: any AppBackend

    public func callAsFunction(_ pickerStyle: some PickerStyle) -> Bool {
        pickerStyle.isSupported(backend: backend)
    }
}
