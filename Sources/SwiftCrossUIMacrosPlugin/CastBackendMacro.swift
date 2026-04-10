import MacroToolkit
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

public struct CastBackendMacro: BodyMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
        in context: some MacroExpansionContext
    ) throws -> [CodeBlockItemSyntax] {
        // Get the single generic argument.
        guard
            let genericArgs = Attribute(node).name.genericArguments,
            let newBackendType = genericArgs.first?._baseSyntax
        else {
            throw MacroError("@CastBackend macro expects a single type parameter")
        }

        // Make sure this is a function and it has a `backend` parameter.
        guard
            let signature = declaration.as(FunctionDeclSyntax.self)?.signature,
            let backendParameter = signature.parameterClause.parameters.first(where: {
                ($0.secondName ?? $0.firstName).trimmedDescription == "backend"
            })
        else {
            throw MacroError("@CastBackend macro expects a function with a `backend` argument")
        }

        // Make sure there's an existing body -- we're not making it from scratch.
        guard let body = declaration.body else {
            throw MacroError("@CastBackend macro expects a function with a body")
        }

        // If we were told that this function returns a widget, make sure
        // it actually has a return type.
        let widgetType: TypeSyntax?
        if
            let args = Attribute(node).asMacroAttribute?.arguments,
            let returnsWidgetExpr = args
                .first(where: { $0.label == "returnsWidget" })?
                .expr,
            returnsWidgetExpr.asBooleanLiteral?.value == true
        {
            guard let returnClause = signature.returnClause else {
                throw MacroError("@CastBackend expects a return type when returnsWidget is true")
            }
            widgetType = returnClause.type
        } else {
            widgetType = nil
        }

        // Get the name of the backend type via the parameter.
        let oldBackendType = backendParameter.type

        // Set up identifiers.
        let backendGenericName = context.makeUniqueName("NewBackend")
        let innerFunctionName = context.makeUniqueName("castBackend")
        let castedBackendName = context.makeUniqueName("castedBackend")

        // If we have a `widget` parameter, cast it.
        let widgetCast: StmtSyntax =
            if signature.parameterClause.parameters.hasParameter(named: "widget") {
                "let widget = widget as! \(backendGenericName).Widget"
            } else {
                ""
            }

        // If we're returning a widget, fix the return type from the inner
        // function and then cast the widget in the final return statement.
        let returnClause = if widgetType != nil {
            ReturnClauseSyntax(type: TypeSyntax("\(backendGenericName).Widget"))
        } else {
            signature.returnClause
        }
        let returnExpression: ExprSyntax = if let widgetType {
            "\(innerFunctionName)(\(castedBackendName)) as! \(widgetType)"
        } else {
            "\(innerFunctionName)(\(castedBackendName))"
        }

        // Set up the inner function.
        let castFunction = FunctionDeclSyntax(
            name: innerFunctionName,
            genericParameterClause: "<\(backendGenericName): AppBackend.Base & \(newBackendType)>",
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax {
                    "_ backend: \(backendGenericName)"
                },
                returnClause: returnClause
            )
        ) {
            widgetCast
            body.statements
        }.formatted()

        return [
            "\(castFunction)",
            """
            guard let \(castedBackendName) = backend as? any AppBackend.Base & \(newBackendType) else {
                fatalError("'\\(\(oldBackendType).self)' does not implement '\(newBackendType.trimmed)'")
            }
            """,
            "return \(returnExpression)",
        ]
    }
}

extension FunctionParameterListSyntax {
    func hasParameter(named name: String) -> Bool {
        contains { ($0.secondName ?? $0.firstName).trimmedDescription == name }
    }
}
