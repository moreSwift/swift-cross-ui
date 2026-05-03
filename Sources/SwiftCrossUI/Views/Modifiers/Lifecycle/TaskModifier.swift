extension View {
    /// Starts a task before a view appears (but after ``View/body`` has been
    /// accessed), and cancels the task when the view disappears. Additionally,
    /// if `id` changes the current task is cancelled and a new one is started.
    ///
    /// This variant of `task` can be useful when the lifetime of the task
    /// must be linked to a value with a potentially shorter lifetime than the
    /// view.
    ///
    /// - Parameters:
    ///   - id: The ID of the task.
    ///   - priority: The priority of the task.
    ///   - action: The action to perform within the task.
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
    ///
    /// - Parameters:
    ///   - priority: The priority of the task.
    ///   - action: The action to perform within the task.
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

struct TaskModifier<Id: Equatable, Content: View> {
    @State var task: Task<(), any Error>? = nil

    var id: Id
    var content: Content
    var priority: TaskPriority
    var action: () async -> Void
}

extension TaskModifier: View {
    var body: some View {
        content.onChange(of: id, initial: true) {
            task?.cancel()
            task = Task(priority: priority) {
                await action()
            }
        }.onDisappear {
            task?.cancel()
        }
    }
}
