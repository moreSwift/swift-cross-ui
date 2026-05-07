import MacroToolkit
import SwiftSyntax
import SwiftSyntaxMacros

public struct HotReloadableExprMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard node.arguments.isEmpty, let expr = node.trailingClosure.map(ExprSyntax.init) else {
            throw MacroError("#hotReloadable expects exactly one trailing closure")
        }

        #if HOT_RELOADING_ENABLED
            guard let location = context.location(of: expr) else {
                throw MacroError(
                    "#hotReloadable expr without source location?? (shouldn't be possible)"
                )
            }

            // TODO: Guard against use of `#hotReloadable` in situations where `self` doesn't refer
            //   to the root App type of the user's application.
            return
                """
                {
                    let location = ExprLocation(line: \(location.line), column: \(location.column))
                    let viewId = Self.hotReloadingExprIds[location]!
                    if let hotReloadingImportedEntryPoint {
                        return withUnsafePointer(to: self) { pointer in
                            let rawViewPointer = hotReloadingImportedEntryPoint(
                                pointer,
                                viewId
                            )
                            let viewPointer = UnsafeMutableBufferPointer<SwiftCrossUI.HotReloadableView>(
                                start: rawViewPointer.bindMemory(to: SwiftCrossUI.HotReloadableView.self, capacity: 1),
                                count: 1
                            )
                            defer {
                                viewPointer.deallocate()
                            }
                            return viewPointer.moveElement(from: 0)
                        }
                    } else {
                        return self.entryPoint(viewId: viewId)
                    }
                }()
                """
        #else
            return "SwiftCrossUI.HotReloadableView \(expr)"
        #endif
    }
}
