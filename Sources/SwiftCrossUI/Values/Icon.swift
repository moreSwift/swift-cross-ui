#if compiler(>=6.2.3)
    @nonexhaustive(warn)
#endif
public enum Icon: Hashable, Sendable {
    case share
    case plus
    case edit
    case back
}
