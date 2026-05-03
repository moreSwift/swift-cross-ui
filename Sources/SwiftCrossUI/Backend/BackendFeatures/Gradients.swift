extension BackendFeatures {
    /// Backend Methods for Linear Gradients
    ///
    /// Used by ``LinearGradient``
    public protocol LinearGradients: Core {
        func createLinearGradient() -> Widget
        
        func updateLinearGradient(
            _ widget: Widget,
            gradient: LinearGradient,
            withSize size: SIMD2<Int>,
            in environment: EnvironmentValues
        )
    }
    
    /// Backend Methods for Radial Gradients
    ///
    /// Used by ``RadialGradient``
    public protocol RadialGradients: Core {
        func createRadialGradient() -> Widget
        
        func updateRadialGradient(
            _ widget: Widget,
            gradient: RadialGradient,
            withSize size: SIMD2<Int>,
            in environment: EnvironmentValues
        )
    }
    
    /// Backend Methods for Angular (conic) Gradients
    ///
    /// Used by ``AngularGradient``
    public protocol AngularGradients: Core {
        func createAngularGradient() -> Widget
        
        func updateAngularGradient(
            _ widget: Widget,
            gradient: AngularGradient,
            withSize size: SIMD2<Int>,
            in environment: EnvironmentValues
        )
    }
}
