/// A result builder for `[MenuItem]`.
@resultBuilder
public struct MenuItemsBuilder {
    public static func buildBlock() -> [MenuItem] {
        []
    }
    
    public static func buildPartialBlock(first: some View) -> [MenuItem] {
        // For SwiftUI compatibility, we ignore any views that aren't MenuItemRepresentable.
        guard let first = first as? any MenuItemRepresentable else { return [] }
        return [first.asMenuItem]
    }

    public static func buildPartialBlock(first: Block) -> [MenuItem] {
        first.items
    }

    public static func buildPartialBlock<Items: Collection, ID: Hashable>(
        first: ForEach<Items, ID, [MenuItem]>
    ) -> [MenuItem] {
        first.elements.map(first.child).flatMap { $0 }
    }

    public static func buildPartialBlock(
        accumulated: [MenuItem],
        next: some View
    ) -> [MenuItem] {
        accumulated + buildPartialBlock(first: next)
    }

    public static func buildPartialBlock(
        accumulated: [MenuItem],
        next: Block
    ) -> [MenuItem] {
        accumulated + buildPartialBlock(first: next)
    }

    public static func buildPartialBlock<Items: Collection, ID: Hashable>(
        accumulated: [MenuItem],
        next: ForEach<Items, ID, [MenuItem]>
    ) -> [MenuItem] {
        accumulated + buildPartialBlock(first: next)
    }

    public static func buildOptional(_ component: [MenuItem]?) -> Block {
        Block(items: component ?? [])
    }

    public static func buildEither(first component: [MenuItem]) -> Block {
        Block(items: component)
    }

    public static func buildEither(second component: [MenuItem]) -> Block {
        Block(items: component)
    }

    /// An implementation detail of ``MenuItemsBuilder``'s support for
    /// `if`/`else if`/`else` blocks.
    public struct Block {
        var items: [MenuItem]
    }
}
