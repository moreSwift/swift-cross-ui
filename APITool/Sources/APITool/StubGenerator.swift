import Foundation
import SwiftSyntax

enum StubGenerator {
    static func generateStub(
        context: Context,
        outputDirectory: URL
    ) throws {
        try generateEnumStubs(context: context, file: outputDirectory / "Enums.swift")
    }

    /// This is unused for now, because it doesn't work well enough. We need
    /// to adopt a proper visitor-based screening and sanitisation approach.
    /// We have to ignore structs whose signatures reference protocols that
    /// we don't have yet (i.e. screening). And we have to remove conformances
    /// to protocols that we either can't automatically implement or don't know
    /// about (i.e. sanitization). Eventually we should attempt to stub out
    /// as many members as we possibly can, but that's a future problem.
    static func generateNonViewStructStubs(
        context: Context,
        file: URL
    ) throws {
        print("Generating non-view struct stubs (\(file.lastPathComponent))")

        var decls: [Syntax] = []
        for (_, structDecl) in context.swiftUIAnalysis.nonViewStructs {
            guard
                context.diff.nonViewStructs.missing.contains(structDecl.identifier)
            else {
                continue
            }

            var stub = structDecl._syntax
            stub.memberBlock.members = stub.memberBlock.members.filter { member in
                // Keep structs empty for now
                false
            }

            stub.attributes = filterDeclAttributes(stub.attributes)

            if var clause = stub.inheritanceClause {
                // Only keep conformances that we can trivially satisfy
                clause.inheritedTypes = clause.inheritedTypes.filter { type in
                    [
                        "Swift.Sendable",
                        "Swift.Hashable",
                        "Swift.Equatable",
                        "Swift.Codable",
                        "Swift.Decodable",
                        "Swift.Encodable"
                    ].contains(type.trimmedDescription)
                }
                if clause.inheritedTypes.isEmpty {
                    stub.inheritanceClause = nil
                } else {
                    stub.inheritanceClause = clause
                }
            }

            decls.append(stub._syntaxNode)
        }

        try output(decls: decls, to: file)
    }

    static func generateEnumStubs(
        context: Context,
        file: URL
    ) throws {
        print("Generating enum stubs (\(file.lastPathComponent))")

        var decls: [Syntax] = []
        for (_, enumDecl) in context.swiftUIAnalysis.enums {
            guard context.diff.enums.missing.contains(enumDecl.identifier) else {
                continue
            }
            
            // Remove non-case members (we don't handle stubbing them yet)
            var stub = enumDecl._syntax
            stub.memberBlock.members = stub.memberBlock.members.filter { member in
                member.decl.kind == .enumCaseDecl
            }

            stub.attributes = filterDeclAttributes(stub.attributes)

            decls.append(stub._syntaxNode)
        }

        try output(decls: decls, to: file)
    }

    private static func filterDeclAttributes(
        _ attributes: AttributeListSyntax
    ) -> AttributeListSyntax {
        attributes.filter { attribute in
            switch attribute {
                case .attribute(let attribute):
                    let attr = attribute.attributeName.trimmedDescription
                    return !["_originallyDefinedIn", "frozen", "usableFromInline"].contains(attr)
                case .ifConfigDecl:
                    return false
            }
        }
    }

    private static let header = """
        import CoreFoundation
        import Foundation
        import SwiftCrossUI


        """

    private static func output(decls: [Syntax], to file: URL) throws {
        let stub = header + decls.map(\.description).joined(separator: "\n")
            .replacingOccurrences(of: "SwiftUI.", with: "")
            .replacingOccurrences(of: "SwiftUICore.", with: "")
            .replacingOccurrences(of: "_Concurrency.", with: "")
            .replacingOccurrences(of: "Combine.ObservableObject", with: "ObservableObject")
        try stub.write(to: file, atomically: false, encoding: .utf8)
    }
}
