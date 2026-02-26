/// A control that displays an editable text interface.
public struct TextField: ElementaryView, View {
    /// The ideal width of a TextField.
    private static let idealWidth: Double = 100

    /// The label to show when the field is empty.
    private var placeholder: String
    /// The field's content.
    @Binding
    private var text: String

    /// Creates an editable text field with a given placeholder.
    public init(_ placeholder: String = "", text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    /// Creates an editable text field with a given placeholder.
    @available(
        *, deprecated,
        message: "Use TextField(_:text:) instead",
        renamed: "TextField.init(_:text:)"
    )
    public init(_ placeholder: String = "", _ value: Binding<String>? = nil) {
        self.placeholder = placeholder
        var dummy = ""
        self._text = value ?? Binding(get: { dummy }, set: { dummy = $0 })
    }

    func asWidget<Backend: AppBackend>(backend: Backend) -> Backend.Widget {
        return backend.createTextField()
    }

    func computeLayout<Backend: AppBackend>(
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

    func commit<Backend: AppBackend>(
        _ widget: Backend.Widget,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        backend.updateTextField(
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
                            Unnecessary write to text Binding of TextField detected, \
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
        if text != backend.getContent(ofTextField: widget) {
            backend.setContent(ofTextField: widget, to: text)
        }

        backend.setSize(of: widget, to: layout.size.vector)
    }
}
