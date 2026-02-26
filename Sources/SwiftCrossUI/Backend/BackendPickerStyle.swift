/// Picker styles backed by backend widgets. This is passed to backends when
/// rendering native picker widgets.
public enum BackendPickerStyle: Hashable, Sendable, BitwiseCopyable {
    /// The style corresponding to ``MenuPickerStyle``.
    case menu
    /// The style corresponding to ``RadioGroupPickerStyle``.
    case radioGroup
    /// The style corresponding to ``SegmentedPickerStyle``.
    case segmented
    /// The style corresponding to ``WheelPickerStyle``.
    case wheel
}
