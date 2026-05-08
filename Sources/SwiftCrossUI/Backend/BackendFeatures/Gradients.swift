extension BackendFeatures {
    /// Conform backends to this typealias if it is supporting all SwiftCrossUI supported gradients
    /// and you plan to keep up this support in the future.
    ///
    /// To support a subset of gradient types, conform to each supported gradient protocol individually.
    public typealias Gradients =
        BackendFeatures.LinearGradients &
        BackendFeatures.RadialGradients &
        BackendFeatures.AngularGradients
}
