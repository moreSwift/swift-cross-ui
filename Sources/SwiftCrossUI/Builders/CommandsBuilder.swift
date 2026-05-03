/// A result builder for ``Commands``.
@resultBuilder
public struct CommandsBuilder {
    public static func buildBlock(_ menus: CommandMenu...) -> Commands {
        Commands(menus: menus)
    }
}
