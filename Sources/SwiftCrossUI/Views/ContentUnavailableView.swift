/// An interface, consisting of a label and additional content,
/// that you display when the content of your app is unavailable to users.
public struct ContentUnavailableView<Label: View, Description: View, Actions: View>: View {
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
    
    public var body: some View {
        VStack {
            label.font(.system(size: 26.0)).foregroundColor(.gray)
            description.font(.system(size: 13.0)).foregroundColor(.gray)
            HStack {
                actions
                .environment(\.font, .system(.body))
                .foregroundColor(.adaptive(light: .black, dark: .white))
            }
        }
        .if(backend.deviceClass != .desktop) { view in
            view.padding(30)
        }
        .if(backend.deviceClass == .desktop) { view in
            view.frame(width: 360)
        }
    }
}
