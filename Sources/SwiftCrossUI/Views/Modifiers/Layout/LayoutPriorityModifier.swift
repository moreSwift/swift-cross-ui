extension View {
    /// Sets the priority with which a parent layout should allocate space to this child.
    public func layoutPriority(_ value: Double) -> some View {
        preference(key: \.layoutPriority, value: value)
    }
}
