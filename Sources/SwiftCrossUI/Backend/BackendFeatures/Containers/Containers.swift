extension BackendFeatures {
    /// Backend methods for widget containers.
    ///
    /// These protocols let apps implement views that wrap widgets within
    /// other widgets, such as scroll views or split views.
    ///
    /// The "generic" container is implemented separately from this;
    /// see ``GenericContainers`` for more details on that protocol.
    ///
    /// ## Topics
    ///
    /// ### Constituent Protocols
    /// - ``ScrollContainers``
    /// - ``SelectableListView``
    /// - ``SplitView``
    public typealias Containers =
        ScrollContainers & SelectableListViews & SplitViews
}
