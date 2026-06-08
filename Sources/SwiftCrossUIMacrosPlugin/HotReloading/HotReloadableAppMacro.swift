import MacroToolkit
import SwiftSyntax
import SwiftSyntaxMacros

public struct HotReloadableAppMacro {}

extension HotReloadableAppMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = Decl(declaration).asStruct else {
            throw MacroError("@HotReloadable can only be applied to structs")
        }

        #if HOT_RELOADING_ENABLED
            return [
                """
                @MainActor
                var hotReloadingImportedEntryPoint: (@convention(c) (UnsafeRawPointer, Int) -> UnsafeMutableRawPointer)? = nil
                """,
                """
                @MainActor
                @_cdecl("hotReloadingExportedEntryPoint")
                public func hotReloadingExportedEntryPoint(app: UnsafeRawPointer, viewId: Int) -> UnsafeMutableRawPointer {
                    hotReloadingHasConnectedToServer = true
                    let app = app.assumingMemoryBound(to: \(raw: structDecl.identifier).self)

                    let pointer = UnsafeMutableBufferPointer<SwiftCrossUI.HotReloadableView>.allocate(capacity: 1)
                    let view = SwiftCrossUI.HotReloadableView(
                        app.pointee.entryPoint(viewId: viewId)
                    )
                    pointer.initializeElement(at: 0, to: view)
                    return UnsafeMutableRawPointer(pointer.baseAddress!)
                }
                """,
                """
                @MainActor
                var hotReloadingHasConnectedToServer = false
                """,
            ]
        #else
            return []
        #endif
    }
}

class HotReloadableViewVisitor: SyntaxVisitor {
    var hotReloadableExprs: [ExprSyntax] = []

    override func visit(_ node: MacroExpansionExprSyntax) -> SyntaxVisitorContinueKind {
        guard node.macroName.text == "hotReloadable" else {
            return .visitChildren
        }
        guard
            node.arguments.isEmpty,
            let expr = node.trailingClosure,
            node.additionalTrailingClosures.isEmpty
        else {
            return .visitChildren
        }
        hotReloadableExprs.append(ExprSyntax(expr))
        return .skipChildren
    }
}

extension HotReloadableAppMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = Decl(declaration).asStruct else {
            throw MacroError("@HotReloadable can only be applied to structs")
        }

        #if HOT_RELOADING_ENABLED
            // TODO: Skip nested declarations
            let visitor = HotReloadableViewVisitor(viewMode: .fixedUp)
            visitor.walk(structDecl._syntax)

            let cases: [DeclSyntax] = visitor.hotReloadableExprs.enumerated().map { (index, expr) in
                """
                if viewId == \(raw: index.description) {
                    return SwiftCrossUI.HotReloadableView \(expr)
                }
                """
            }
            var exprIds: [String] = try visitor.hotReloadableExprs.enumerated().map {
                (index, expr) in
                guard let location = context.location(of: expr) else {
                    throw MacroError(
                        "hotReloadable expr without source location?? (shouldn't be possible)"
                    )
                }
                return "ExprLocation(line: \(location.line), column: \(location.column)): \(index),"
            }

            // Handle empty dictionary literal
            if exprIds.isEmpty {
                exprIds.append(":")
            }

            return [
                """
                func entryPoint(viewId: Int) -> SwiftCrossUI.HotReloadableView {
                    #if !canImport(SwiftBundlerRuntime)
                        #error("Hot reloading requires importing SwiftBundlerRuntime from the swift-bundler package")
                    #endif

                    if !hotReloadingHasConnectedToServer {
                        hotReloadingHasConnectedToServer = true
                        Task { @MainActor in
                            do {
                                var client = try await HotReloadingClient()
                                print("Hot reloading: received new dylib")
                                try await client.handlePackets { @Sendable dylib in
                                    Task { @MainActor in
                                        guard let symbol = dylib.symbol(
                                            named: "hotReloadingExportedEntryPoint",
                                            ofType: (@convention(c) (UnsafeRawPointer, Int) -> UnsafeMutableRawPointer).self
                                        ) else {
                                            print("Hot reloading: Missing 'hotReloadingExportedEntryPoint' symbol")
                                            return
                                        }
                                        hotReloadingImportedEntryPoint = symbol
                                        _forceRefresh()
                                    }
                                }
                            } catch {
                                print("Hot reloading: \\(error)")
                            }
                        }
                    }

                    \(raw: cases.map(\.description).joined(separator: "\n"))
                    fatalError("Unknown viewId \\(viewId)")
                }
                """,
                """
                static let hotReloadingExprIds: [ExprLocation: Int] = [
                    \(raw: exprIds.joined(separator: "\n"))
                ]
                """,
            ]
        #else
            return []
        #endif
    }
}
