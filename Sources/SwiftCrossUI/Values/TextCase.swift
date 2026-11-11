extension Text {
    /// How to transform the capitalization of text.
    public enum Case: Hashable, Sendable {
        /// Makes text all lowercase.
        case lowercase
        /// Makes text all uppercase.
        case uppercase
    }
}
