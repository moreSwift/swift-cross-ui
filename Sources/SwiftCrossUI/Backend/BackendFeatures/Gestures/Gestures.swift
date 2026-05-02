extension BackendFeatures {
    /// Backend methods for gesture handling.
    ///
    /// ## Topics
    ///
    /// ### Constituent Protocols
    /// - ``TapGestures``
    /// - ``HoverGestures``
    public typealias Gestures = TapGestures & HoverGestures
}
