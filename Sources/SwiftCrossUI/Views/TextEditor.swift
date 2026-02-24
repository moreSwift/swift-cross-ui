/// A control for editing multiline text.
public struct TextEditor: ElementaryView {
    @Binding var text: String

    public init(text: Binding<String>) {
        _text = text
    }

    func asWidget<Backend: AppBackend>(backend: Backend) -> Backend.Widget {
        backend.createTextEditor()
    }

    func computeLayout<Backend: AppBackend>(
        _ widget: Backend.Widget,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        // Avoid evaluating the binding multiple times
        let content = text

        let size: ViewSize
        if proposedSize == .unspecified {
            size = ViewSize(10, 10)
        } else if let width = proposedSize.width, proposedSize.height == nil {
            // See ``Text``'s computeLayout for a more details on why we clamp
            // the width to be positive.
            let idealSize = backend.size(
                of: content,
                whenDisplayedIn: widget,
                // For text, an infinite proposal is the same as an unspecified
                // proposal, and this works nicer with most backends than converting
                // .infinity to a large integer (which is the alternative).
                proposedWidth: width == .infinity ? nil : max(1, LayoutSystem.roundSize(width)),
                proposedHeight: nil,
                environment: environment
            )
            size = ViewSize(
                max(width, Double(idealSize.x)),
                Double(idealSize.y)
            )
        } else {
            size = proposedSize.replacingUnspecifiedDimensions(by: ViewSize(10, 10))
        }

        return ViewLayoutResult.leafView(size: size)
    }

    func commit<Backend: AppBackend>(
        _ widget: Backend.Widget,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        // Avoid evaluating the binding multiple times
        let content = self.text

        backend.updateTextEditor(widget, environment: environment) { newValue in
            #if DEBUG
                if text == newValue {
                    logger.warning(
                        """
                        Unnecessary write to text Binding of TextEditor detected, \
                        please open an issue on the SwiftCrossUI GitHub repository \
                        so we can fix it on \(type(of: backend)).
                        """
                    )
                }
            #endif
            self.text = newValue
        }
        if text != backend.getContent(ofTextEditor: widget) {
            backend.setContent(ofTextEditor: widget, to: content)
        }

        backend.setSize(of: widget, to: layout.size.vector)
    }
}
