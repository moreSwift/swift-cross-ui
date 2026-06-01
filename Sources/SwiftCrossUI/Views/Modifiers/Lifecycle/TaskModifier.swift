//MARK: Is this needed? This seems to be the worst offender in terms of compatibility. 

/*@available(iOS 13, *)
extension View {
    /// Starts a task before a view appears (but after ``View/body`` has been
    /// accessed), and cancels the task when the view disappears. Additionally,
    /// if `id` changes the current task is cancelled and a new one is started.
    ///
    /// This variant of `task` can be useful when the lifetime of the task
    /// must be linked to a value with a potentially shorter lifetime than the
    /// view.
    public nonisolated func task<Id: Equatable>(
        id: Id,
        priority: TaskPriority = .userInitiated,
        _ action: @escaping () async -> Void
    ) -> some View {
        TaskModifier(
            id: id,
            content: TupleView1(self),
            priority: priority,
            action: action
        )
    }

    /// Starts a task before a view appears (but after ``View/body`` has been
    /// accessed), and cancels the task when the view disappears.
    public nonisolated func task(
        priority: TaskPriority = .userInitiated,
        _ action: @escaping () async -> Void
    ) -> some View {
        TaskModifier(
            id: 0,
            content: TupleView1(self),
            priority: priority,
            action: action
        )
    }
}

@available(iOS 13, *)
struct TaskModifier<Id: Equatable, Content: View> {
    @State var task: Task<(), any Error>? = nil

    var id: Id
    var content: Content
    var priority: TaskPriority
    var action: () async -> Void
}

@available(iOS 13, *)
extension TaskModifier: View {
    var body: some View {
        // Explicitly return to disable result builder (we don't want an extra
        // layer of views).
        return
            content
            .onChange(of: id, initial: true) {
                task?.cancel()
                task = Task(priority: priority) {
                    await action()
                }
            }
            .onDisappear {
                task?.cancel()
            }
    }
}*/
