/// A view that presents views in two or three columns.
public struct NavigationSplitView<Sidebar: View, MiddleBar: View, Detail: View>: View {
    public var body: some View {
        SplitView(
            sidebar: {
                return sidebar
            },
            detail: {
                if MiddleBar.self == EmptyView.self {
                    detail
                } else {
                    SplitView(
                        sidebar: {
                            return content
                        },
                        detail: {
                            return detail
                        }
                    )
                }
            }
        )
    }

    /// The sidebar content.
    public var sidebar: Sidebar
    /// The middle content.
    public var content: MiddleBar
    /// The detail content.
    public var detail: Detail

    /// Creates a three column split view.
    ///
    /// - Parameters:
    ///   - sidebar: The sidebar content.
    ///   - content: The middle content.
    ///   - detail: The detail content.
    public init(
        @ViewBuilder sidebar: () -> Sidebar,
        @ViewBuilder content: () -> MiddleBar,
        @ViewBuilder detail: () -> Detail
    ) {
        self.sidebar = sidebar()
        self.content = content()
        self.detail = detail()
    }
}

extension NavigationSplitView where MiddleBar == EmptyView {
    /// Creates a two column split view.
    ///
    /// - Parameters:
    ///   - sidebar: The sidebar content.
    ///   - detail: The detail content.
    public init(
        @ViewBuilder sidebar: () -> Sidebar,
        @ViewBuilder detail: () -> Detail
    ) {
        self.sidebar = sidebar()
        content = EmptyView()
        self.detail = detail()
    }
}
