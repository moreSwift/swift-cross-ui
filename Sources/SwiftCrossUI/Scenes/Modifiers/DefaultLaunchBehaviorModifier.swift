extension Scene {
    /// Sets the default launch behavior of windows controlled by this scene.
    public func defaultLaunchBehavior(
        _ launchBehavior: SceneLaunchBehavior
    ) -> some Scene {
        environment(\.defaultLaunchBehavior, launchBehavior)
    }
}
