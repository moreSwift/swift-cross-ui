import SwiftCrossUIMacrosPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros
import SwiftSyntaxMacrosGenericTestSupport
import Testing

fileprivate let testMacros: [String: MacroSpec] = [
    "Preview": MacroSpec(type: SCUIPreviewMacro.self)
]

@Suite("Testing #Preview Macro")
struct SCUIPreviewMacroTests {
    // The registry type is named with `makeUniqueName`, which mangles in the
    // module and file being compiled, so these tests pin the parts of the
    // expansion that carry meaning rather than matching a whole buffer.

    @Test("Expansion is gated on the platforms that have a preview canvas")
    func testExpansionIsGated() throws {
        let expansion = try expand(
            """
            #Preview {
                Text("Hello")
            }
            """
        )

        // The gate has to test `os(...)`. `canImport(SwiftUI)` evaluates to
        // false inside an expansion buffer even where SwiftUI is available,
        // which would silently drop every preview.
        #expect(
            expansion.contains(
                "#if os(macOS) || os(iOS) || os(tvOS) || os(visionOS) || os(watchOS)"
            )
        )
        #expect(!expansion.contains("canImport"))
        #expect(expansion.contains("#endif"))
    }

    @Test("Expansion registers the preview directly")
    func testExpansionRegistersPreview() throws {
        let expansion = try expand(
            """
            #Preview {
                Text("Hello")
            }
            """
        )

        // The registry is emitted here rather than by delegating to SwiftUI's
        // `#Preview`, which would mangle a frame deeper than Xcode expects.
        #expect(expansion.contains(": DeveloperToolsSupport.PreviewRegistry"))
        #expect(expansion.contains("DeveloperToolsSupport.Preview"))
        #expect(expansion.contains("SwiftCrossUIPreviews.SCUIPreview"))
        #expect(expansion.contains("Text(\"Hello\")"))
    }

    @Test("Registry reports the source position of the macro")
    func testRegistryReportsSourcePosition() throws {
        let expansion = try expand(
            """
            #Preview {
                Text("Hello")
            }
            """
        )

        // The canvas associates a registration with the call site it came
        // from, so the registry has to carry all three position properties.
        #expect(expansion.contains("static var fileID: String"))
        #expect(expansion.contains("static var line: Int"))
        #expect(expansion.contains("static var column: Int"))
    }

    @Test("Display name is passed through to the registration")
    func testDisplayNameIsPassedThrough() throws {
        let expansion = try expand(
            """
            #Preview("Counter") {
                PreviewedView()
            }
            """
        )

        #expect(expansion.contains("DeveloperToolsSupport.Preview(\"Counter\")"))
    }

    @Test("Omitted display name expands to an empty argument list")
    func testOmittedDisplayName() throws {
        let expansion = try expand(
            """
            #Preview {
                PreviewedView()
            }
            """
        )

        #expect(expansion.contains("DeveloperToolsSupport.Preview()"))
    }

    @Test("Macro requires a trailing closure")
    func testRequiresTrailingClosure() throws {
        let declaration = try #require(
            DeclSyntax("#Preview(\"Counter\")").as(MacroExpansionDeclSyntax.self)
        )

        #expect(throws: (any Error).self) {
            try SCUIPreviewMacro.expansion(
                of: declaration,
                in: BasicMacroExpansionContext()
            )
        }
    }

    /// Expands a single `#Preview` declaration and returns the expanded code.
    private func expand(_ source: SyntaxNodeString) throws -> String {
        let declaration = try #require(
            DeclSyntax("\(source)").as(MacroExpansionDeclSyntax.self)
        )
        let expansion = try SCUIPreviewMacro.expansion(
            of: declaration,
            in: BasicMacroExpansionContext()
        )
        return expansion.map(\.description).joined(separator: "\n")
    }
}
