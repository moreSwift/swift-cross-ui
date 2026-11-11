import MacroToolkit

enum Differ {
    struct Diff {
        /// Structs in each library that don't conform to View.
        var nonViewStructs: Component<String>
        /// Enums in each library.
        var enums: Component<String>
        /// Views in each library.
        var views: Component<String>
        /// View modifiers in each library (including overloads).
        var viewModifiers: Component<ViewModifierSignature>
        /// View modifiers in each library (excluding overloads).
        var uniqueViewModifiers: Component<String>

        struct Component<T: Comparable & Hashable> {
            /// Elements in SwiftCrossUI.
            var swiftCrossUI: [T]
            /// Elements in SwiftUI.
            var swiftUI: [T]
            /// Elements present in both libraries.
            var shared: [T]
            /// Elements present in SwiftUI but missing from SwiftCrossUI.
            var missing: [T]

            init(swiftCrossUI: [T], swiftUI: [T]) {
                self.swiftCrossUI = swiftCrossUI
                self.swiftUI = swiftUI
                self.shared = Array(Set(swiftCrossUI).intersection(swiftUI)).sorted()
                self.missing = Array(Set(swiftUI).subtracting(swiftCrossUI)).sorted()
            }
        }
    }

    static func diff(
        swiftCrossUIAnalysis: Analyzer.Result,
        swiftUIAnalysis: Analyzer.Result
    ) -> Diff {
        let scuiModifierSignatures = swiftCrossUIAnalysis.viewModifiers
            .map(ViewModifierSignature.init(_:))
        let swiftUIModifierSignatures = swiftUIAnalysis.viewModifiers
            .map(ViewModifierSignature.init(_:))

        return Diff(
            nonViewStructs: Diff.Component(
                swiftCrossUI: swiftCrossUIAnalysis.nonViewStructs.map(\.decl.identifier),
                swiftUI: swiftUIAnalysis.nonViewStructs.map(\.decl.identifier)
            ),
            enums: Diff.Component(
                swiftCrossUI: swiftCrossUIAnalysis.enums.map(\.decl.identifier),
                swiftUI: swiftUIAnalysis.enums.map(\.decl.identifier)
            ),
            views: Diff.Component(
                swiftCrossUI: swiftCrossUIAnalysis.views.map(\.identifier),
                swiftUI: swiftUIAnalysis.views.map(\.identifier)
            ),
            viewModifiers: Diff.Component(
                swiftCrossUI: scuiModifierSignatures,
                swiftUI: swiftUIModifierSignatures
            ),
            uniqueViewModifiers: Diff.Component(
                swiftCrossUI: Array(Set(swiftCrossUIAnalysis.viewModifiers.map(\.identifier))),
                swiftUI: Array(Set(swiftUIAnalysis.viewModifiers.map(\.identifier)))
            )
        )
    }

    /// A view modifier signature used to match view modifiers implemented by
    /// SwiftCrossUI and SwiftUI.
    struct ViewModifierSignature: Hashable, CustomStringConvertible, Comparable {
        init(_ function: Function) {
            identifier = function.identifier
            parameters = function.parameters.map { parameter in
                // FIXME: This is really janky, but it'd be a lot of effort to
                //   do it well (relative to the amount of gain we'd get for
                //   our usecase of analyzing known swiftinterface files).
                //   We want to drop these module prefixes, even when the type
                //   is wrapped in an optional, or included as a generic param etc.
                var typeWithoutModule = parameter.type.normalizedDescription
                typeWithoutModule = typeWithoutModule.replacingOccurrences(of: "SwiftUI.", with: "")
                typeWithoutModule = typeWithoutModule.replacingOccurrences(
                    of: "SwiftUICore.",
                    with: ""
                )
                typeWithoutModule = typeWithoutModule.replacingOccurrences(
                    of: "SwiftCrossUI.",
                    with: ""
                )
                typeWithoutModule = typeWithoutModule.replacingOccurrences(
                    of: "CoreFoundation.CGFloat",
                    with: "Swift.Double"
                )
                return Parameter(
                    label: parameter.callSiteLabel,
                    typeWithoutModule: typeWithoutModule
                )
            }
        }

        var identifier: String
        var parameters: [Parameter]

        struct Parameter: Hashable, CustomStringConvertible {
            var label: String?
            var typeWithoutModule: String

            var description: String {
                "\(label ?? "_"): \(typeWithoutModule)"
            }
        }

        var description: String {
            "func \(identifier)(\(parameters.map(\.description).joined(separator: ", ")))"
        }

        static func < (_ lhs: Self, _ rhs: Self) -> Bool {
            // Sort by identifier, and then sort overloads alphabetically by
            // their textual signature representation
            lhs.identifier < rhs.identifier || (
                lhs.identifier == rhs.identifier && lhs.description < rhs.description
            )
        }
    }
}
