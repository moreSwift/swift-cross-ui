@globalActor
public actor _GlobalActorToDisableGlobalActorInference {
    public static let shared = _GlobalActorToDisableGlobalActorInference()
}

/// Protocols that inherit from an actor-isolated protocol (such as View)
/// and `_RemoveGlobalActorIsolation` end up without an inferred isolation.
///
/// This is useful for protocols such as Shape which inherit from an
/// actor-isolated protocol but don't themselves need the isolation for
/// members that aren't a direct requirement of the isolated protocol.
@_GlobalActorToDisableGlobalActorInference
public protocol _RemoveGlobalActorIsolation {}
