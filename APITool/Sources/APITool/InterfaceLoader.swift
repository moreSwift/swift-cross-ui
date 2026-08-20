import Foundation
import SwiftSyntax
import SwiftParser
import MacroToolkit

enum InterfaceLoader {
    enum Error: LocalizedError {
        case failedToReadFile(Swift.Error)

        var errorDescription: String? {
            switch self {
                case .failedToReadFile(let error):
                    return "Failed to read file: \(error.localizedDescription)"
            }
        }
    }

    static func loadInterface(_ file: URL, moduleName: String) throws(Error) -> SwiftInterface {
        let sourceText: String
        do {
            sourceText = try String(contentsOf: file)
        } catch {
            throw Error.failedToReadFile(error)
        }

        let sourceFile = Parser.parse(source: sourceText)
        var structs: [Struct] = []
        var enums: [Enum] = []
        var extensions: [Extension] = []
        for stmt in sourceFile.statements {
            let decl: DeclSyntax
            switch stmt.item {
                case .decl(let declSyntax):
                    decl = declSyntax
                case .expr, .stmt:
                    continue
            }

            let wrapped = Decl(decl)
            if let enumDecl = wrapped.asEnum {
                enums.append(enumDecl)
            } else if let structDecl = wrapped.asStruct {
                structs.append(structDecl)
            } else if let extensionDecl = wrapped._syntax.as(ExtensionDeclSyntax.self) {
                extensions.append(Extension(extensionDecl))
            }
        }

        return SwiftInterface(
            moduleName: moduleName,
            sourceFile: sourceFile,
            structs: structs,
            enums: enums,
            extensions: extensions
        )
    }
}
