import Foundation
@_spi(Backends) import SwiftCrossUI

@MainActor
public final class DummyBackend {
    public var incomingURLHandler: ((URL) -> Void)?
    public var appPhase = AppPhase.active

    public init() {}
}
