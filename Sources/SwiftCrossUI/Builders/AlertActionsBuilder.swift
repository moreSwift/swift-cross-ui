/// A result builder for `[AlertAction]`.
@resultBuilder
public struct AlertActionsBuilder {
    /// Called when no actions are provided.
    ///
    /// - Returns: A default "OK" action.
    public static func buildBlock() -> [AlertAction] {
        [.default]
    }

    @MainActor
    public static func buildPartialBlock(first: Button<TupleView1<Text>>) -> [AlertAction] {
        [
            AlertAction(
                label: first.body.view0.view0.string,
                action: first.action
            )
        ]
    }

    public static func buildPartialBlock(first: Block) -> [AlertAction] {
        first.actions
    }

    @MainActor
    public static func buildPartialBlock(
        accumulated: [AlertAction],
        next: Button<TupleView1<Text>>
    ) -> [AlertAction] {
        accumulated + [
            AlertAction(
                label: next.body.view0.view0.string,
                action: next.action
            )
        ]
    }

    public static func buildPartialBlock(
        accumulated: [AlertAction],
        next: Block
    ) -> [AlertAction] {
        accumulated + next.actions
    }

    public static func buildOptional(_ component: [AlertAction]?) -> Block {
        Block(actions: component ?? [])
    }

    public static func buildEither(first component: [AlertAction]) -> Block {
        Block(actions: component)
    }

    public static func buildEither(second component: [AlertAction]) -> Block {
        Block(actions: component)
    }

    public struct Block {
        var actions: [AlertAction]
    }
}
