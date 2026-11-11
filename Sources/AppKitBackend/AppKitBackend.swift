import AppKit
@_spi(Backends) import SwiftCrossUI

extension App {
    public typealias Backend = AppKitBackend

    public var backend: AppKitBackend {
        AppKitBackend()
    }
}

@MainActor
public final class AppKitBackend {
    let appDelegate = NSCustomApplicationDelegate()
    let focusManager = FocusStateManager()
    var borderedButtonPadding: SIMD2<Int>?

    public init() {
        NSApplication.shared.delegate = appDelegate
    }
}
