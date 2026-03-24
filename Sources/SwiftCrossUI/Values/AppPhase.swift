/// A phase of an app's lifecycle.
#if compiler(>=6.2.3)
    @nonexhaustive
#endif
public enum AppPhase: Hashable, Sendable {
    // TODO: Figure out how .background could work on desktops

//    /// The app is in the process of launching.
//    ///
//    /// This indicates that the app process is running but has not yet finished
//    /// initialization.
//    /// - On desktop backends, none of the app's windows have opened yet, but
//    ///   it'll usually show up in system UI (such as the Dock on macOS).
//    /// - On most mobile backends, an app in the `launching` phase has taken
//    ///   over the screen but has not yet rendered its UI.
//    ///
//    /// Once initialization is complete, the app will transition to the
//    /// appropriate runtime phase.
//    ///
//    /// This is the app's initial phase when it begins starting up, and it is
//    /// never reached again after initialization is complete.
//    case launching
    /// The app is currently active.
    ///
    /// This indicates that one of the app's windows has focus and can recieve
    /// input events.
    case active
    /// The app is currently inactive, but is still in the foreground.
    ///
    /// On desktop backends, this indicates that another app currently has
    /// focus -- i.e. none of this app's windows are active, and (in the case of
    /// macOS) this app does not own the menu bar. Usually the app's windows are
    /// still visible on the screen with dimmed title bars.
    ///
    /// An app can be `inactive` on mobile backends if it is being obscured by
    /// system UI (such as the iOS Control Center or Android notification shade)
    /// but is still considered "in the foreground" by the system. The specific
    /// details can vary greatly between backends, and we don't recommend
    /// treating the `inactive` phase specially on mobile for this reason.
    case inactive
    /// The app is in the background.
    ///
    /// On mobile backends, apps reach the `background` phase when the user or
    /// system moves another app or the home screen into the foreground (such as
    /// by swiping on the gesture bar / Home indicator). **Be aware that the
    /// system may choose to terminate the app's process at any time when it is
    /// in the `background` phase** -- see ``terminating`` for more details.
    ///
    /// This phase is currently never reached on desktop backends.
    case background
//    /// The app is preparing to terminate.
//    ///
//    /// This indicates that the user or system has initiated app termination,
//    /// such as by pressing Command+Q on macOS or closing all of the app's
//    /// windows on GTK or Windows.
//    ///
//    /// Typically, user input can never cause this phase to be reached on mobile
//    /// backends, as closing an app from the system app switcher usually
//    /// forcibly terminates the process. However, the system may choose to
//    /// cleanly terminate apps that are currently in the ``background`` phase
//    /// due to memory pressure or other reasons -- in this case, the app will
//    /// enter the `terminating` phase.
//    ///
//    /// Once the app has reached the `terminating` phase, it will remain there
//    /// until the process exits.
//    case terminating
}
