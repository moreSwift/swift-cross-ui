@MainActor private protocol TextFieldProtocol: ElementaryView, View {
    static var isSecure: Bool { get }
    var placeholder: String { get set }
    var text: Binding<String> { get set }
    init(_ placeholder: String, text: Binding<String>)
}

extension TextFieldProtocol {
    /// The ideal width of a `TextField` / `SecureField`.
    private static var idealWidth: Double { 100 }

    /// Creates an editable text field with a given placeholder.
    @available(*, deprecated, renamed: "init(_:text:)")
    public init(_ placeholder: String = "", _ value: Binding<String>? = nil) {
        var dummy = ""
        self.init(placeholder, text: value ?? Binding(get: { dummy }, set: { dummy = $0 }))
    }

    func asWidget<Backend: AppBackend>(backend: Backend) -> Backend.Widget {
        return backend.createTextField(secure: Self.isSecure)
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
                    if self.text.wrappedValue == newValue {
                        logger.warning(
                                """
                                Unnecessary write to text Binding of \(Self.self) detected, \
                                please open an issue at \(Meta.issueReportingURL) \
                                so we can fix it for \(type(of: backend)).
                                """
                        )
                    }
                #endif

                self.text.wrappedValue = newValue
            },
            onSubmit: environment.onSubmit ?? {}
        )

        let text = text.wrappedValue
        if text != backend.getContent(ofTextField: widget) {
            backend.setContent(ofTextField: widget, to: text)
        }

        backend.setSize(of: widget, to: layout.size.vector)
    }
}

/// A control that displays an editable text interface.
public struct TextField: TextFieldProtocol {
    fileprivate static let isSecure = false

    /// The label to show when the field is empty.
    fileprivate var placeholder: String

    /// The field's content.
    fileprivate var text: Binding<String>

    /// Creates an editable text field with a given placeholder.
    ///
    /// - Parameters:
    ///   - placeholder: The label to show when the field is empty.
    ///   - text: The field's content.
    public init(_ placeholder: String = "", text: Binding<String>) {
        self.placeholder = placeholder
        self.text = text
    }
}

/// A control that displays an editable text interface with hidden input.
public struct SecureField: TextFieldProtocol {
    fileprivate static let isSecure = true

    /// The label to show when the field is empty.
    fileprivate var placeholder: String

    /// The field's content.
    fileprivate var text: Binding<String>

    /// Creates an editable secure text field with a given placeholder.
    ///
    /// - Parameters:
    ///   - placeholder: The label to show when the field is empty.
    ///   - text: The field's content.
    public init(_ placeholder: String = "", text: Binding<String>) {
        self.placeholder = placeholder
        self.text = text
    }
}
