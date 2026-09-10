import MacroToolkit
import SwiftSyntax
import SwiftSyntaxMacros

/// Expands SwiftCrossUIPreviews' `#Preview(_:body:)` overload into a preview
/// registration on the platforms that have a preview canvas, and into nothing
/// everywhere else.
///
/// Expanding to nothing off-Apple is what lets consumers write `#Preview` in
/// ordinary source files, with no conditional compilation of their own, and
/// still have those files build on Linux and Windows.
///
/// Three details of the expansion are forced rather than chosen:
///
/// - The registration is emitted here rather than by delegating to SwiftUI's
///   `#Preview`. Xcode identifies a preview by the mangled name of its registry
///   type, which encodes the shape of the expansion that produced it, so
///   delegating would nest SwiftUI's expansion inside this one and mangle a
///   frame deeper than the canvas expects.
/// - The gate tests `os(...)` rather than `canImport(SwiftUI)`. `canImport`
///   evaluates to false inside a macro expansion buffer even on platforms where
///   the module is present, so gating on it would silently discard every
///   preview.
/// - The registry type is named with `makeUniqueName`. Freestanding declaration
///   macros have to declare the names they introduce and can't introduce
///   arbitrary ones at file scope; names from `makeUniqueName` are exempt.
public struct SCUIPreviewMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let body = node.trailingClosure else {
            throw MacroError("#Preview expects a trailing closure containing a view")
        }

        // SwiftUI's `#Preview` takes an optional display name as its first
        // argument, so pass along whatever the caller wrote.
        let name = node.arguments.map(\.description).joined(separator: ", ")

        // The canvas associates a registration with the call site it came from
        // by these three values.
        let location = context.location(of: node, at: .afterLeadingTrivia, filePathMode: .fileID)
        let fileID = location?.file ?? "\"\""
        let line = location?.line ?? "0"
        let column = location?.column ?? "0"

        // The label becomes part of the mangled name, so it has to match the
        // one SwiftUI's own expansion uses.
        let registry = context.makeUniqueName("PreviewRegistry")

        return [
            """
            #if os(macOS) || os(iOS) || os(tvOS) || os(visionOS) || os(watchOS)
                @available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, watchOS 10.0, *)
                nonisolated struct \(registry): DeveloperToolsSupport.PreviewRegistry {
                    static var fileID: String {
                        \(raw: fileID)
                    }
                    static var line: Int {
                        \(raw: line)
                    }
                    static var column: Int {
                        \(raw: column)
                    }

                    @MainActor static func makePreview() throws -> DeveloperToolsSupport.Preview {
                        DeveloperToolsSupport.Preview(\(raw: name)) {
                            SwiftCrossUIPreviews.SCUIPreview \(raw: body.description)
                        }
                    }
                }
            #endif
            """
        ]
    }
}
