import Foundation
import PerceptionCore

/// This protocol can be adoopted by classes responsible for handling part of the view hierarchy. It makes
/// it easy to automatically update the view when observable view models change.
///
/// The most important rule: Every computation of a view's `body` MUST be performed inside a call to
/// `observe()`. For example:
///
///     let body = self.observe(in: backend) { view.body }
///     // Use `body`
///
/// Then, `viewModelDidChange()` will automatically be called the next time a view model conforming
/// to `Observable` or `Perceptible` and used inside the `body` computation will have change.
///
/// - Important: `self` MUST only be used to observe a single view because
/// `viewModelDidChange()`will only be called for the most recent call to `observe()` in order to
/// prevent duplicate view updates.
@MainActor
protocol ViewModelObserver: AnyObject, Sendable {
    /// Used by the `ViewModelObserver` protocol to prevent duplicate view updates.
    var currentViewModelObservationID: UUID? { get set }
    
    /// This method is called at most once after a call to `observe()` if an object conforming to
    /// `Observable` or `Perceptible` used in the `computation` closure of the last call to
    /// `observe()` has changed.
    ///
    /// When this method has been called, it will not be called again until the next call to `observe()`.
    ///
    /// - Parameter backend: The backend passed to the last call to `observe()`.
    func viewModelDidChange<Backend: BaseAppBackend>(backend: Backend)
}

extension ViewModelObserver {
    /// Performs a computation and tracks accesses to properties of objects conforming to
    /// `Observable` or `Perceptible` inside the computation. The next time one of those
    /// properties changes, `viewModelDidChange()` will be called.
    ///
    /// If this method is called multiple times, only the last call will be tracked. The reason is that view
    /// updates may be caused by other triggers. If all of those would be tracked, view updates would
    /// multiply.
    ///
    /// - Parameters:
    ///   - backend: The backend used to schedule calls to `viewModelDidChange()` on the
    ///   main thread. A strong reference will be held until that call has been made.
    ///   - computation: The computation to be tracked. Usually, accesses to a view's `body`
    ///   property will be encapsulated in this closure.
    /// - Returns: The result of the computation.
    func observe<Backend: BaseAppBackend, Result>(
        in backend: Backend,
        _ computation: () -> Result
    ) -> Result {
        let perceptionTrackingID = UUID()
        self.currentViewModelObservationID = perceptionTrackingID
        return withPerceptionTracking {
            computation()
        } onChange: { [backend, weak self] in
            backend.runInMainThread {
                guard
                    self?.currentViewModelObservationID == perceptionTrackingID
                else { return }
                self?.viewModelDidChange(backend: backend)
            }
        }
    }
}
