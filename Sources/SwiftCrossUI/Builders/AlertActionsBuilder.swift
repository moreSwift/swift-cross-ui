/// A result builder for `[AlertAction]`.
@resultBuilder
public struct AlertActionsBuilder {
    /// Called when no actions are provided.
    ///
    /// - Returns: A default "OK" action.
    public static func buildBlock() -> [AlertAction] {
        [.default]
    }

    public static func buildPartialBlock(first: Button) -> [AlertAction] {
        [
            AlertAction(
                label: first.label,
                action: first.action
            )
        ]
    }

    public static func buildPartialBlock(first: Block) -> [AlertAction] {
        first.actions
    }

    public static func buildPartialBlock(
        accumulated: [AlertAction],
        next: Button
    ) -> [AlertAction] {
        accumulated + [
            AlertAction(
                label: next.label,
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
