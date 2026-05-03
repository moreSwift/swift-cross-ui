@MainActor
public struct PickerSupportedAction: Sendable {
    var backend: any BaseAppBackend

    public func callAsFunction(_ pickerStyle: some PickerStyle) -> Bool {
        pickerStyle.isSupported(backend: backend)
    }
}
