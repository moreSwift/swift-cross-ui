extension View {
    /// Transforms the case of ``Text`` views.
    ///
    /// - Parameter textCase: The new text case.
    public func textCase(_ textCase: Text.Case?) -> some View {
        environment(\.textCase, textCase)
    }
}
