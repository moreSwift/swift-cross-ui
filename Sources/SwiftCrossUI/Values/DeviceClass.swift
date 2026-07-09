/// A class of devices. Used to determine adaptive sizing behaviour such as
/// the sizes of the various dynamic ``Font/TextStyle``s.
public struct DeviceClass: Hashable, Sendable {
    @_spi(Backends) public enum Kind: Sendable {
        case desktop
        case phone
        case tablet
        case tv
        case watch
    }

    @_spi(Backends) public var kind: Kind

    /// The device class for laptops and desktops.
    public static let desktop = Self(kind: .desktop)
    /// The device class for smartphones.
    public static let phone = Self(kind: .phone)
    /// The device class for tablets (e.g. iPads).
    public static let tablet = Self(kind: .tablet)
    /// The device class for smart TVs (e.g. Apple TVs).
    public static let tv = Self(kind: .tv)
    /// The device class for smart watches.
    public static let watch = Self(kind: .watch)
}
