import MacroToolkit
import SwiftSyntax
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

public struct ObservableObjectMacro: MemberAttributeMacro, ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard ClassDeclSyntax(declaration) != nil else {
            throw MacroError("@Observable can only be applied to classes")
        }

        guard
            let variable = Decl(member).asVariable,
            // only fully visible members
            !variable._syntax.modifiers.contains(where: { modifier in
                let kind = modifier.name.tokenKind

                return
                    kind == .keyword(.static) || kind == .keyword(.private)
                    || kind == .keyword(.fileprivate)
            }),
            // Only include variables
            variable._syntax.bindingSpecifier.text == "var",
            // Only include not yet observed and not opt out members
            !variable.attributes.contains(where: { attr in
                return
                    [
                        "Published",
                        "SwiftCrossUI.Published",
                        "ObservationIgnored",
                        "SwiftCrossUI.ObservationIgnored",
                    ].contains(attr.attribute?.name.name)
            }),
            // Only include properties without accessors
            let binding = destructureSingle(variable.bindings),
            // Don't allow any accessors, because even when the property is
            // stored (i.e. supports `@Published`), the added property wrapper
            // changes the meaning of `didSet` and `willSet` accessors.
            binding.accessors.isEmpty
        else {
            return []
        }

        return ["@SwiftCrossUI.Published"]
    }

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard ClassDeclSyntax(declaration) != nil else {
            throw MacroError("@Observable can only be applied to classes")
        }

        let extensionDecl = try ExtensionDeclSyntax(
            """
            extension \(raw: type): SwiftCrossUI.ObservableObject {}
            """
        )

        return [extensionDecl]
    }
}

public struct ObservationIgnoredMacro: AccessorMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingAccessorsOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.AccessorDeclSyntax] {
        return []
    }
}
