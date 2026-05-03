import Testing
import SwiftSyntaxMacrosGenericTestSupport
import SwiftSyntaxMacros
import SwiftCrossUIMacrosPlugin
import SwiftSyntaxMacroExpansion

fileprivate let testMacros: [String: MacroSpec] = [
    "ObservableObject": MacroSpec(type: ObservableObjectMacro.self)
]

@Suite("Testing @ObservableObject Macro")
struct ObservableTests {
    @Test("Stored property gets Published")
    func testStoredPropertyGetsAttribute() {
        assertMacroExpansion(
            """
            @ObservableObject
            class ViewModel {
                var name: String = ""
            }
            """,
            expandedSource: """
            class ViewModel {
                @SwiftCrossUI.Published
                var name: String = ""
            }
            
            extension ViewModel: SwiftCrossUI.ObservableObject {
            }
            """,
            macroSpecs: testMacros,
            failureHandler: { spec in
                Issue.record(spec.issueComment)
            }
        )
    }
    
    @Test("Computed property gets skipped")
    func testComputedPropertyIsIgnored() {
        assertMacroExpansion(
            """
            @ObservableObject
            class ViewModel {
                var computed: Int { 1 + 1 }
                var explicitGet: Int { get { 0 } }
            }
            """,
            expandedSource: """
            class ViewModel {
                var computed: Int { 1 + 1 }
                var explicitGet: Int { get { 0 } }
            }
            
            extension ViewModel: SwiftCrossUI.ObservableObject {
            }
            """,
            macroSpecs: testMacros,
            failureHandler: { spec in
                Issue.record(spec.issueComment)
            }
        )
    }
    
    @Test("Stored property with observers doesn't get attribute")
    func testPropertyWithObserversGetsAttribute() {
        assertMacroExpansion(
            """
            @ObservableObject
            class ViewModel {
                var observed: String = "" {
                    didSet { print("changed") }
                }
            }
            """,
            expandedSource: """
            class ViewModel {
                var observed: String = "" {
                    didSet { print("changed") }
                }
            }
            
            extension ViewModel: SwiftCrossUI.ObservableObject {
            }
            """,
            macroSpecs: testMacros,
            failureHandler: { spec in
                Issue.record(spec.issueComment)
            }
        )
    }
    
    @Test("Private and static properties are ignored")
    func testPrivateAndStaticAreIgnored() {
        assertMacroExpansion(
            """
            @ObservableObject
            class ViewModel {
                private var secret = "shh"
                static var shared = "info"
                private(set) var readOnly = "safe"
            }
            """,
            expandedSource: """
            class ViewModel {
                private var secret = "shh"
                static var shared = "info"
                private(set) var readOnly = "safe"
            }
            
            extension ViewModel: SwiftCrossUI.ObservableObject {
            }
            """,
            macroSpecs: testMacros,
            failureHandler: { spec in
                Issue.record(spec.issueComment)
            }
        )
    }
    
    @Test("ObservationIgnored is honored")
    func testObservationIgnoredIsHonored() {
        assertMacroExpansion(
            """
            @ObservableObject
            class ViewModel {
                @ObservationIgnored var skipMe = false
            }
            """,
            expandedSource: """
            class ViewModel {
                @ObservationIgnored var skipMe = false
            }
            
            extension ViewModel: SwiftCrossUI.ObservableObject {
            }
            """,
            macroSpecs: testMacros,
            failureHandler: { spec in
                Issue.record(spec.issueComment)
            }
        )
    }
    
    @Test("Multiple Bindings get ignored")
    func testMultipleBindingsThrowError() {
        assertMacroExpansion(
            """
            @ObservableObject
            class ViewModel {
                var a, b: String
            }
            """,
            expandedSource: """
            class ViewModel {
                var a, b: String
            }
            
            extension ViewModel: SwiftCrossUI.ObservableObject {
            }
            """,
            macroSpecs: testMacros,
            failureHandler: { spec in
                Issue.record(spec.issueComment)
            }
        )
    }
    
    @Test("Namespaced ObservationIgnored blocks application")
    func namespacedObservationIgnoredBlocksApplication() async throws {
        assertMacroExpansion(
            """
            @ObservableObject
            class ViewModel {
                @SwiftCrossUI.ObservationIgnored var skipMe = false
            }
            """,
            expandedSource: """
            class ViewModel {
                @SwiftCrossUI.ObservationIgnored var skipMe = false
            }
            
            extension ViewModel: SwiftCrossUI.ObservableObject {
            }
            """,
            macroSpecs: testMacros,
            failureHandler: { spec in
                Issue.record(spec.issueComment)
            }
        )
    }
}
