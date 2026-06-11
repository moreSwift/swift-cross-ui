/// Creates an ``EnvironmentValues``, or ``AppStorageValues`` entry.
///
/// You can create ``EnvironmentValues`` entries by extending the ``EnvironmentValues`` struct with
/// `@Entry`-annotated properties:
/// ```swift
/// extension EnvironmentValues {
///     @Entry var myCustomValue: String = "Default value"
///     @Entry var anotherCustomValue = true
/// }
/// ```
///
/// You can create ``AppStorageValues`` entries by extending the ``AppStorageValues`` struct with
/// `@Entry`-annotated properties:
/// ```swift
/// extension AppStorageValues {
///     @Entry var myCustomValue: String = "Default value"
///     @Entry var anotherCustomValue = true
/// }
/// ```
@attached(accessor) @attached(peer, names: prefixed(__Key_))
public macro Entry() =
    #externalMacro(
        module: "SwiftCrossUIMacrosPlugin",
        type: "EntryMacro"
    )
