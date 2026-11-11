/// An interface, consisting of a label and additional content,
/// that you display when the content of your app is unavailable to users.
public struct ContentUnavailableView<Label: View, Description: View, Actions: View>: View {
    /// Creates an interface, consisting of a label and additional content,
    /// that you display when the content of your app is unavailable to users.
    ///
    /// - Parameters:
    ///   - label: The label that describes the view.
    ///   - description: The view giving more information about the reason
    ///     for the content being unavailable.
    ///   - actions: The view containing actions related to the content being unavailable.
    ///     For example "Back to Home", "Login" or "Refresh".
    public init(
        @ViewBuilder label: () -> Label,
        @ViewBuilder description: () -> Description = { EmptyView() },
        @ViewBuilder actions: () -> Actions = { EmptyView() }
    ) {
        self.label = label()
        self.description = description()
        self.actions = actions()
    }

    private var label: Label
    private var description: Description
    private var actions: Actions

    @Environment(\.backend) var backend
    @Environment(\.foregroundColor) var environmentForegroundColor

    var labelFont: Font {
        switch backend.deviceClass.kind {
            case .phone, .tablet, .watch: .title2
            case .tv: .headline
            case .desktop: .largeTitle
        }
    }

    var descriptionFont: Font {
        switch backend.deviceClass.kind {
            case .phone, .tablet, .tv, .watch: .subheadline
            case .desktop: .body
        }
    }

    var labelColor: Color {
        if let environmentForegroundColor { return environmentForegroundColor }
        if backend.deviceClass == .desktop { return .gray }
        return .adaptive(light: .black, dark: .white)
    }

    public var body: some View {
        VStack {
            label
                .font(labelFont)
                .foregroundColor(labelColor)
            description
                .font(descriptionFont)
                .foregroundColor(environmentForegroundColor ?? .gray)

            if backend.deviceClass == .desktop {
                HStack {
                    actions
                        .font(.body)
                        .foregroundColor(
                            environmentForegroundColor
                                ?? .adaptive(light: .black, dark: .white)
                        )
                }
            } else {
                VStack {
                    actions
                        .font(.body)
                }
            }
        }
        .if(backend.deviceClass != .desktop) { view in
            view.padding(30)
        }
        .if(backend.deviceClass == .desktop) { view in
            view.frame(maxWidth: 360)
        }
    }
}
