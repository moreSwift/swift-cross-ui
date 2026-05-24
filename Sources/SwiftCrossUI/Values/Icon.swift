#if compiler(>=6.2.3)
    @nonexhaustive(warn)
#endif
public enum Icon: Hashable, Sendable {
    case share
    case plus
    case back
    case cut
    case copy
    case paste
    case search
}
