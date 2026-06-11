// NB: Implicitly Sendable due to @MainActor.
@MainActor
public struct PickerSupportedAction {
    var backend: any BaseAppBackend

    public func callAsFunction(_ pickerStyle: some PickerStyle) -> Bool {
        pickerStyle.isSupported(backend: backend)
    }
}
