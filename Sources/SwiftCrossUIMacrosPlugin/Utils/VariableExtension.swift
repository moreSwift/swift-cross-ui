import MacroToolkit
import SwiftSyntax
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

extension Variable {
    // Portions of this code are derived from the Swift Open Source Project.
    // Copyright (c) 2014 - 2024 Apple Inc. and the Swift project authors
    // Licensed under Apache License v2.0 with Runtime Library Exception
    // Source https://github.com/swiftlang/swift/blob/2e8977f/lib/Macros/Sources/ObservationMacros/Extensions.swift#L111
    func hasMacroApplication(_ name: String) -> Bool {
        let parts = name.split(separator: ".")

        var expectation: [TokenKind] = []

        for (i, identifier) in parts.enumerated() {
            expectation.append(.identifier(String(identifier)))

            if i < parts.count - 1 {
                expectation.append(.period)
            }
        }

        for attribute in _syntax.attributes {
            switch attribute {
                case .attribute(let attr):
                    if attr.attributeName.tokens(viewMode: .all).map({
                        $0.tokenKind
                    }) == expectation {
                        return true
                    }
                default:
                    break
            }
        }
        return false
    }
}
