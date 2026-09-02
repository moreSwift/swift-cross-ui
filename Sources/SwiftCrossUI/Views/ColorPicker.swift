/// A control used to select a color from the system color picker UI.
///
/// This renders a button with a color swatch indicating the currently-selected color. Clicking the
/// button opens a backend-dependent dialog, sheet, or window providing a way to set the color. The
/// label is rendered next to the button.
@available(iOS 14, macCatalyst 14, *)
@available(tvOS, unavailable)
public struct ColorPicker<Label: View> {
    private var label: Label
    private var selection: Binding<Color>
    private var supportsOpacity: Bool

    /// Creates a color picker with a text label generated from a title string.
    /// - Parameters:
    ///   - label: The title displayed by the color picker.
    ///   - selection: A ``Binding`` to the variable that displays the selected ``Color``.
    ///   - supportsOpacity: A Boolean value that indicates whether the color picker allows
    ///   adjusting the selected color’s opacity; the default is `true`.
    public nonisolated init(
        _ label: String,
        selection: Binding<Color>,
        supportsOpacity: Bool = true
    ) where Label == Text {
        self.label = Text(label)
        self.selection = selection
        self.supportsOpacity = supportsOpacity
    }

    /// Creates an instance that selects a color.
    /// - Parameters:
    ///   - selection: A ``Binding`` to the variable that displays the selected ``Color``.
    ///   - supportsOpacity: A Boolean value that indicates whether the color picker allows
    ///   adjusting the selected color’s opacity; the default is `true`.
    ///   - label: A view that describes the use of the selected color.
    public nonisolated init(
        selection: Binding<Color>,
        supportsOpacity: Bool = true,
        @ViewBuilder label: () -> Label
    ) {
        self.label = label()
        self.selection = selection
        self.supportsOpacity = supportsOpacity
    }
}

@available(iOS 14, macCatalyst 14, *)
@available(tvOS, unavailable)
extension ColorPicker: View {
    public var body: some View {
        HStack {
            label

            HorizontalControlSpacer()

            ColorPickerImplementation(selection: selection, supportsOpacity: supportsOpacity)
        }
    }
}

struct ColorPickerImplementation: ElementaryView {
    @Binding var selection: Color
    var supportsOpacity: Bool

    let body = EmptyView()

    @CastBackend<BackendFeatures.ColorPickers>(returnsWidget: true)
    func asWidget<Backend: BaseAppBackend>(backend: Backend) -> Backend.Widget {
        backend.createColorPicker()
    }

    @CastBackend<BackendFeatures.ColorPickers>
    func computeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        backend.updateColorPicker(
            widget,
            supportsOpacity: supportsOpacity,
            environment: environment
        ) { resolvedColor in
            selection = Color(resolvedColor)
        }

        let naturalSize = backend.naturalSize(of: widget)
        return ViewLayoutResult.leafView(size: ViewSize(naturalSize))
    }

    @CastBackend<BackendFeatures.ColorPickers>
    func commit<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        backend.setValue(ofColorPicker: widget, to: selection.resolve(in: environment))
        backend.setSize(of: widget, to: layout.size.vector)
    }
}
