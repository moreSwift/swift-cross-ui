/// Context passed to a g_idle_add_full and g_timeout_add_full by GtkBackend.
class ThreadActionContext {
    var action: @MainActor () -> Void

    init(action: @escaping @MainActor () -> Void) {
        self.action = action
    }
}
