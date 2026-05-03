/// A labelled column with a view for each row in a table.
public struct TableColumn<RowValue, Content: View> {
    /// The label displayed at the top of the column (also known as the column title).
    public var label: String
    /// The content displayed for this column of each row of the table.
    public var content: (RowValue) -> Content
}

extension TableColumn {
    /// Creates a column.
    ///
    /// - Parameters:
    ///   - label: The label displayed at the top of the column (also known as
    ///     the column title).
    ///   - content: The content displayed for this column of each row of the
    ///     table.
    public init(_ label: String, @ViewBuilder content: @escaping (RowValue) -> Content) {
        self.label = label
        self.content = content
    }
}

extension TableColumn where Content == Text {
    /// Creates a column with that displays a string property and has a text
    /// label.
    ///
    /// - Parameters:
    ///   - label: The label displayed at the top of the column (also known as
    ///     the column title).
    ///   - keyPath: A key path to the string value to display.
    public init(_ label: String, value keyPath: KeyPath<RowValue, String>) {
        self.label = label
        self.content = { row in
            Text(row[keyPath: keyPath])
        }
    }
}
