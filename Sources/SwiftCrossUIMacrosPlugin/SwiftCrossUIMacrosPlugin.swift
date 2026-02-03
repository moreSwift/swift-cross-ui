import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct SwiftCrossUIMacrosPlugin: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [
        ObservableObjectMacro.self,
        ObservationIgnoredMacro.self,
        HotReloadableAppMacro.self,
        HotReloadableExprMacro.self,
    ]
}
