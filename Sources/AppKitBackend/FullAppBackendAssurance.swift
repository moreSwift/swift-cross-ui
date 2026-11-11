@_spi(Backends) import SwiftCrossUI

/// This function exists purely to produce a compile-time error if AppKitBackend stops
/// conforming to FullAppBackend. ``ensureFullAppBackendConformance``'s docs explain
/// the rationale behind this approach.
private func ensureAppKitBackendFullAppBackendConformance(_ backend: AppKitBackend) {
    ensureFullAppBackendConformance(backend)
}
