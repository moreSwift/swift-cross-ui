/// The position of a cell in a table (with row and column numbers starting from 0).
public struct CellPosition {
    /// The row number (starting from 0).
    public var row: Int
    /// The column number (starting from 0).
    public var column: Int

    /// Creates a cell position from a row and column number.
    ///
    /// - Parameters:
    ///   - row: The row number (starting from 0).
    ///   - column: The column number (starting from 0).
    public init(_ row: Int, _ column: Int) {
        self.row = row
        self.column = column
    }
}
