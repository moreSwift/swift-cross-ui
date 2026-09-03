import Testing

import DummyBackend
@testable @_spi(Backends) import SwiftCrossUI

@Suite("Testing for table layouts")
struct TableLayoutTests {
    struct Person {
        var name: String
        var age: Int
    }

    let backend: DummyBackend
    let window: DummyBackend.Window
    let environment: EnvironmentValues

    let people = [
        Person(name: "Alice", age: 99),
        Person(name: "Bob", age: 42),
        Person(name: "Carol", age: 7),
    ]

    @MainActor
    init() {
        backend = DummyBackend()
        window = backend.createWindow(withDefaultSize: nil, id: "window")
        environment = EnvironmentValues(backend: backend).with(\.window, window)
    }

    @MainActor
    func table() -> some View {
        Table(people) {
            TableColumn("Name", value: \Person.name)
            TableColumn("Age", value: \Person.age.description)
        }
    }

    /// The height each row occupies given the backend's metrics: the taller of
    /// the cell's content and the backend's default row content height, plus
    /// padding above and below.
    @MainActor
    var expectedRowHeight: Int {
        let cellHeight = Int(environment.resolvedFont.lineHeight)
        return max(cellHeight, backend.defaultTableRowContentHeight)
            + backend.defaultTableCellVerticalPadding * 2
    }

    /// The height the table occupies given the backend's metrics: its rows,
    /// its column header, and the space the backend reserves around its rows.
    @MainActor
    var expectedTableHeight: Int {
        let table = backend.createTable()
        return people.count * expectedRowHeight
            + backend.tableHeaderHeight(of: table)
            + backend.tableVerticalPadding(of: table)
    }

    @MainActor
    @Test("Table sizes to its content when proposed no height (#692)")
    func tableSizesToContentWithoutHeightProposal() {
        let expectedHeight = expectedTableHeight

        let node = ViewGraphNode(for: table(), backend: backend, environment: environment)
        let result = node.computeLayout(
            proposedSize: ProposedViewSize(600, nil),
            environment: environment
        )

        #expect(result.size.vector.y == expectedHeight)
    }

    @MainActor
    @Test("Table accepts a proposed height")
    func tableAcceptsProposedHeight() {
        let node = ViewGraphNode(for: table(), backend: backend, environment: environment)
        let result = node.computeLayout(
            proposedSize: ProposedViewSize(600, 400),
            environment: environment
        )

        #expect(result.size.vector.y == 400)
    }

    @MainActor
    @Test("Table contributes its content height to a stack (#692)")
    func tableContributesHeightToStack() {
        let text = Text("Section")
        let textNode = ViewGraphNode(for: text, backend: backend, environment: environment)
        let textHeight = textNode.computeLayout(
            proposedSize: ProposedViewSize(600, nil),
            environment: environment
        ).size.vector.y

        let view = VStack(spacing: 0) {
            text
            table()
        }
        let node = ViewGraphNode(for: view, backend: backend, environment: environment)
        let result = node.computeLayout(
            proposedSize: ProposedViewSize(600, nil),
            environment: environment
        )

        #expect(result.size.vector.y == textHeight + expectedTableHeight)
    }
}
