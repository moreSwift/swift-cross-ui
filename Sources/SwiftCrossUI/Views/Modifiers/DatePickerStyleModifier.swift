extension View {
    public func datePickerStyle(_ style: DatePickerStyle) -> some View {
        EnvironmentModifier(self) { environment in
            guard environment.supportedDatePickerStyles.contains(style) else {
                assertionFailure("Unsupported date picker style: \(style)")
                return environment.with(\.datePickerStyle, .automatic)
            }
            return environment.with(\.datePickerStyle, style)
        }
    }
}
