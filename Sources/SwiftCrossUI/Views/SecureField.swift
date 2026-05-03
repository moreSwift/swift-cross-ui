/// A control that displays an editable text interface, hiding characters
/// as they're typed.
public struct SecureField: ElementaryView, View {
    /// The ideal width of a `SecureField`.
    private static let idealWidth: Double = 100

    /// The label to show when the field is empty.
    private var placeholder: String
    /// The field's content.
    @Binding private var text: String

    /// Creates an editable secure text field with a given placeholder.
    ///
    /// - Parameters:
    ///   - placeholder: The label to show when the field is empty.
    ///   - text: The field's content.
    public init(_ placeholder: String = "", text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    func asWidget<Backend: BaseAppBackend>(backend: Backend) -> Backend.Widget {
        return backend.createSecureField()
    }

    func computeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        let naturalHeight = backend.naturalSize(of: widget).y
        let size = ViewSize(
            proposedSize.width ?? Self.idealWidth,
            Double(naturalHeight)
        )

        // TODO: Allow backends to set their own ideal text field width
        return ViewLayoutResult.leafView(size: size)
    }

    func commit<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        backend.updateSecureField(
            widget,
            placeholder: placeholder,
            environment: environment,
            onChange: { newValue in
                #if DEBUG
                    // We perform this check in debug mode to catch backends that cause
                    // unnecessary binding writes, but avoid doing so in release mode
                    // because comparing text may often be more expensive than just
                    // avoiding the additional write at the backend level. These
                    // additional writes are often the result of the handler being
                    // triggered when we call backend.setContent(ofTextField:to:)
                    if self.text == newValue {
                        logger.warning(
                            """
                            Unnecessary write to text Binding of SecureField detected, \
                            please open an issue at \(Meta.issueReportingURL) \
                            so we can fix it for \(type(of: backend)).
                            """
                        )
                    }
                #endif

                self.text = newValue
            },
            onSubmit: environment.onSubmit ?? {}
        )

        let text = text
        if text != backend.getContent(ofSecureField: widget) {
            backend.setContent(ofSecureField: widget, to: text)
        }

        backend.setSize(of: widget, to: layout.size.vector)
    }
}
