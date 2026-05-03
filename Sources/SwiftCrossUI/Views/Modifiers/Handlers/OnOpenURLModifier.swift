import Foundation

extension View {
    /// Performs an action whenever the system asks the app to handle
    /// a URL with a registered scheme.
    ///
    /// - Parameter action: The action to perform. Receives the URL in
    ///   question.
    public func onOpenURL(
        perform action: @escaping (URL) -> Void
    ) -> some View {
        PreferenceModifier(self) { preferences, environment in
            var newPreferences = preferences
            newPreferences.onOpenURL = { url in
                action(url)
                if let innerHandler = preferences.onOpenURL {
                    innerHandler(url)
                } else {
                    environment.bringWindowForward()
                }
            }
            return newPreferences
        }
    }
}
