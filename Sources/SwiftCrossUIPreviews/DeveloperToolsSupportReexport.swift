#if os(macOS) || os(iOS) || os(tvOS) || os(visionOS) || os(watchOS)
    // The preview registration expands to code referring to
    // `DeveloperToolsSupport`, and a macro expansion can't import anything
    // itself, so that module has to already be in scope wherever `#Preview`
    // is written. Re-exporting it here covers every file that imports this
    // module.
    @_exported import DeveloperToolsSupport
#endif
