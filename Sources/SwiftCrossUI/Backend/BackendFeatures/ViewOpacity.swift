extension BackendFeatures {
    @MainActor
    public protocol ViewOpacity: BackendFeatures.Core {
        func setOpacity(of widget: Widget, to opacity: Double)
    }
}
