import CGtk
import Foundation
import GtkCHelpers
import Mutex

public enum FreedesktopError: Error {
    public enum BusError: Error {
        case failedCall
        case malformedInput
        case noProxy
    }
}

private class CallbackBox<T> {
    var value: T

    init(_ value: T) {
        self.value = value
    }
}

private typealias DBusSignalHandler =
    @convention(c) (
        OpaquePointer?, UnsafePointer<CChar>?, UnsafePointer<CChar>?,
        UnsafePointer<CChar>?, UnsafePointer<CChar>?, OpaquePointer?,
        UnsafeMutableRawPointer?
    ) -> Void

public class Bus {
    private var proxy: UnsafeMutablePointer<GDBusProxy>
    private var interfaceName: String
    private var subscriptions: [(UInt, Any)] = []

    init(interfaceName: String) throws(FreedesktopError.BusError) {
        self.interfaceName = interfaceName
        let p = g_dbus_proxy_new_for_bus_sync(
            G_BUS_TYPE_SESSION,
            G_DBUS_PROXY_FLAGS_NONE,
            nil,
            "org.freedesktop.portal.Desktop",
            "/org/freedesktop/portal/desktop",
            "org.freedesktop.portal.\(interfaceName)",
            nil,
            nil
        )

        guard let p else { throw FreedesktopError.BusError.noProxy }
        self.proxy = p
    }

    deinit {
        for (handlerId, _) in subscriptions {
            g_signal_handler_disconnect(self.proxy, handlerId)
        }
        subscriptions = []
        g_object_unref(proxy)
    }

    public func call(namespace: String, key: String, method: String)
        throws(FreedesktopError.BusError) -> GVariant
    {
        guard let v = GVariant.parse("('\(namespace)', '\(key)')") else { throw .malformedInput }

        let output = g_dbus_proxy_call_sync(
            proxy,
            method,
            v.pointer,
            G_DBUS_CALL_FLAGS_NONE,
            gint(-1),
            nil,
            nil
        )

        guard let output else { throw .failedCall }

        return GVariant(owning: output)
    }

    public func call(method: String, parameters: GVariant)
        throws(FreedesktopError.BusError) -> GVariant
    {
        let output = g_dbus_proxy_call_sync(
            proxy,
            method,
            parameters.pointer,
            G_DBUS_CALL_FLAGS_NONE,
            gint(-1),
            nil,
            nil
        )

        guard let output else { throw .failedCall }

        return GVariant(owning: output)
    }

    public func readProperty(_ name: String) -> GVariant? {
        guard let prop = g_dbus_proxy_get_cached_property(proxy, name) else { return nil }
        return GVariant(owning: prop)
    }

    public func connection() -> OpaquePointer? {
        g_dbus_proxy_get_connection(proxy)
    }

    public func subscribe(
        signal: String, namespace: String, key: String, handler: @escaping (OpaquePointer) -> Void
    ) -> UInt {
        let callback:
            @convention(c) (
                OpaquePointer?, UnsafePointer<CChar>?, UnsafePointer<CChar>?,
                OpaquePointer?, UnsafeMutableRawPointer?
            ) -> Void = { _, _, sig, params, data in
                let dataTyped =
                    Unmanaged<CallbackBox<(String, String, (OpaquePointer) -> Void)>>.fromOpaque(
                        data!
                    ).takeUnretainedValue()
                let (namespaceInner, keyInner, handlerInner) = dataTyped.value

                guard let walker = GVariant(params),
                    walker.child(0)?.string() == namespaceInner,
                    walker.child(1)?.string() == keyInner
                else { return }

                if let ptr = walker.child(2)?.pointer { handlerInner(ptr) }
            }

        let data = CallbackBox((namespace, key, handler))

        let handlerId = g_signal_connect_data(
            self.proxy, signal,
            unsafeBitCast(callback, to: GCallback.self),
            Unmanaged.passUnretained(data).toOpaque(),
            nil, .init(0)
        )

        subscriptions.append((handlerId, data))

        return handlerId
    }

    public func unsubscribe(from: UInt) {
        g_signal_handler_disconnect(self.proxy, from)
        subscriptions.removeAll { $0.0 == from }
    }
}

private func decodeLocationData(from raw: OpaquePointer)
    -> Freedesktop.Portal.Location.LocationData?
{
    guard let walker = GVariant(raw) else { return nil }
    let timestamp = walker.lookup("Timestamp")
    return Freedesktop.Portal.Location.LocationData(
        latitude: walker.lookup("Latitude")?.double(),
        longitude: walker.lookup("Longitude")?.double(),
        altitude: walker.lookup("Altitude")?.double(),
        accuracy: walker.lookup("Accuracy")?.double(),
        speed: walker.lookup("Speed")?.double(),
        heading: walker.lookup("Heading")?.double(),
        timestampSeconds: timestamp?.child(0)?.int64(),
        timestampMicroseconds: timestamp?.child(1)?.int64()
    )
}

private func parseLocationUpdate(
    params: OpaquePointer, sessionHandle: String
) -> Freedesktop.Portal.Location.LocationData? {
    guard GVariant(params)?.child(0)?.string() == sessionHandle else { return nil }
    return GVariant(params)?.child(1).flatMap { decodeLocationData(from: $0.pointer) }
}

private func requestResponse(
    bus: Bus, method: String, input: (String) -> GVariant?
) throws(FreedesktopError.BusError) -> GVariant {
    guard let connection = bus.connection() else { throw .failedCall }
    guard let uniqueName = g_dbus_connection_get_unique_name(connection) else { throw .failedCall }

    let token = "swift_cross_ui_\(UUID().uuidString.replacingOccurrences(of: "-", with: "_"))"
    let sender = String(cString: uniqueName)
        .replacingOccurrences(of: ":", with: "")
        .replacingOccurrences(of: ".", with: "_")
    let expectedHandle = "/org/freedesktop/portal/desktop/request/\(sender)/\(token)"

    typealias State = (done: Bool, response: UInt32, results: GVariant?)
    let state = UnsafeMutablePointer<State>.allocate(capacity: 1)
    state.initialize(to: (false, 2, nil))
    defer {
        state.deinitialize(count: 1)
        state.deallocate()
    }

    let callback: DBusSignalHandler = { _, _, _, _, _, params, data in
        guard let params, let data else { return }
        let s = data.assumingMemoryBound(to: State.self)
        guard let walker = GVariant(params),
            let response = walker.child(0)?.uint32()
        else { return }
        s.pointee.response = response
        if let child1 = walker.child(1) {
            s.pointee.results = GVariant(owning: g_variant_ref(child1.pointer))
        }
        s.pointee.done = true
    }

    var sub = g_dbus_connection_signal_subscribe(
        connection, "org.freedesktop.portal.Desktop",
        "org.freedesktop.portal.Request", "Response",
        expectedHandle, nil, G_DBUS_SIGNAL_FLAGS_NONE,
        callback, UnsafeMutableRawPointer(state), nil
    )

    guard let parameters = input(token) else {
        g_dbus_connection_signal_unsubscribe(connection, sub)
        throw .malformedInput
    }

    let result = try bus.call(method: method, parameters: parameters)

    guard let actualHandle = result.child(0)?.string() else {
        g_dbus_connection_signal_unsubscribe(connection, sub)
        throw .failedCall
    }

    if actualHandle != expectedHandle {
        g_dbus_connection_signal_unsubscribe(connection, sub)
        sub = g_dbus_connection_signal_subscribe(
            connection, "org.freedesktop.portal.Desktop",
            "org.freedesktop.portal.Request", "Response",
            actualHandle, nil, G_DBUS_SIGNAL_FLAGS_NONE,
            callback, UnsafeMutableRawPointer(state), nil
        )
    }
    defer { g_dbus_connection_signal_unsubscribe(connection, sub) }

    while !state.pointee.done { g_main_context_iteration(nil, 1) }

    guard state.pointee.response == 0, let results = state.pointee.results else {
        throw .failedCall
    }

    state.pointee.results = nil
    return results
}

public enum Freedesktop {
    public enum Portal {
        public enum Settings {
            fileprivate static let bus = try! Bus(interfaceName: "Settings")

            public enum Version {
                public static func get() throws(FreedesktopError.BusError) -> UInt32 {
                    guard let prop = bus.readProperty("version")
                    else { throw .failedCall }
                    return prop.uint32()
                }
            }

            fileprivate struct SettingField<T> {
                let namespace: String
                let key: String
                let decodeResult: (OpaquePointer) -> T?
                let decodeSignal: (OpaquePointer) -> T?

                func read() throws(FreedesktopError.BusError) -> T {
                    let result = try bus.call(namespace: namespace, key: key, method: "Read")
                    guard let value = decodeResult(result.pointer) else { throw .failedCall }
                    return value
                }

                func observe() -> AsyncStream<T> {
                    AsyncStream { continuation in
                        let id = bus.subscribe(
                            signal: "g-signal::SettingChanged",
                            namespace: namespace,
                            key: key
                        ) { raw in
                            guard let value = decodeSignal(raw) else { return }
                            continuation.yield(value)
                        }
                        continuation.onTermination = { _ in bus.unsubscribe(from: id) }
                    }
                }

                func subscribe(_ handler: @escaping (T) -> Void) -> Task<Void, Never> {
                    Task { @MainActor in
                        for await value in observe() {
                            handler(value)
                        }
                    }
                }
            }

            public enum Appearance {
                public enum ColorScheme {
                    private static let field = SettingField(
                        namespace: "org.freedesktop.appearance",
                        key: "color-scheme",
                        decodeResult: {
                            GVariant($0)?.child(0)?.variant()?.variant()?.uint32()
                        },
                        decodeSignal: { GVariant($0)?.variant()?.uint32() }
                    )

                    public static func read() throws(FreedesktopError.BusError) -> UInt32 {
                        try field.read()
                    }

                    public static func observe() -> AsyncStream<UInt32> {
                        field.observe()
                    }

                    public static func subscribe(_ handler: @escaping (UInt32) -> Void)
                        -> Task<Void, Never>
                    {
                        field.subscribe(handler)
                    }
                }

                public enum AccentColor {
                    private static let field = SettingField<(Float64, Float64, Float64)>(
                        namespace: "org.freedesktop.appearance",
                        key: "accent-color",
                        decodeResult: { raw in
                            guard let triple = GVariant(raw)?.child(0)?.variant()?.variant()
                            else { return nil }
                            guard let r = triple.child(0)?.double(),
                                let g = triple.child(1)?.double(),
                                let b = triple.child(2)?.double()
                            else { return nil }
                            return (r, g, b)
                        },
                        decodeSignal: { raw in
                            guard let inner = GVariant(raw)?.variant() else { return nil }
                            guard let r = inner.child(0)?.double(),
                                let g = inner.child(1)?.double(),
                                let b = inner.child(2)?.double()
                            else { return nil }
                            return (r, g, b)
                        }
                    )

                    public static func read() throws(FreedesktopError.BusError)
                        -> (Float64, Float64, Float64)
                    {
                        try field.read()
                    }

                    public static func observe() -> AsyncStream<(Float64, Float64, Float64)> {
                        field.observe()
                    }

                    public static func subscribe(
                        _ handler: @escaping ((Float64, Float64, Float64)) -> Void
                    ) -> Task<Void, Never> {
                        field.subscribe(handler)
                    }
                }

                public enum Contrast {
                    private static let field = SettingField(
                        namespace: "org.freedesktop.appearance",
                        key: "contrast",
                        decodeResult: {
                            GVariant($0)?.child(0)?.variant()?.variant()?.uint32()
                        },
                        decodeSignal: { GVariant($0)?.variant()?.uint32() }
                    )

                    public static func read() throws(FreedesktopError.BusError) -> UInt32 {
                        try field.read()
                    }

                    public static func observe() -> AsyncStream<UInt32> {
                        field.observe()
                    }

                    public static func subscribe(_ handler: @escaping (UInt32) -> Void)
                        -> Task<Void, Never>
                    {
                        field.subscribe(handler)
                    }
                }

                public enum ReducedMotion {
                    private static let field = SettingField(
                        namespace: "org.freedesktop.appearance",
                        key: "reduced-motion",
                        decodeResult: {
                            GVariant($0)?.child(0)?.variant()?.variant()?.uint32()
                        },
                        decodeSignal: { GVariant($0)?.variant()?.uint32() }
                    )

                    public static func read() throws(FreedesktopError.BusError) -> UInt32 {
                        try field.read()
                    }

                    public static func observe() -> AsyncStream<UInt32> {
                        field.observe()
                    }

                    public static func subscribe(_ handler: @escaping (UInt32) -> Void)
                        -> Task<Void, Never>
                    {
                        field.subscribe(handler)
                    }
                }
            }
        }

        public enum Account {
            private static let bus = try! Bus(interfaceName: "Account")

            public enum Version {
                public static func get() throws(FreedesktopError.BusError) -> UInt32 {
                    guard let prop = bus.readProperty("version")
                    else { throw .failedCall }
                    return prop.uint32()
                }
            }

            public enum UserInformation {
                private static func read(_ key: String) throws(FreedesktopError.BusError)
                    -> String
                {
                    let result = try requestResponse(
                        bus: bus,
                        method: "GetUserInformation"
                    ) { token in
                        // Format: (window_identifier, options_dict)
                        //   ''      = empty window identifier (no parent window)
                        //   @a{sv} = dictionary of string→variant pairs with handle_token
                        // Ref: https://flatpak.github.io/xdg-desktop-portal/docs/doc-org.freedesktop.portal.Account.html#org-freedesktop-portal-account-getuserinformation
                        GVariant.parse("('', @a{sv} {'handle_token': <'\(token)'>})")
                    }
                    guard let value = result.lookup(key)?.string() else {
                        throw .failedCall
                    }
                    return value
                }

                public enum Id {
                    public static func read() throws(FreedesktopError.BusError) -> String {
                        try UserInformation.read("id")
                    }
                }

                public enum Name {
                    public static func read() throws(FreedesktopError.BusError) -> String {
                        try UserInformation.read("name")
                    }
                }

                public enum Image {
                    public static func read() throws(FreedesktopError.BusError) -> String {
                        try UserInformation.read("image")
                    }
                }
            }
        }

        public enum Location {
            public enum RequestedAccuracy: UInt32 {
                case none = 0
                case country = 1
                case city = 2
                case neighborhood = 3
                case street = 4
                case exact = 5
            }

            public struct LocationData {
                public let latitude: Double?
                public let longitude: Double?
                public let altitude: Double?
                public let accuracy: Double?
                public let speed: Double?
                public let heading: Double?
                public let timestampSeconds: Int?
                public let timestampMicroseconds: Int?
            }

            public struct Options {
                public var accuracy: RequestedAccuracy
                public var distanceThreshold: UInt32
                public var timeThreshold: UInt32
                public var parentWindow: String

                public init(
                    accuracy: RequestedAccuracy = .exact,
                    distanceThreshold: UInt32 = 0,
                    timeThreshold: UInt32 = 0,
                    parentWindow: String = ""
                ) {
                    self.accuracy = accuracy
                    self.distanceThreshold = distanceThreshold
                    self.timeThreshold = timeThreshold
                    self.parentWindow = parentWindow
                }
            }

            private static let busState = Mutex<Bus?>(nil)
            private static let session = Mutex<(handle: String?, started: Bool)>((nil, false))

            private static func getBus() throws(FreedesktopError.BusError) -> Bus {
                try busState.withLock { stored throws(FreedesktopError.BusError) -> Bus in
                    if let existing = stored { return existing }
                    let newBus = try Bus(interfaceName: "Location")
                    stored = newBus
                    return newBus
                }
            }

            private static func startSession(options: Options)
                throws(FreedesktopError.BusError)
            {
                if session.withLock({ $0.started }) { return }
                let bus = try getBus()

                let token =
                    "swift_cross_ui_\(UUID().uuidString.replacingOccurrences(of: "-", with: "_"))"
                var parts = ["'session_handle_token': <'\(token)'>"]
                if options.accuracy != .exact {
                    parts.append("'accuracy': <uint32 \(options.accuracy.rawValue)>")
                }
                if options.distanceThreshold != 0 {
                    parts.append("'distance-threshold': <uint32 \(options.distanceThreshold)>")
                }
                if options.timeThreshold != 0 {
                    parts.append("'time-threshold': <uint32 \(options.timeThreshold)>")
                }

                try session.withLock { state throws(FreedesktopError.BusError) in
                    if state.started { return }

                    guard
                        let input = GVariant.parse("(@a{sv} {\(parts.joined(separator: ", "))},)")
                    else { throw .malformedInput }

                    let result = try bus.call(method: "CreateSession", parameters: input)
                    guard let sessionHandle = result.child(0)?.string()
                    else { throw .failedCall }
                    state.handle = sessionHandle

                    let parent = options.parentWindow.isEmpty ? "''" : "'\(options.parentWindow)'"
                    _ = try requestResponse(bus: bus, method: "Start") { token in
                        GVariant.parse(
                            "(@o '\(sessionHandle)', \(parent), @a{sv} {'handle_token': <'\(token)'>})"
                        )
                    }
                    state.started = true
                }
            }

            public enum Version {
                public static func get() throws(FreedesktopError.BusError) -> UInt32 {
                    let bus = try getBus()
                    guard let prop = bus.readProperty("version")
                    else { throw .failedCall }
                    return prop.uint32()
                }
            }

            fileprivate static func readFull(
                options: Options = .init()
            ) throws(FreedesktopError.BusError) -> LocationData {
                try startSession(options: options)
                let sessionHandle = session.withLock { $0.handle! }
                let bus = try getBus()
                guard let connection = bus.connection() else { throw .failedCall }

                typealias State = (done: Bool, data: LocationData?, sh: String)
                let state = UnsafeMutablePointer<State>.allocate(capacity: 1)
                state.initialize(to: (false, nil, sessionHandle))
                defer {
                    state.deinitialize(count: 1)
                    state.deallocate()
                }

                let callback: DBusSignalHandler = { _, _, _, _, _, params, data in
                    guard let params, let data else { return }
                    let s = data.assumingMemoryBound(to: State.self)
                    if let loc = parseLocationUpdate(params: params, sessionHandle: s.pointee.sh) {
                        s.pointee.data = loc
                        s.pointee.done = true
                    }
                }

                let sub = g_dbus_connection_signal_subscribe(
                    connection, "org.freedesktop.portal.Desktop",
                    "org.freedesktop.portal.Location", "LocationUpdated",
                    "/org/freedesktop/portal/desktop", nil,
                    G_DBUS_SIGNAL_FLAGS_NONE,
                    callback, UnsafeMutableRawPointer(state), nil
                )
                defer { g_dbus_connection_signal_unsubscribe(connection, sub) }

                while !state.pointee.done { g_main_context_iteration(nil, 1) }
                guard let data = state.pointee.data else { throw .failedCall }
                return data
            }

            fileprivate static func observeFull(
                options: Options = .init()
            ) -> AsyncStream<LocationData> {
                AsyncStream { continuation in
                    let sessionHandle: String
                    let connection: OpaquePointer
                    do {
                        try startSession(options: options)
                        guard let sh = session.withLock({ $0.handle }) else {
                            continuation.finish()
                            return
                        }
                        sessionHandle = sh
                        let bus = try getBus()
                        guard let conn = bus.connection() else {
                            continuation.finish()
                            return
                        }
                        connection = conn
                    } catch {
                        continuation.finish()
                        return
                    }

                    nonisolated(unsafe) let conn = connection
                    let box = CallbackBox((sessionHandle, continuation))

                    let callback: DBusSignalHandler = { _, _, _, _, _, params, data in
                        guard let params, let data else { return }
                        let b = Unmanaged<
                            CallbackBox<(String, AsyncStream<LocationData>.Continuation)>
                        >.fromOpaque(data).takeUnretainedValue()
                        if let loc = parseLocationUpdate(params: params, sessionHandle: b.value.0) {
                            b.value.1.yield(loc)
                        }
                    }

                    let sub = g_dbus_connection_signal_subscribe(
                        connection, "org.freedesktop.portal.Desktop",
                        "org.freedesktop.portal.Location", "LocationUpdated",
                        "/org/freedesktop/portal/desktop", nil,
                        G_DBUS_SIGNAL_FLAGS_NONE,
                        callback, Unmanaged.passUnretained(box).toOpaque(), nil
                    )

                    continuation.onTermination = { _ in
                        g_dbus_connection_signal_unsubscribe(conn, sub)
                    }
                }
            }

            private struct LocationField<T> {
                let keyPath: KeyPath<LocationData, T?>

                func read(options: Options = .init()) throws(FreedesktopError.BusError) -> T? {
                    try readFull(options: options)[keyPath: keyPath]
                }

                func observe(options: Options = .init()) -> AsyncStream<T?> {
                    AsyncStream { continuation in
                        let task = Task {
                            for await data in observeFull(options: options) {
                                continuation.yield(data[keyPath: keyPath])
                            }
                            continuation.finish()
                        }
                        continuation.onTermination = { _ in task.cancel() }
                    }
                }

                func subscribe(
                    options: Options = .init(),
                    _ handler: @escaping (T?) -> Void
                ) -> Task<Void, Never> {
                    Task { @MainActor in
                        for await value in observe(options: options) {
                            handler(value)
                        }
                    }
                }
            }

            public enum Latitude {
                private static let field = LocationField(keyPath: \.latitude)

                public static func read(options: Options = .init())
                    throws(FreedesktopError.BusError) -> Double?
                {
                    try field.read(options: options)
                }

                public static func observe(options: Options = .init()) -> AsyncStream<Double?> {
                    field.observe(options: options)
                }

                public static func subscribe(
                    options: Options = .init(),
                    _ handler: @escaping (Double?) -> Void
                ) -> Task<Void, Never> {
                    field.subscribe(options: options, handler)
                }
            }

            public enum Longitude {
                private static let field = LocationField(keyPath: \.longitude)

                public static func read(options: Options = .init())
                    throws(FreedesktopError.BusError) -> Double?
                {
                    try field.read(options: options)
                }

                public static func observe(options: Options = .init()) -> AsyncStream<Double?> {
                    field.observe(options: options)
                }

                public static func subscribe(
                    options: Options = .init(),
                    _ handler: @escaping (Double?) -> Void
                ) -> Task<Void, Never> {
                    field.subscribe(options: options, handler)
                }
            }

            public enum Altitude {
                private static let field = LocationField(keyPath: \.altitude)

                public static func read(options: Options = .init())
                    throws(FreedesktopError.BusError) -> Double?
                {
                    try field.read(options: options)
                }

                public static func observe(options: Options = .init()) -> AsyncStream<Double?> {
                    field.observe(options: options)
                }

                public static func subscribe(
                    options: Options = .init(),
                    _ handler: @escaping (Double?) -> Void
                ) -> Task<Void, Never> {
                    field.subscribe(options: options, handler)
                }
            }

            public enum Accuracy {
                private static let field = LocationField(keyPath: \.accuracy)

                public static func read(options: Options = .init())
                    throws(FreedesktopError.BusError) -> Double?
                {
                    try field.read(options: options)
                }

                public static func observe(options: Options = .init()) -> AsyncStream<Double?> {
                    field.observe(options: options)
                }

                public static func subscribe(
                    options: Options = .init(),
                    _ handler: @escaping (Double?) -> Void
                ) -> Task<Void, Never> {
                    field.subscribe(options: options, handler)
                }
            }

            public enum Speed {
                private static let field = LocationField(keyPath: \.speed)

                public static func read(options: Options = .init())
                    throws(FreedesktopError.BusError) -> Double?
                {
                    try field.read(options: options)
                }

                public static func observe(options: Options = .init()) -> AsyncStream<Double?> {
                    field.observe(options: options)
                }

                public static func subscribe(
                    options: Options = .init(),
                    _ handler: @escaping (Double?) -> Void
                ) -> Task<Void, Never> {
                    field.subscribe(options: options, handler)
                }
            }

            public enum Heading {
                private static let field = LocationField(keyPath: \.heading)

                public static func read(options: Options = .init())
                    throws(FreedesktopError.BusError) -> Double?
                {
                    try field.read(options: options)
                }

                public static func observe(options: Options = .init()) -> AsyncStream<Double?> {
                    field.observe(options: options)
                }

                public static func subscribe(
                    options: Options = .init(),
                    _ handler: @escaping (Double?) -> Void
                ) -> Task<Void, Never> {
                    field.subscribe(options: options, handler)
                }
            }

            public enum TimestampSeconds {
                private static let field = LocationField(keyPath: \.timestampSeconds)

                public static func read(options: Options = .init())
                    throws(FreedesktopError.BusError) -> Int?
                {
                    try field.read(options: options)
                }

                public static func observe(options: Options = .init()) -> AsyncStream<Int?> {
                    field.observe(options: options)
                }

                public static func subscribe(
                    options: Options = .init(),
                    _ handler: @escaping (Int?) -> Void
                ) -> Task<Void, Never> {
                    field.subscribe(options: options, handler)
                }
            }

            public enum TimestampMicroseconds {
                private static let field = LocationField(keyPath: \.timestampMicroseconds)

                public static func read(options: Options = .init())
                    throws(FreedesktopError.BusError) -> Int?
                {
                    try field.read(options: options)
                }

                public static func observe(options: Options = .init()) -> AsyncStream<Int?> {
                    field.observe(options: options)
                }

                public static func subscribe(
                    options: Options = .init(),
                    _ handler: @escaping (Int?) -> Void
                ) -> Task<Void, Never> {
                    field.subscribe(options: options, handler)
                }
            }
        }

    }
}
