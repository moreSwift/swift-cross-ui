/// A view that behaves like a spacer on certain device classes, for `HStack`-based controls like
/// ``ColorPicker`` and switch-style ``Toggle``.
struct HorizontalControlSpacer: View {
    @Environment(\.deviceClass) private var deviceClass

    var body: some View {
        if deviceClass != .desktop {
            HStack { // workaround for #728
                Spacer()
            }
        }
    }
}
