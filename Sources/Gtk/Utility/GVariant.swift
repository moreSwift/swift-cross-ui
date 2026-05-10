import CGtk
import Foundation
import GtkCHelpers

public class GVariant {
    private let ptr: OpaquePointer
    private let shouldUnrefOnDeinit: Bool

    public init?(_ root: OpaquePointer?) {
        guard let root else { return nil }
        self.ptr = root
        self.shouldUnrefOnDeinit = false
    }

    private init(owning pointer: OpaquePointer) {
        self.ptr = pointer
        self.shouldUnrefOnDeinit = true
    }

    deinit {
        if shouldUnrefOnDeinit { g_variant_unref(ptr) }
    }

    public var pointer: OpaquePointer { ptr }

    public func child(_ index: Int) -> GVariant? {
        guard let child = g_variant_get_child_value(ptr, gsize(index)) else { return nil }
        return GVariant(owning: child)
    }

    public func variant() -> GVariant? {
        guard let inner = g_variant_get_variant(ptr) else { return nil }
        return GVariant(owning: inner)
    }

    public func lookup(_ key: String) -> GVariant? {
        guard let value = g_variant_lookup_value(ptr, key, nil) else { return nil }
        return GVariant(owning: value)
    }

    public func bool() -> Bool {
        g_variant_get_boolean(ptr).toBool()
    }

    public func int32() -> Int32 {
        g_variant_get_int32(ptr)
    }

    public func uint32() -> UInt32 {
        g_variant_get_uint32(ptr)
    }

    public func int64() -> Int {
        Int(g_variant_get_int64(ptr))
    }

    public func uint64() -> UInt64 {
        UInt64(g_variant_get_uint64(ptr))
    }

    public func double() -> Double {
        g_variant_get_double(ptr)
    }

    public func string() -> String {
        String(cString: g_variant_get_string(ptr, nil))
    }
}
