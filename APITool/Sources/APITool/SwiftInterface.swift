import SwiftSyntax
import MacroToolkit

struct SwiftInterface {
    var moduleName: String
    var sourceFile: SourceFileSyntax

    var structs: [Struct]
    var enums: [Enum]
    var extensions: [Extension]
}
