/// A phase of an app's lifecycle.
#if compiler(>=6.2.3)
    @nonexhaustive
#endif
public enum AppPhase: Hashable, Sendable {
    // TODO: Figure out how .background could work on desktops

    /// The app is currently active.
    ///
    /// This indicates that one of the app's windows has focus and can recieve
    /// input events.
    ///
    /// The `active` phase requires no special handling, as it is the "default"
    /// phase where normal interaction occurs.
    case active
    /// The app is currently inactive, but is still in the foreground.
    ///
    /// On desktop backends, this indicates that another app currently has
    /// focus -- i.e. none of this app's windows are active, and (in the case of
    /// macOS) it does not own the menu bar. Usually the app's windows are still
    /// visible on the screen with dimmed title bars.
    ///
    /// An app can be `inactive` on mobile backends if it is being obscured by
    /// system UI (such as the iOS Control Center or Android notification shade)
    /// but is still considered "in the foreground" by the system. The exact
    /// details can vary between backends; we recommend against special
    /// treatment of the `inactive` phase on mobile for this reason.
    case inactive
    /// The app is in the background.
    ///
    /// On mobile backends, apps reach the `background` phase when the user or
    /// system moves another app or the home screen into the foreground (such as
    /// by swiping on the gesture bar / Home indicator).
    ///
    /// - Important: Be aware that, on mobile backends, the system may choose to
    ///   cleanly terminate the app at any time when it is in the `background`
    ///   phase due to memory pressure or other reasons.
    ///
    /// This phase is currently never reached on desktop backends.
    case background
}
