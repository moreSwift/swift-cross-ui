/// A phase of an app's lifecycle.
///
/// # Backend Developer Notes
///
/// Usually ``EnvironmentValues/appPhase`` returns ``AppPhase/active`` if
/// and only if any of the app's windows are active, but on platforms such
/// as macOS it can also return `active` if the app doesn't have any open
/// windows but still appears in the menu bar.
///
/// Generally speaking, if the app is in the ``AppPhase/inactive`` or
/// ``AppPhase/background`` phases, all of its windows should be in the
/// ``ScenePhase/inactive`` phase.
public struct AppPhase: Hashable, Sendable {
    // TODO: Figure out how .background could work on desktops

    private enum Phase: Hashable, Sendable {
        case active
        case inactive
        case background
    }
    private var phase: Phase

    /// The app is currently active.
    ///
    /// This indicates that one of the app's windows has focus and can recieve
    /// input events.
    ///
    /// The `active` phase requires no special handling, as it is the "default"
    /// phase where normal interaction occurs.
    public static let active = Self(phase: .active)
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
    public static let inactive = Self(phase: .inactive)
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
    public static let background = Self(phase: .background)
}

extension AppPhase: CustomStringConvertible {
    public var description: String {
        String(describing: phase)
    }
}
