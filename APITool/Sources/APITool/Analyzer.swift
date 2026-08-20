import MacroToolkit
import SwiftSyntax

enum Analyzer {
    struct Result {
        var structs: [(module: String, decl: Struct)]
        var structTable: [String: Int]
        var structConformances: [String: [Type]]

        var nonViewStructs: [(module: String, decl: Struct)]
        var enums: [(module: String, decl: Enum)]
        var extensions: [(module: String, decl: Extension)]

        var views: [Struct]
        var viewModifiers: [Function]
    }

    /// The analyzer collects 'interesting' declarations from the Swift interfaces
    /// that it's given. It ignores declarations that begin with an underscore
    /// (as those aren't considered properly 'public') and those that are unavailable
    /// on iOS or macOS (as they are likely platform-specific APIs that we don't
    /// care about in SwiftCrossUI).
    static func analyze(interfaces: [SwiftInterface]) -> Result {
        let structs: [(String, Struct)] = interfaces.flatMap { interface in
            interface.structs.map { (interface.moduleName, $0) }
        }
        .filter { !$0.1.identifier.starts(with: "_") }
        .filter { availableEnough($0.1._syntax.attributes) }
        .filter { $0.1.accessLevel == .public }

        let enums: [(String, Enum)] = interfaces.flatMap { interface in
            interface.enums.map { (interface.moduleName, $0) }
        }
        .filter { !$0.1.identifier.starts(with: "_") }
        .filter { availableEnough($0.1._syntax.attributes) }
        .filter { $0.1.accessLevel == .public }

        let extensions: [(String, Extension)] = interfaces.flatMap { interface in
            interface.extensions.map { (interface.moduleName, $0) }
        }
        .filter { !$0.1.identifier.starts(with: "_") }
        .filter { availableEnough($0.1._syntax.attributes) }

        var structTable: [String: Int] = [:]
        for (index, (module, structDecl)) in structs.enumerated() {
            structTable["\(module).\(structDecl.identifier)"] = index
        }

        var conformances: [String: [Type]] = [:]
        for (module, structDecl) in structs {
            conformances["\(module).\(structDecl.identifier)"] = structDecl.inheritedTypes
        }

        for (_, extensionDecl) in extensions {
            conformances[extensionDecl.identifier, default: []] += extensionDecl.inheritedTypes
        }

        // TODO: Include transitive conformances by iterating through protocols as well

        var viewIdentifiers: Set<String> = []
        var views: [Struct] = []
        for (module, structDecl) in structs {
            let identifier = "\(module).\(structDecl.identifier)"

            guard conformances[identifier]?.contains(where: isViewProtocol(_:)) == true else {
                continue
            }

            viewIdentifiers.insert(identifier)
            views.append(structDecl)
        }

        var viewModifiers: [Function] = []
        for (_, extensionDecl) in extensions {
            guard isViewProtocol(extensionDecl.identifier) else {
                continue
            }

            for member in extensionDecl.members {
                guard
                    let method = member.asFunction,
                    !method._syntax.modifiers.contains(where: { $0.name.text == "static" }),
                    case let .someOrAny(opaqueReturn) = method.returnType,
                    opaqueReturn._baseSyntax.someOrAnySpecifier.text == "some",
                    isViewProtocol(Type(opaqueReturn._baseSyntax.constraint))
                else {
                    continue
                }

                guard availableEnough(method._syntax.attributes) else {
                    continue
                }

                guard !method.identifier.starts(with: "_") else {
                    continue
                }

                viewModifiers.append(method)
            }
        }

        let nonViewStructs = structs.filter { (module, decl) in
            let identifier = "\(module).\(decl.identifier)"
            return !viewIdentifiers.contains(identifier)
        }

        return Result(
            structs: structs,
            structTable: structTable,
            structConformances: conformances,
            nonViewStructs: nonViewStructs,
            enums: enums,
            extensions: extensions,
            views: views,
            viewModifiers: viewModifiers
        )
    }

    /// A very crude check for identifying the SwiftUI View
    /// protocol (as it spelled in the Swift interface files
    /// that we're interested in).
    static func isViewProtocol(_ type: Type) -> Bool {
        isViewProtocol(type.normalizedDescription)
    }

    /// A very crude check for identifying the SwiftUI View
    /// protocol (as it spelled in the Swift interface files
    /// that we're interested in).
    static func isViewProtocol(_ type: String) -> Bool {
        ["SwiftUICore.View", "SwiftCrossUI.View"].contains(type)
    }

    /// Checks whether a set of attributes is loose enough for
    /// us to care about the declaration that they're attached to.
    ///
    /// For now we just require that the declaration is available
    /// on macOS or iOS.
    static func availableEnough(_ attributes: AttributeListSyntax) -> Bool {
        var unavailableOnMacOS = false
        var unavailableOnIOS = false
        for attribute in attributes {
            switch attribute {
                case .attribute(let attribute):
                    guard
                        attribute.attributeName.trimmedDescription == "available",
                        let arguments = attribute.arguments?.as(AvailabilityArgumentListSyntax.self)
                    else {
                        continue
                    }

                    let args = arguments.map(\.argument.trimmedDescription)
                    if args == ["macOS", "unavailable"] {
                        unavailableOnMacOS = true
                    } else if args == ["iOS", "unavailable"] {
                        unavailableOnIOS = true
                    }
                case .ifConfigDecl:
                    continue
            }
        }
        return !unavailableOnIOS || !unavailableOnMacOS
    }
}
