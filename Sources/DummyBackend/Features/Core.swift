@_spi(Backends) import SwiftCrossUI
import Foundation

extension DummyBackend: BackendFeatures.Core {
    public var deviceClass: DeviceClass { DeviceClass.desktop }

    public func runMainLoop(_ callback: @escaping @MainActor () -> Void) {
        callback()
    }

    public func runInMainThread(action: @escaping @MainActor () -> Void) {
        DispatchQueue.main.async {
            action()
        }
    }

    public func computeRootEnvironment(defaultEnvironment: EnvironmentValues) -> EnvironmentValues {
        defaultEnvironment
            .with(\.appPhase, appPhase)
    }

    public func setRootEnvironmentChangeHandler(
        to action: @escaping @Sendable @MainActor () -> Void
    ) {}

}
