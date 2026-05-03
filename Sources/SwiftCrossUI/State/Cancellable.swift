/// Will run a 'cancel' action when the cancellable falls out of scope (gets
/// deinited by ARC). Protects against calling the action twice.
public class Cancellable {
    /// The cancel action to call on deinit.
    private var closure: (() -> Void)?
    /// A human-readable tag for debugging purposes.
    var tag: String?

    /// If defused, the cancellable won't cancel the ongoing action on deinit.
    var defused = false

    /// Creates a new cancellable.
    ///
    /// - Parameter closure: The closure to call when this cancellable falls out
    ///   of scope (i.e. is deinited).
    public init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    /// Prevents the cancellable from calling its cancel action when it goes out
    /// of scope.
    func defuse() {
        defused = true
    }

    /// Runs the cancel action.
    deinit {
        if !defused {
            cancel()
        }
    }

    /// Runs the cancel action and ensures that it can't be called a second
    /// time.
    public func cancel() {
        closure?()
        closure = nil
    }

    /// Adds a human-readable tag to the cancellable.
    ///
    /// This method is a no-op in release mode.
    ///
    /// - Parameter tag: The tag to add.
    @discardableResult
    func tag(with tag: @autoclosure () -> String?) -> Self {
        #if DEBUG
            self.tag = tag()
        #endif
        return self
    }
}
