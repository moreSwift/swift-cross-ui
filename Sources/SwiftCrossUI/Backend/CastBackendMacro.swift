/// Modifies a function body in a view implementation to automatically
/// cast a backend instance.
///
/// This is for internal SCUI use and should not be exposed publicly -- the
/// macro is not especially robust and only performs minimal checking.
///
/// This macro expects to be attached to a `func` declaration with a parameter
/// named `backend`. It will also recognize a parameter named `widget` and will
/// insert the appropriate cast.
///
/// - Parameters:
///   - backendGenericName: The name of the generic parameter to the inner
///     function. If `nil`, one will be generated randomly.
///   - returnsWidget: Whether the attached function returns a widget. If it
///     does, the macro will insert an extra cast to make sure the correct
///     widget type comes out.
@attached(body)
internal macro CastBackend<NewBackend>(
    backendGenericName: String? = nil,
    returnsWidget: Bool = false
) = #externalMacro(module: "SwiftCrossUIMacrosPlugin", type: "CastBackendMacro")
