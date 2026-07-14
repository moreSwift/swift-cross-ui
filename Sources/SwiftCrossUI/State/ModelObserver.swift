import Foundation
import ObservationPolyfillCore

/// This protocol can be adopted by classes responsible for handling part of the stateful hierarchy. It makes
/// it easy to automatically update the view when observable models change.
///
/// The most important rule: Every computation of a `body` property MUST be performed inside a call to
/// ``observe(with:_:)``. For example:
///
///     let body = self.observe(in: backend) { view.body }
///     // Use `body`
///
/// Then, ``viewModelDidChange(backend:)`` will automatically be called the next time a view
/// model conforming to `Observable` and used inside the `body` computation changes.
///
/// - Important: `self` MUST only be used to observe a single view because
/// ``viewModelDidChange(backend:)`` will only be called for the most recent call to
/// ``observe(with:_:)`` in order to prevent duplicate view updates.
@MainActor
protocol ModelObserver: AnyObject, Sendable {
    /// Used by the ``ModelObserver`` protocol to prevent duplicate view updates.
    var currentViewModelObservationID: UUID? { get set }
    
    /// This method is called at most once after a call to `observe()` if an object conforming to
    /// `Observable` used in the `computation` closure of the last call to ``observe(with:_:)``
    /// has changed.
    ///
    /// When this method has been called, it will not be called again until the next call to
    /// ``observe(with:_:)``.
    ///
    /// - Parameter backend: The backend passed to the last call to ``observe(with:_:)``.
    func viewModelDidChange<Backend: BaseAppBackend>(backend: Backend)
}

extension ModelObserver {
    /// Performs a computation and tracks accesses to properties of objects conforming to
    /// `Observable` inside the computation. The next time one of those properties changes,
    /// ``viewModelDidChange(backend:)`` will be called.
    ///
    /// If this method is called multiple times, only the last call will be tracked. The reason is that view
    /// updates may be caused by other triggers. If all of those would be tracked, view updates would
    /// multiply.
    ///
    /// - Parameters:
    ///   - backend: The backend used to schedule calls to
    ///     ``viewModelDidChange(backend:)`` on the main thread. A strong reference will be
    ///     held until that call has been made.
    ///   - computation: The computation to be tracked. Usually, accesses to a view's `body`
    ///     property will be encapsulated in this closure.
    /// - Returns: The result of the computation.
    func observe<Backend: BaseAppBackend, Result>(
        with backend: Backend,
        _ computation: () -> Result
    ) -> Result {
        let observationTrackingID = UUID()
        self.currentViewModelObservationID = observationTrackingID
        return ObservationPolyfillCore.withObservationTracking {
            computation()
        } onChange: { [backend, weak self] in
            backend.runInMainThread {
                guard
                    self?.currentViewModelObservationID == observationTrackingID
                else { return }
                self?.viewModelDidChange(backend: backend)
            }
        }
    }
}
