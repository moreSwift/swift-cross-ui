import MacroToolkit
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

public struct CastBackendMacro: BodyMacro {
    public static func expansion(
        of attribute: AttributeSyntax,
        providingBodyFor decl: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
        in context: some MacroExpansionContext
    ) throws -> [CodeBlockItemSyntax] {
        // MARK: Checks

        // Get the single generic argument.
        guard
            let newBackend = Attribute(attribute).name
                .genericArguments?.first?._baseSyntax
        else {
            throw MacroError(
                "@CastBackend macro expects a single type parameter"
            )
        }

        // Get the `backendGenericName` argument, if we have one; if we don't,
        // generate one randomly.
        let backendGeneric =
            if let backendGenericName = Attribute(attribute)
                .asMacroAttribute?.arguments
                .first(where: { $0.label == "backendGenericName" })?
                .expr.asStringLiteral?.value
            {
                TokenSyntax.identifier(backendGenericName)
            } else {
                context.makeUniqueName("NewBackend")
            }

        // Make sure this is a function and it has a `backend` parameter.
        guard
            let signature = decl.as(FunctionDeclSyntax.self)?.signature,
            let backendParameter = signature.parameterClause.parameters.first(where: {
                ($0.secondName ?? $0.firstName).trimmedDescription == "backend"
            })
        else {
            throw MacroError(
                "@CastBackend macro expects a function with a `backend` parameter"
            )
        }

        // Make sure there's an existing body -- we're not making it from scratch.
        guard let body = decl.body else {
            throw MacroError(
                "@CastBackend macro expects a function with a body"
            )
        }

        // If we were told that this function returns a widget, make sure
        // it actually has a return type.
        let widgetType: TypeSyntax?
        if
            let returnsWidgetExpr = Attribute(attribute)
                .asMacroAttribute?.arguments
                .first(where: { $0.label == "returnsWidget" })?.expr,
            returnsWidgetExpr.asBooleanLiteral?.value == true
        {
            guard let returnClause = signature.returnClause else {
                throw MacroError(
                    "@CastBackend expects a return type when returnsWidget is true"
                )
            }
            widgetType = returnClause.type
        } else {
            widgetType = nil
        }

        // MARK: Expansion

        // Set up identifiers.
        let innerFunction = context.makeUniqueName("castBackend")
        let castedBackend = context.makeUniqueName("castedBackend")

        // If we have a `widget` parameter, cast it.
        let widgetCast: StmtSyntax? =
            if signature.parameterClause.parameters.contains(where: {
                ($0.secondName ?? $0.firstName).trimmedDescription == "widget"
            }) {
                "let widget = widget as! \(backendGeneric).Widget"
            } else {
                nil
            }

        // If we're returning a widget, fix the return type from the inner
        // function and then cast the widget in the final return statement.
        let returnClause = if widgetType != nil {
            ReturnClauseSyntax(type: TypeSyntax("\(backendGeneric).Widget"))
        } else {
            signature.returnClause
        }
        let returnCast = if let widgetType {
            " as! \(widgetType)"
        } else {
            ""
        }

        return [
            """
            func \(innerFunction)<
                \(backendGeneric): BaseAppBackend & \(newBackend)
            >(_ backend: \(backendGeneric))\(returnClause) {
                \(widgetCast)
                \(body.statements)
            }
            
            guard let \(castedBackend) = backend as? any BaseAppBackend & \(newBackend) else {
                fatalError("'\\(\(backendParameter.type).self)' does not implement '\(newBackend.trimmed)'")
            }
            return \(innerFunction)(\(castedBackend))\(raw: returnCast)
            """
        ]
    }
}
