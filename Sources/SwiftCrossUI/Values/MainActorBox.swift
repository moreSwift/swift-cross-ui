// NB: Implicitly Sendable due to @MainActor.
@MainActor
struct MainActorBox<T> {
    var value: T
}
