import Foundation

/// ``ObservableObject`` values nested within an ``ObservableObject`` object
/// will only have their changes published by the parent ``ObservableObject``
/// if marked with this marker protocol. This avoids uncertainty around which
/// properties will or will not have their changes published by the parent.
/// For clarity reasons, you shouldn't conform your own types to this protocol.
/// Instead, apply the ``Published`` property wrapper when needed.
///
/// ```swift
/// // The following example highlights why the marker protocol exists.
///
/// class MyNestedState: ObservableObject {
///     @Published var count = 0
/// }
///
/// class MyState: ObservableObject {
///     // Without the marker protocol mechanism in place, `nested` would get
///     // published as well as `index`. However, that would not be possible to
///     // know without looking at the definition to check if `MyNestedState`
///     // is `ObservableObject`. Because of the marker protocol, it is required
///     // that both properties are annotated with `@Published` (which conforms
///     // to the marker protocol).
///     var nested = MyNestedState()
///     @Published var index = 0
/// }
/// ```
///
public protocol PublishedMarkerProtocol {}

/// A wrapper which publishes a change whenever the wrapped value is set. If
/// the wrapped value is ``ObservableObject``, its `didChange` publisher will
/// also be forwarded to the wrapper's publisher.
///
/// A compile time warning is emitted if the wrapper is applied to a class
/// which isn't ``ObservableObject`` because this is considered undesired
/// behaviour. Only replacing the value with a new instance of the class would
/// cause a change to be published; changing the class' properties would not.
/// The warning will show up as a deprecation, but it isn't (as you could guess
/// from the accompanying message).
@propertyWrapper
public final class Published<Value>: ObservableObject, PublishedMarkerProtocol {
    /// A handle that can be used to cancel the link to the previous upstream publisher.
    private var upstreamLinkCancellable: Cancellable?

    /// A binding to the inner value.
    public var projectedValue: Binding<Value> {
        Binding(
            get: {
                self.wrappedValue
            },
            set: { newValue in
                self.wrappedValue = newValue
            }
        )
    }

    /// The underlying wrapped value.
    public var wrappedValue: Value {
        didSet {
            valueDidChange()
        }
    }

    /// A publisher that publishes any observable changes made to
    /// ``Published/wrappedValue``.
    public let didChange = Publisher().tag(with: "Published")

    /// Creates a publishing wrapper around a value type or
    /// ``ObservableObject`` class.
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
        valueDidChange(publish: false)
    }

    /// Creates a publishing wrapper around a value type or ``ObservableObject``
    /// class.
    public init(wrappedValue: Value) where Value: AnyObject, Value: ObservableObject {
        // This initializer exists to redirect valid classes away from the initializer which
        // contains a compile time warning (through deprecation).
        self.wrappedValue = wrappedValue
        valueDidChange(publish: false)
    }

    /// Creates a wrapper around a non-ObservableObject class. Setting
    /// ``Published/wrappedValue`` to a new instance of the class is the only
    /// change that will get published. This is hardly ever intentional, so
    /// this initializer variant contains a deprecation warning to warn
    /// developers (but does nothing functionally different).
    @available(
        *,
        deprecated,
        message: "A class must conform to ObservableObject to be Published"
    )
    public init(wrappedValue: Value) where Value: AnyObject {
        self.wrappedValue = wrappedValue
        valueDidChange(publish: false)
    }

    /// Handles changing a value. If `publish` is `false` the change won't be
    /// published, but if the wrapped value is ``ObservableObject`` the new
    /// upstream publisher will still get relinked.
    public func valueDidChange(publish: Bool = true) {
        if publish {
            didChange.send()
        }

        if let upstream = wrappedValue as? ObservableObject {
            upstreamLinkCancellable?.cancel()
            upstreamLinkCancellable = didChange.link(toUpstream: upstream.didChange)
        }
    }
}

extension Published: Codable where Value: Codable {
    public convenience init(from decoder: Decoder) throws {
        self.init(wrappedValue: try Value(from: decoder))
    }

    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}

@available(*, deprecated, message: "Replace Observed with Published")
public typealias Observed = Published
