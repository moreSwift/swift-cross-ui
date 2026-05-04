import CGtk
import Foundation
import GtkCHelpers

public class GVariant {
    public let pointer: OpaquePointer
    private let shouldUnrefOnDeinit: Bool

    public init?(_ root: OpaquePointer?) {
        guard let root else { return nil }
        self.pointer = root
        self.shouldUnrefOnDeinit = false
    }

    internal init(owning pointer: OpaquePointer) {
        self.pointer = pointer
        self.shouldUnrefOnDeinit = true
    }

    public convenience init?(parsing format: String) {
        guard let v = g_variant_parse(nil, format, nil, nil, nil) else { return nil }
        self.init(owning: v)
    }

    public static func parse(_ format: String) -> GVariant? {
        guard let v = g_variant_parse(nil, format, nil, nil, nil) else { return nil }
        return GVariant(owning: v)
    }

    public func copy() -> GVariant {
        GVariant(owning: g_variant_ref(pointer))
    }

    deinit {
        if shouldUnrefOnDeinit { g_variant_unref(pointer) }
    }

    public func child(_ index: Int) -> GVariant? {
        guard let child = g_variant_get_child_value(pointer, gsize(index)) else { return nil }
        return GVariant(owning: child)
    }

    public func variant() -> GVariant? {
        guard let inner = g_variant_get_variant(pointer) else { return nil }
        return GVariant(owning: inner)
    }

    public func lookup(_ key: String) -> GVariant? {
        guard let value = g_variant_lookup_value(pointer, key, nil) else { return nil }
        return GVariant(owning: value)
    }

    public func bool() -> Bool {
        g_variant_get_boolean(pointer).toBool()
    }

    public func int32() -> Int32 {
        g_variant_get_int32(pointer)
    }

    public func uint32() -> UInt32 {
        g_variant_get_uint32(pointer)
    }

    public func int64() -> Int {
        Int(g_variant_get_int64(pointer))
    }

    public func uint64() -> UInt64 {
        UInt64(g_variant_get_uint64(pointer))
    }

    public func double() -> Double {
        g_variant_get_double(pointer)
    }

    public func string() -> String {
        String(cString: g_variant_get_string(pointer, nil))
    }
}
