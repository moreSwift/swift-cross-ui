import Foundation
import XMLCoder

extension GtkCodeGen {
    static func decodeGIR(_ data: Data) throws -> GIR {
        let decoder = XMLDecoder()
        decoder.keyDecodingStrategy = .custom({ path in
            let codingKey = path[path.count - 1]
            let containsColon = codingKey.stringValue.contains(":")
            let containsHyphen = codingKey.stringValue.contains("-")
            if containsColon || containsHyphen {
                var input = codingKey.stringValue
                var output = ""

                // Remove namespace
                if containsColon {
                    let parts = input.split(separator: ":").map(String.init)
                    output = parts[0]
                    input = parts[1]
                }

                // Convert kebab-case to camelCase
                if containsHyphen {
                    var parts = input.split(separator: "-")
                    let firstPart = String(parts.removeFirst())
                    if containsColon {
                        output += firstPart.capitalized
                    } else {
                        output += firstPart
                    }

                    for part in parts {
                        output += part.capitalized
                    }
                } else {
                    output += input.capitalized
                }

                return output
            } else {
                return codingKey
            }
        })
        return try decoder.decode(GIR.self, from: data)
    }
}

struct GIR: Decodable {
    var package: Package
    var namespace: Namespace
    var include: [Include]
}

struct Namespace: Decodable {
    var name: String
    var version: String
    var sharedLibrary: String
    var cIdentifierPrefix: String
    var cSymbolPrefix: String

    var aliases: [Alias]
    var classes: [Class]
    var enumerations: [Enumeration]
    var interfaces: [Interface]

    enum CodingKeys: String, CodingKey {
        case name
        case version
        case sharedLibrary
        case cIdentifierPrefix = "cIdentifierPrefixes"
        case cSymbolPrefix = "cSymbolPrefixes"
        case aliases = "alias"
        case classes = "class"
        case enumerations = "enumeration"
        case interfaces = "interface"
    }
}

/// Can be expanded in future. Intended to be a common API for classes and interfaces.
protocol ClassLike {
    var name: String { get }
    var cSymbolPrefix: String { get }
    var methods: [Method] { get }
    var signals: [Signal] { get }
    var properties: [Property] { get }
}

struct Interface: Decodable, ClassLike {
    var name: String
    var cSymbolPrefix: String
    var cType: String
    var version: String?
    var glibTypeName: String
    var glibGetType: String
    var glibTypeStruct: String?
    var doc: String?
    var prerequisites: [ConformancePrerequisite]

    var functions: [Function]
    var virtualMethods: [VirtualMethod]
    var methods: [Method]
    var signals: [Signal]
    var properties: [Property]

    enum CodingKeys: String, CodingKey {
        case name
        case cSymbolPrefix
        case cType
        case version
        case glibTypeName
        case glibGetType
        case glibTypeStruct
        case doc
        case prerequisites = "prerequisite"
        case functions = "function"
        case virtualMethods = "virtualMethod"
        case methods = "method"
        case signals = "glibSignal"
        case properties = "property"
    }
}

struct Function: Decodable {
    var name: String
    var cIdentifier: String
    var doc: String?
    var returnValue: ReturnValue
    var parameters: Parameters

    enum CodingKeys: String, CodingKey {
        case name
        case cIdentifier
        case doc
        case returnValue
        case parameters
    }
}

struct VirtualMethod: Decodable {
    var name: String
    var invoker: String?
    var attribute: VirtualMethodAttribute?
    var doc: String?
    var returnValue: ReturnValue
    var parameters: MethodParameters
}

struct VirtualMethodAttribute: Decodable {
    var name: String
    var value: String
}

struct ConformancePrerequisite: Decodable {
    var name: String
}

struct Enumeration: Decodable {
    var name: String
    var version: String?
    var cType: String
    var doc: String?
    var members: [Member]

    enum CodingKeys: String, CodingKey {
        case name
        case cType
        case doc
        case version
        case members = "member"
    }

    struct Member: Decodable {
        var name: String
        var cIdentifier: String
        var doc: String?
        var version: String?
        var docDeprecated: String?
    }
}

struct Alias: Decodable {
    var name: String
    @Attribute var cType: String
    var doc: String?
    @Element var type: String
}

struct Class: Decodable, ClassLike {
    var name: String
    var cSymbolPrefix: String
    var cType: String?
    var parent: String?
    var abstract: Bool?

    var doc: String?
    var constructors: [Constructor]
    var methods: [Method]
    var properties: [Property]
    var signals: [Signal]
    var conformances: [Conformance]

    enum CodingKeys: String, CodingKey {
        case name
        case cSymbolPrefix
        case cType
        case parent
        case abstract
        case doc
        case constructors = "constructor"
        case methods = "method"
        case properties = "property"
        case signals = "glibSignal"
        case conformances = "implements"
    }

    /// Aggregates all members of a specific type including those implemented for an
    /// interface conformance (but not those from super classes).
    func getAllImplemented<T>(
        _ keyPath: KeyPath<ClassLike, [T]>,
        namespace: Namespace,
        excludeInherited: Bool = true
    ) -> [(any ClassLike, T)] {
        let baseProperties = self[keyPath: keyPath].map { (self, $0) }
        let interfaceProperties = getImplementedInterfaces(
            namespace: namespace,
            excludeInherited: true
        )
        .flatMap { interface in
            let elements = interface[keyPath: keyPath]
            return elements.map { (interface, $0) }
        }
        return baseProperties + interfaceProperties
    }

    /// Aggregates all members of a specific type that have been inherited from super
    /// classes (doesn't include members from implemented interfaces).
    func getAllInherited<T>(
        _ keyPath: KeyPath<any ClassLike, [T]>,
        namespace: Namespace
    ) -> [(any ClassLike, T)] {
        guard
            let parent,
            let parentClass = namespace.classes.first(where: { $0.name == parent })
        else {
            return []
        }

        return
            parentClass[keyPath: keyPath].map { (parentClass, $0) }
                + parentClass.getAllInherited(keyPath, namespace: namespace)
    }

    /// Returns all interfaces implemented by the class that aren't already implemented
    /// by a superclass. Excludes interfaces that can't be found in the namespace.
    func getImplementedInterfaces(
        namespace: Namespace,
        excludeInherited: Bool
    ) -> [Interface] {
        let interfaces = conformances.compactMap { conformance in
            namespace.interfaces.first { $0.name == conformance.name }
        }.filter { $0.version == nil }

        if excludeInherited {
            let inheritedInterfaces = getInheritedInterfaces(namespace: namespace)
            return interfaces.filter { interface in
                !inheritedInterfaces.contains { inheritedInterface in
                    inheritedInterface.name == interface.name
                }
            }
        } else {
            return interfaces
        }
    }

    /// Gets interface conformances inherited from parent.
    func getInheritedInterfaces(namespace: Namespace) -> [Interface] {
        guard let parentClass = getParentClass(namespace: namespace) else {
            return []
        }
        return parentClass.getImplementedInterfaces(namespace: namespace, excludeInherited: false)
    }

    /// Returns nil if the class is parentless or the parent can't be found in the
    /// namespace.
    func getParentClass(namespace: Namespace) -> Class? {
        guard
            let parent,
            let parentClass = namespace.classes.first(where: { $0.name == parent })
        else {
            return nil
        }
        return parentClass
    }

    /// Returns `true` if the namespace contains at least one subclass of the class.
    func hasSubclass(namespace: Namespace) -> Bool {
        let child = namespace.classes.first { $0.parent == name }
        return child != nil
    }
}

struct Conformance: Decodable {
    var name: String
}

struct Signal: Decodable {
    var name: String
    var when: String?
    var noRecurse: Bool?
    var doc: String?
    var returnValue: ReturnValue
    var parameters: Parameters?
}

struct Constructor: Decodable {
    var name: String
    var cIdentifier: String
    var deprecated: Int?
    var doc: String?
    var returnValue: ReturnValue
    var parameters: Parameters?
    var version: String?
}

struct Method: Decodable {
    var name: String
    var cIdentifier: String
    var version: String?
    var doc: String?
    var returnValue: ReturnValue?
    var parameters: MethodParameters?
}

struct Property: Decodable {
    var name: String
    var version: String?
    var doc: String?
    var getter: String?
    var setter: String?
    var defaultValue: String?
    var transferOwnership: String
    var writable: Bool?
    var type: GIRType?
}

struct MethodParameters: Decodable {
    var instanceParameter: Parameter
    var parameters: [Parameter]

    enum CodingKeys: String, CodingKey {
        case instanceParameter
        case parameters = "parameter"
    }
}

struct Parameters: Decodable {
    var parameters: [Parameter]

    enum CodingKeys: String, CodingKey {
        case parameters = "parameter"
    }
}

struct Parameter: Decodable {
    var nullable: Bool?
    var name: String
    var transferOwnership: String
    var doc: String?
    var type: GIRType?
    var array: ArrayType?
    var varargs: VarArgs?
}

struct ArrayType: Decodable {
    var cType: String
    var type: GIRType
}

struct VarArgs: Decodable {}

struct ReturnValue: Decodable {
    var nullable: Bool?
    var transferOwnership: String?
    var doc: String?
    var type: GIRType?
}

struct GIRType: Decodable {
    var name: String?
    var cType: String?
}

struct Package: Decodable {
    var name: String
}

struct Include: Decodable {
    var name: String
    var version: String
}
