import Foundation

@attached(
    peer,
    names: named(hotReloadingExportedEntryPoint),
    named(hotReloadingImportedEntryPoint),
    named(hotReloadingHasConnectedToServer)
)
@attached(member, names: named(entryPoint), named(hotReloadingExprIds))
public macro HotReloadable() =
    #externalMacro(module: "SwiftCrossUIMacrosPlugin", type: "HotReloadableAppMacro")

@freestanding(expression)
public macro hotReloadable<T: View>(@ViewBuilder _ expr: () -> T) -> HotReloadableView =
    #externalMacro(module: "SwiftCrossUIMacrosPlugin", type: "HotReloadableExprMacro")

@_documentation(visibility: internal)
public struct ExprLocation: Hashable {
    var line: Int
    var column: Int

    public init(line: Int, column: Int) {
        self.line = line
        self.column = column
    }
}
