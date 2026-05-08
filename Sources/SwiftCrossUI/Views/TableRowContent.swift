// This file was generated using gyb. Do not edit it directly. Edit
// TableRowContent.swift.gyb instead.

public protocol TableRowContent<RowValue> {
    associatedtype RowValue
    associatedtype RowContent: View

    var labels: [String] { get }

    func content(for row: RowValue) -> RowContent
}

public struct EmptyTableRowContent<RowValue>: TableRowContent {
    public typealias RowContent = EmptyView

    public var labels: [String] {
        []
    }

    public init() {}

    public func content(for row: RowValue) -> EmptyView {
        EmptyView()
    }
}

public struct TupleTableRowContent1<RowValue, Content0: View>: TableRowContent {
    public typealias RowContent = TupleView1<Content0>

    public var column0: TableColumn<RowValue, Content0>

    public var labels: [String] {
        [column0.label]
    }

    public init(_ column0: TableColumn<RowValue, Content0>) {
        self.column0 = column0
    }

    public func content(for row: RowValue) -> RowContent {
        TupleView1(column0.content(row))
    }
}

public struct TupleTableRowContent2<RowValue, Content0: View, Content1: View>: TableRowContent {
    public typealias RowContent = TupleView2<Content0, Content1>

    public var column0: TableColumn<RowValue, Content0>
    public var column1: TableColumn<RowValue, Content1>

    public var labels: [String] {
        [column0.label, column1.label]
    }

    public init(
        _ column0: TableColumn<RowValue, Content0>,
        _ column1: TableColumn<RowValue, Content1>
    ) {
        self.column0 = column0
        self.column1 = column1
    }

    public func content(for row: RowValue) -> RowContent {
        TupleView2(column0.content(row), column1.content(row))
    }
}

public struct TupleTableRowContent3<RowValue, Content0: View, Content1: View, Content2: View>:
    TableRowContent
{
    public typealias RowContent = TupleView3<Content0, Content1, Content2>

    public var column0: TableColumn<RowValue, Content0>
    public var column1: TableColumn<RowValue, Content1>
    public var column2: TableColumn<RowValue, Content2>

    public var labels: [String] {
        [column0.label, column1.label, column2.label]
    }

    public init(
        _ column0: TableColumn<RowValue, Content0>,
        _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<RowValue, Content2>
    ) {
        self.column0 = column0
        self.column1 = column1
        self.column2 = column2
    }

    public func content(for row: RowValue) -> RowContent {
        TupleView3(column0.content(row), column1.content(row), column2.content(row))
    }
}

public struct TupleTableRowContent4<
    RowValue,
    Content0: View,
    Content1: View,
    Content2: View,
    Content3: View
>: TableRowContent {
    public typealias RowContent = TupleView4<Content0, Content1, Content2, Content3>

    public var column0: TableColumn<RowValue, Content0>
    public var column1: TableColumn<RowValue, Content1>
    public var column2: TableColumn<RowValue, Content2>
    public var column3: TableColumn<RowValue, Content3>

    public var labels: [String] {
        [column0.label, column1.label, column2.label, column3.label]
    }

    public init(
        _ column0: TableColumn<RowValue, Content0>,
        _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<RowValue, Content2>,
        _ column3: TableColumn<RowValue, Content3>
    ) {
        self.column0 = column0
        self.column1 = column1
        self.column2 = column2
        self.column3 = column3
    }

    public func content(for row: RowValue) -> RowContent {
        TupleView4(
            column0.content(row),
            column1.content(row),
            column2.content(row),
            column3.content(row)
        )
    }
}

public struct TupleTableRowContent5<
    RowValue,
    Content0: View,
    Content1: View,
    Content2: View,
    Content3: View,
    Content4: View
>: TableRowContent {
    public typealias RowContent = TupleView5<Content0, Content1, Content2, Content3, Content4>

    public var column0: TableColumn<RowValue, Content0>
    public var column1: TableColumn<RowValue, Content1>
    public var column2: TableColumn<RowValue, Content2>
    public var column3: TableColumn<RowValue, Content3>
    public var column4: TableColumn<RowValue, Content4>

    public var labels: [String] {
        [column0.label, column1.label, column2.label, column3.label, column4.label]
    }

    public init(
        _ column0: TableColumn<RowValue, Content0>,
        _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<RowValue, Content2>,
        _ column3: TableColumn<RowValue, Content3>,
        _ column4: TableColumn<RowValue, Content4>
    ) {
        self.column0 = column0
        self.column1 = column1
        self.column2 = column2
        self.column3 = column3
        self.column4 = column4
    }

    public func content(for row: RowValue) -> RowContent {
        TupleView5(
            column0.content(row),
            column1.content(row),
            column2.content(row),
            column3.content(row),
            column4.content(row)
        )
    }
}

public struct TupleTableRowContent6<
    RowValue,
    Content0: View,
    Content1: View,
    Content2: View,
    Content3: View,
    Content4: View,
    Content5: View
>: TableRowContent {
    public typealias RowContent = TupleView6<
        Content0,
        Content1,
        Content2,
        Content3,
        Content4,
        Content5
    >

    public var column0: TableColumn<RowValue, Content0>
    public var column1: TableColumn<RowValue, Content1>
    public var column2: TableColumn<RowValue, Content2>
    public var column3: TableColumn<RowValue, Content3>
    public var column4: TableColumn<RowValue, Content4>
    public var column5: TableColumn<RowValue, Content5>

    public var labels: [String] {
        [column0.label, column1.label, column2.label, column3.label, column4.label, column5.label]
    }

    public init(
        _ column0: TableColumn<RowValue, Content0>,
        _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<RowValue, Content2>,
        _ column3: TableColumn<RowValue, Content3>,
        _ column4: TableColumn<RowValue, Content4>,
        _ column5: TableColumn<RowValue, Content5>
    ) {
        self.column0 = column0
        self.column1 = column1
        self.column2 = column2
        self.column3 = column3
        self.column4 = column4
        self.column5 = column5
    }

    public func content(for row: RowValue) -> RowContent {
        TupleView6(
            column0.content(row),
            column1.content(row),
            column2.content(row),
            column3.content(row),
            column4.content(row),
            column5.content(row)
        )
    }
}

public struct TupleTableRowContent7<
    RowValue,
    Content0: View,
    Content1: View,
    Content2: View,
    Content3: View,
    Content4: View,
    Content5: View,
    Content6: View
>: TableRowContent {
    public typealias RowContent = TupleView7<
        Content0,
        Content1,
        Content2,
        Content3,
        Content4,
        Content5,
        Content6
    >

    public var column0: TableColumn<RowValue, Content0>
    public var column1: TableColumn<RowValue, Content1>
    public var column2: TableColumn<RowValue, Content2>
    public var column3: TableColumn<RowValue, Content3>
    public var column4: TableColumn<RowValue, Content4>
    public var column5: TableColumn<RowValue, Content5>
    public var column6: TableColumn<RowValue, Content6>

    public var labels: [String] {
        [
            column0.label,
            column1.label,
            column2.label,
            column3.label,
            column4.label,
            column5.label,
            column6.label,
        ]
    }

    public init(
        _ column0: TableColumn<RowValue, Content0>,
        _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<RowValue, Content2>,
        _ column3: TableColumn<RowValue, Content3>,
        _ column4: TableColumn<RowValue, Content4>,
        _ column5: TableColumn<RowValue, Content5>,
        _ column6: TableColumn<RowValue, Content6>
    ) {
        self.column0 = column0
        self.column1 = column1
        self.column2 = column2
        self.column3 = column3
        self.column4 = column4
        self.column5 = column5
        self.column6 = column6
    }

    public func content(for row: RowValue) -> RowContent {
        TupleView7(
            column0.content(row),
            column1.content(row),
            column2.content(row),
            column3.content(row),
            column4.content(row),
            column5.content(row),
            column6.content(row)
        )
    }
}

public struct TupleTableRowContent8<
    RowValue,
    Content0: View,
    Content1: View,
    Content2: View,
    Content3: View,
    Content4: View,
    Content5: View,
    Content6: View,
    Content7: View
>: TableRowContent {
    public typealias RowContent = TupleView8<
        Content0,
        Content1,
        Content2,
        Content3,
        Content4,
        Content5,
        Content6,
        Content7
    >

    public var column0: TableColumn<RowValue, Content0>
    public var column1: TableColumn<RowValue, Content1>
    public var column2: TableColumn<RowValue, Content2>
    public var column3: TableColumn<RowValue, Content3>
    public var column4: TableColumn<RowValue, Content4>
    public var column5: TableColumn<RowValue, Content5>
    public var column6: TableColumn<RowValue, Content6>
    public var column7: TableColumn<RowValue, Content7>

    public var labels: [String] {
        [
            column0.label,
            column1.label,
            column2.label,
            column3.label,
            column4.label,
            column5.label,
            column6.label,
            column7.label,
        ]
    }

    public init(
        _ column0: TableColumn<RowValue, Content0>,
        _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<RowValue, Content2>,
        _ column3: TableColumn<RowValue, Content3>,
        _ column4: TableColumn<RowValue, Content4>,
        _ column5: TableColumn<RowValue, Content5>,
        _ column6: TableColumn<RowValue, Content6>,
        _ column7: TableColumn<RowValue, Content7>
    ) {
        self.column0 = column0
        self.column1 = column1
        self.column2 = column2
        self.column3 = column3
        self.column4 = column4
        self.column5 = column5
        self.column6 = column6
        self.column7 = column7
    }

    public func content(for row: RowValue) -> RowContent {
        TupleView8(
            column0.content(row),
            column1.content(row),
            column2.content(row),
            column3.content(row),
            column4.content(row),
            column5.content(row),
            column6.content(row),
            column7.content(row)
        )
    }
}

public struct TupleTableRowContent9<
    RowValue,
    Content0: View,
    Content1: View,
    Content2: View,
    Content3: View,
    Content4: View,
    Content5: View,
    Content6: View,
    Content7: View,
    Content8: View
>: TableRowContent {
    public typealias RowContent = TupleView9<
        Content0,
        Content1,
        Content2,
        Content3,
        Content4,
        Content5,
        Content6,
        Content7,
        Content8
    >

    public var column0: TableColumn<RowValue, Content0>
    public var column1: TableColumn<RowValue, Content1>
    public var column2: TableColumn<RowValue, Content2>
    public var column3: TableColumn<RowValue, Content3>
    public var column4: TableColumn<RowValue, Content4>
    public var column5: TableColumn<RowValue, Content5>
    public var column6: TableColumn<RowValue, Content6>
    public var column7: TableColumn<RowValue, Content7>
    public var column8: TableColumn<RowValue, Content8>

    public var labels: [String] {
        [
            column0.label,
            column1.label,
            column2.label,
            column3.label,
            column4.label,
            column5.label,
            column6.label,
            column7.label,
            column8.label,
        ]
    }

    public init(
        _ column0: TableColumn<RowValue, Content0>,
        _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<RowValue, Content2>,
        _ column3: TableColumn<RowValue, Content3>,
        _ column4: TableColumn<RowValue, Content4>,
        _ column5: TableColumn<RowValue, Content5>,
        _ column6: TableColumn<RowValue, Content6>,
        _ column7: TableColumn<RowValue, Content7>,
        _ column8: TableColumn<RowValue, Content8>
    ) {
        self.column0 = column0
        self.column1 = column1
        self.column2 = column2
        self.column3 = column3
        self.column4 = column4
        self.column5 = column5
        self.column6 = column6
        self.column7 = column7
        self.column8 = column8
    }

    public func content(for row: RowValue) -> RowContent {
        TupleView9(
            column0.content(row),
            column1.content(row),
            column2.content(row),
            column3.content(row),
            column4.content(row),
            column5.content(row),
            column6.content(row),
            column7.content(row),
            column8.content(row)
        )
    }
}

public struct TupleTableRowContent10<
    RowValue,
    Content0: View,
    Content1: View,
    Content2: View,
    Content3: View,
    Content4: View,
    Content5: View,
    Content6: View,
    Content7: View,
    Content8: View,
    Content9: View
>: TableRowContent {
    public typealias RowContent = TupleView10<
        Content0,
        Content1,
        Content2,
        Content3,
        Content4,
        Content5,
        Content6,
        Content7,
        Content8,
        Content9
    >

    public var column0: TableColumn<RowValue, Content0>
    public var column1: TableColumn<RowValue, Content1>
    public var column2: TableColumn<RowValue, Content2>
    public var column3: TableColumn<RowValue, Content3>
    public var column4: TableColumn<RowValue, Content4>
    public var column5: TableColumn<RowValue, Content5>
    public var column6: TableColumn<RowValue, Content6>
    public var column7: TableColumn<RowValue, Content7>
    public var column8: TableColumn<RowValue, Content8>
    public var column9: TableColumn<RowValue, Content9>

    public var labels: [String] {
        [
            column0.label,
            column1.label,
            column2.label,
            column3.label,
            column4.label,
            column5.label,
            column6.label,
            column7.label,
            column8.label,
            column9.label,
        ]
    }

    public init(
        _ column0: TableColumn<RowValue, Content0>,
        _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<RowValue, Content2>,
        _ column3: TableColumn<RowValue, Content3>,
        _ column4: TableColumn<RowValue, Content4>,
        _ column5: TableColumn<RowValue, Content5>,
        _ column6: TableColumn<RowValue, Content6>,
        _ column7: TableColumn<RowValue, Content7>,
        _ column8: TableColumn<RowValue, Content8>,
        _ column9: TableColumn<RowValue, Content9>
    ) {
        self.column0 = column0
        self.column1 = column1
        self.column2 = column2
        self.column3 = column3
        self.column4 = column4
        self.column5 = column5
        self.column6 = column6
        self.column7 = column7
        self.column8 = column8
        self.column9 = column9
    }

    public func content(for row: RowValue) -> RowContent {
        TupleView10(
            column0.content(row),
            column1.content(row),
            column2.content(row),
            column3.content(row),
            column4.content(row),
            column5.content(row),
            column6.content(row),
            column7.content(row),
            column8.content(row),
            column9.content(row)
        )
    }
}

public struct TupleTableRowContent11<
    RowValue,
    Content0: View,
    Content1: View,
    Content2: View,
    Content3: View,
    Content4: View,
    Content5: View,
    Content6: View,
    Content7: View,
    Content8: View,
    Content9: View,
    Content10: View
>: TableRowContent {
    public typealias RowContent = TupleView11<
        Content0,
        Content1,
        Content2,
        Content3,
        Content4,
        Content5,
        Content6,
        Content7,
        Content8,
        Content9,
        Content10
    >

    public var column0: TableColumn<RowValue, Content0>
    public var column1: TableColumn<RowValue, Content1>
    public var column2: TableColumn<RowValue, Content2>
    public var column3: TableColumn<RowValue, Content3>
    public var column4: TableColumn<RowValue, Content4>
    public var column5: TableColumn<RowValue, Content5>
    public var column6: TableColumn<RowValue, Content6>
    public var column7: TableColumn<RowValue, Content7>
    public var column8: TableColumn<RowValue, Content8>
    public var column9: TableColumn<RowValue, Content9>
    public var column10: TableColumn<RowValue, Content10>

    public var labels: [String] {
        [
            column0.label,
            column1.label,
            column2.label,
            column3.label,
            column4.label,
            column5.label,
            column6.label,
            column7.label,
            column8.label,
            column9.label,
            column10.label,
        ]
    }

    public init(
        _ column0: TableColumn<RowValue, Content0>,
        _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<RowValue, Content2>,
        _ column3: TableColumn<RowValue, Content3>,
        _ column4: TableColumn<RowValue, Content4>,
        _ column5: TableColumn<RowValue, Content5>,
        _ column6: TableColumn<RowValue, Content6>,
        _ column7: TableColumn<RowValue, Content7>,
        _ column8: TableColumn<RowValue, Content8>,
        _ column9: TableColumn<RowValue, Content9>,
        _ column10: TableColumn<RowValue, Content10>
    ) {
        self.column0 = column0
        self.column1 = column1
        self.column2 = column2
        self.column3 = column3
        self.column4 = column4
        self.column5 = column5
        self.column6 = column6
        self.column7 = column7
        self.column8 = column8
        self.column9 = column9
        self.column10 = column10
    }

    public func content(for row: RowValue) -> RowContent {
        TupleView11(
            column0.content(row),
            column1.content(row),
            column2.content(row),
            column3.content(row),
            column4.content(row),
            column5.content(row),
            column6.content(row),
            column7.content(row),
            column8.content(row),
            column9.content(row),
            column10.content(row)
        )
    }
}

public struct TupleTableRowContent12<
    RowValue,
    Content0: View,
    Content1: View,
    Content2: View,
    Content3: View,
    Content4: View,
    Content5: View,
    Content6: View,
    Content7: View,
    Content8: View,
    Content9: View,
    Content10: View,
    Content11: View
>: TableRowContent {
    public typealias RowContent = TupleView12<
        Content0,
        Content1,
        Content2,
        Content3,
        Content4,
        Content5,
        Content6,
        Content7,
        Content8,
        Content9,
        Content10,
        Content11
    >

    public var column0: TableColumn<RowValue, Content0>
    public var column1: TableColumn<RowValue, Content1>
    public var column2: TableColumn<RowValue, Content2>
    public var column3: TableColumn<RowValue, Content3>
    public var column4: TableColumn<RowValue, Content4>
    public var column5: TableColumn<RowValue, Content5>
    public var column6: TableColumn<RowValue, Content6>
    public var column7: TableColumn<RowValue, Content7>
    public var column8: TableColumn<RowValue, Content8>
    public var column9: TableColumn<RowValue, Content9>
    public var column10: TableColumn<RowValue, Content10>
    public var column11: TableColumn<RowValue, Content11>

    public var labels: [String] {
        [
            column0.label,
            column1.label,
            column2.label,
            column3.label,
            column4.label,
            column5.label,
            column6.label,
            column7.label,
            column8.label,
            column9.label,
            column10.label,
            column11.label,
        ]
    }

    public init(
        _ column0: TableColumn<RowValue, Content0>,
        _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<RowValue, Content2>,
        _ column3: TableColumn<RowValue, Content3>,
        _ column4: TableColumn<RowValue, Content4>,
        _ column5: TableColumn<RowValue, Content5>,
        _ column6: TableColumn<RowValue, Content6>,
        _ column7: TableColumn<RowValue, Content7>,
        _ column8: TableColumn<RowValue, Content8>,
        _ column9: TableColumn<RowValue, Content9>,
        _ column10: TableColumn<RowValue, Content10>,
        _ column11: TableColumn<RowValue, Content11>
    ) {
        self.column0 = column0
        self.column1 = column1
        self.column2 = column2
        self.column3 = column3
        self.column4 = column4
        self.column5 = column5
        self.column6 = column6
        self.column7 = column7
        self.column8 = column8
        self.column9 = column9
        self.column10 = column10
        self.column11 = column11
    }

    public func content(for row: RowValue) -> RowContent {
        TupleView12(
            column0.content(row),
            column1.content(row),
            column2.content(row),
            column3.content(row),
            column4.content(row),
            column5.content(row),
            column6.content(row),
            column7.content(row),
            column8.content(row),
            column9.content(row),
            column10.content(row),
            column11.content(row)
        )
    }
}

public struct TupleTableRowContent13<
    RowValue,
    Content0: View,
    Content1: View,
    Content2: View,
    Content3: View,
    Content4: View,
    Content5: View,
    Content6: View,
    Content7: View,
    Content8: View,
    Content9: View,
    Content10: View,
    Content11: View,
    Content12: View
>: TableRowContent {
    public typealias RowContent = TupleView13<
        Content0,
        Content1,
        Content2,
        Content3,
        Content4,
        Content5,
        Content6,
        Content7,
        Content8,
        Content9,
        Content10,
        Content11,
        Content12
    >

    public var column0: TableColumn<RowValue, Content0>
    public var column1: TableColumn<RowValue, Content1>
    public var column2: TableColumn<RowValue, Content2>
    public var column3: TableColumn<RowValue, Content3>
    public var column4: TableColumn<RowValue, Content4>
    public var column5: TableColumn<RowValue, Content5>
    public var column6: TableColumn<RowValue, Content6>
    public var column7: TableColumn<RowValue, Content7>
    public var column8: TableColumn<RowValue, Content8>
    public var column9: TableColumn<RowValue, Content9>
    public var column10: TableColumn<RowValue, Content10>
    public var column11: TableColumn<RowValue, Content11>
    public var column12: TableColumn<RowValue, Content12>

    public var labels: [String] {
        [
            column0.label,
            column1.label,
            column2.label,
            column3.label,
            column4.label,
            column5.label,
            column6.label,
            column7.label,
            column8.label,
            column9.label,
            column10.label,
            column11.label,
            column12.label,
        ]
    }

    public init(
        _ column0: TableColumn<RowValue, Content0>,
        _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<RowValue, Content2>,
        _ column3: TableColumn<RowValue, Content3>,
        _ column4: TableColumn<RowValue, Content4>,
        _ column5: TableColumn<RowValue, Content5>,
        _ column6: TableColumn<RowValue, Content6>,
        _ column7: TableColumn<RowValue, Content7>,
        _ column8: TableColumn<RowValue, Content8>,
        _ column9: TableColumn<RowValue, Content9>,
        _ column10: TableColumn<RowValue, Content10>,
        _ column11: TableColumn<RowValue, Content11>,
        _ column12: TableColumn<RowValue, Content12>
    ) {
        self.column0 = column0
        self.column1 = column1
        self.column2 = column2
        self.column3 = column3
        self.column4 = column4
        self.column5 = column5
        self.column6 = column6
        self.column7 = column7
        self.column8 = column8
        self.column9 = column9
        self.column10 = column10
        self.column11 = column11
        self.column12 = column12
    }

    public func content(for row: RowValue) -> RowContent {
        TupleView13(
            column0.content(row),
            column1.content(row),
            column2.content(row),
            column3.content(row),
            column4.content(row),
            column5.content(row),
            column6.content(row),
            column7.content(row),
            column8.content(row),
            column9.content(row),
            column10.content(row),
            column11.content(row),
            column12.content(row)
        )
    }
}

public struct TupleTableRowContent14<
    RowValue,
    Content0: View,
    Content1: View,
    Content2: View,
    Content3: View,
    Content4: View,
    Content5: View,
    Content6: View,
    Content7: View,
    Content8: View,
    Content9: View,
    Content10: View,
    Content11: View,
    Content12: View,
    Content13: View
>: TableRowContent {
    public typealias RowContent = TupleView14<
        Content0,
        Content1,
        Content2,
        Content3,
        Content4,
        Content5,
        Content6,
        Content7,
        Content8,
        Content9,
        Content10,
        Content11,
        Content12,
        Content13
    >

    public var column0: TableColumn<RowValue, Content0>
    public var column1: TableColumn<RowValue, Content1>
    public var column2: TableColumn<RowValue, Content2>
    public var column3: TableColumn<RowValue, Content3>
    public var column4: TableColumn<RowValue, Content4>
    public var column5: TableColumn<RowValue, Content5>
    public var column6: TableColumn<RowValue, Content6>
    public var column7: TableColumn<RowValue, Content7>
    public var column8: TableColumn<RowValue, Content8>
    public var column9: TableColumn<RowValue, Content9>
    public var column10: TableColumn<RowValue, Content10>
    public var column11: TableColumn<RowValue, Content11>
    public var column12: TableColumn<RowValue, Content12>
    public var column13: TableColumn<RowValue, Content13>

    public var labels: [String] {
        [
            column0.label,
            column1.label,
            column2.label,
            column3.label,
            column4.label,
            column5.label,
            column6.label,
            column7.label,
            column8.label,
            column9.label,
            column10.label,
            column11.label,
            column12.label,
            column13.label,
        ]
    }

    public init(
        _ column0: TableColumn<RowValue, Content0>,
        _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<RowValue, Content2>,
        _ column3: TableColumn<RowValue, Content3>,
        _ column4: TableColumn<RowValue, Content4>,
        _ column5: TableColumn<RowValue, Content5>,
        _ column6: TableColumn<RowValue, Content6>,
        _ column7: TableColumn<RowValue, Content7>,
        _ column8: TableColumn<RowValue, Content8>,
        _ column9: TableColumn<RowValue, Content9>,
        _ column10: TableColumn<RowValue, Content10>,
        _ column11: TableColumn<RowValue, Content11>,
        _ column12: TableColumn<RowValue, Content12>,
        _ column13: TableColumn<RowValue, Content13>
    ) {
        self.column0 = column0
        self.column1 = column1
        self.column2 = column2
        self.column3 = column3
        self.column4 = column4
        self.column5 = column5
        self.column6 = column6
        self.column7 = column7
        self.column8 = column8
        self.column9 = column9
        self.column10 = column10
        self.column11 = column11
        self.column12 = column12
        self.column13 = column13
    }

    public func content(for row: RowValue) -> RowContent {
        TupleView14(
            column0.content(row),
            column1.content(row),
            column2.content(row),
            column3.content(row),
            column4.content(row),
            column5.content(row),
            column6.content(row),
            column7.content(row),
            column8.content(row),
            column9.content(row),
            column10.content(row),
            column11.content(row),
            column12.content(row),
            column13.content(row)
        )
    }
}

public struct TupleTableRowContent15<
    RowValue,
    Content0: View,
    Content1: View,
    Content2: View,
    Content3: View,
    Content4: View,
    Content5: View,
    Content6: View,
    Content7: View,
    Content8: View,
    Content9: View,
    Content10: View,
    Content11: View,
    Content12: View,
    Content13: View,
    Content14: View
>: TableRowContent {
    public typealias RowContent = TupleView15<
        Content0,
        Content1,
        Content2,
        Content3,
        Content4,
        Content5,
        Content6,
        Content7,
        Content8,
        Content9,
        Content10,
        Content11,
        Content12,
        Content13,
        Content14
    >

    public var column0: TableColumn<RowValue, Content0>
    public var column1: TableColumn<RowValue, Content1>
    public var column2: TableColumn<RowValue, Content2>
    public var column3: TableColumn<RowValue, Content3>
    public var column4: TableColumn<RowValue, Content4>
    public var column5: TableColumn<RowValue, Content5>
    public var column6: TableColumn<RowValue, Content6>
    public var column7: TableColumn<RowValue, Content7>
    public var column8: TableColumn<RowValue, Content8>
    public var column9: TableColumn<RowValue, Content9>
    public var column10: TableColumn<RowValue, Content10>
    public var column11: TableColumn<RowValue, Content11>
    public var column12: TableColumn<RowValue, Content12>
    public var column13: TableColumn<RowValue, Content13>
    public var column14: TableColumn<RowValue, Content14>

    public var labels: [String] {
        [
            column0.label,
            column1.label,
            column2.label,
            column3.label,
            column4.label,
            column5.label,
            column6.label,
            column7.label,
            column8.label,
            column9.label,
            column10.label,
            column11.label,
            column12.label,
            column13.label,
            column14.label,
        ]
    }

    public init(
        _ column0: TableColumn<RowValue, Content0>,
        _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<RowValue, Content2>,
        _ column3: TableColumn<RowValue, Content3>,
        _ column4: TableColumn<RowValue, Content4>,
        _ column5: TableColumn<RowValue, Content5>,
        _ column6: TableColumn<RowValue, Content6>,
        _ column7: TableColumn<RowValue, Content7>,
        _ column8: TableColumn<RowValue, Content8>,
        _ column9: TableColumn<RowValue, Content9>,
        _ column10: TableColumn<RowValue, Content10>,
        _ column11: TableColumn<RowValue, Content11>,
        _ column12: TableColumn<RowValue, Content12>,
        _ column13: TableColumn<RowValue, Content13>,
        _ column14: TableColumn<RowValue, Content14>
    ) {
        self.column0 = column0
        self.column1 = column1
        self.column2 = column2
        self.column3 = column3
        self.column4 = column4
        self.column5 = column5
        self.column6 = column6
        self.column7 = column7
        self.column8 = column8
        self.column9 = column9
        self.column10 = column10
        self.column11 = column11
        self.column12 = column12
        self.column13 = column13
        self.column14 = column14
    }

    public func content(for row: RowValue) -> RowContent {
        TupleView15(
            column0.content(row),
            column1.content(row),
            column2.content(row),
            column3.content(row),
            column4.content(row),
            column5.content(row),
            column6.content(row),
            column7.content(row),
            column8.content(row),
            column9.content(row),
            column10.content(row),
            column11.content(row),
            column12.content(row),
            column13.content(row),
            column14.content(row)
        )
    }
}

public struct TupleTableRowContent16<
    RowValue,
    Content0: View,
    Content1: View,
    Content2: View,
    Content3: View,
    Content4: View,
    Content5: View,
    Content6: View,
    Content7: View,
    Content8: View,
    Content9: View,
    Content10: View,
    Content11: View,
    Content12: View,
    Content13: View,
    Content14: View,
    Content15: View
>: TableRowContent {
    public typealias RowContent = TupleView16<
        Content0,
        Content1,
        Content2,
        Content3,
        Content4,
        Content5,
        Content6,
        Content7,
        Content8,
        Content9,
        Content10,
        Content11,
        Content12,
        Content13,
        Content14,
        Content15
    >

    public var column0: TableColumn<RowValue, Content0>
    public var column1: TableColumn<RowValue, Content1>
    public var column2: TableColumn<RowValue, Content2>
    public var column3: TableColumn<RowValue, Content3>
    public var column4: TableColumn<RowValue, Content4>
    public var column5: TableColumn<RowValue, Content5>
    public var column6: TableColumn<RowValue, Content6>
    public var column7: TableColumn<RowValue, Content7>
    public var column8: TableColumn<RowValue, Content8>
    public var column9: TableColumn<RowValue, Content9>
    public var column10: TableColumn<RowValue, Content10>
    public var column11: TableColumn<RowValue, Content11>
    public var column12: TableColumn<RowValue, Content12>
    public var column13: TableColumn<RowValue, Content13>
    public var column14: TableColumn<RowValue, Content14>
    public var column15: TableColumn<RowValue, Content15>

    public var labels: [String] {
        [
            column0.label,
            column1.label,
            column2.label,
            column3.label,
            column4.label,
            column5.label,
            column6.label,
            column7.label,
            column8.label,
            column9.label,
            column10.label,
            column11.label,
            column12.label,
            column13.label,
            column14.label,
            column15.label,
        ]
    }

    public init(
        _ column0: TableColumn<RowValue, Content0>,
        _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<RowValue, Content2>,
        _ column3: TableColumn<RowValue, Content3>,
        _ column4: TableColumn<RowValue, Content4>,
        _ column5: TableColumn<RowValue, Content5>,
        _ column6: TableColumn<RowValue, Content6>,
        _ column7: TableColumn<RowValue, Content7>,
        _ column8: TableColumn<RowValue, Content8>,
        _ column9: TableColumn<RowValue, Content9>,
        _ column10: TableColumn<RowValue, Content10>,
        _ column11: TableColumn<RowValue, Content11>,
        _ column12: TableColumn<RowValue, Content12>,
        _ column13: TableColumn<RowValue, Content13>,
        _ column14: TableColumn<RowValue, Content14>,
        _ column15: TableColumn<RowValue, Content15>
    ) {
        self.column0 = column0
        self.column1 = column1
        self.column2 = column2
        self.column3 = column3
        self.column4 = column4
        self.column5 = column5
        self.column6 = column6
        self.column7 = column7
        self.column8 = column8
        self.column9 = column9
        self.column10 = column10
        self.column11 = column11
        self.column12 = column12
        self.column13 = column13
        self.column14 = column14
        self.column15 = column15
    }

    public func content(for row: RowValue) -> RowContent {
        TupleView16(
            column0.content(row),
            column1.content(row),
            column2.content(row),
            column3.content(row),
            column4.content(row),
            column5.content(row),
            column6.content(row),
            column7.content(row),
            column8.content(row),
            column9.content(row),
            column10.content(row),
            column11.content(row),
            column12.content(row),
            column13.content(row),
            column14.content(row),
            column15.content(row)
        )
    }
}

public struct TupleTableRowContent17<
    RowValue,
    Content0: View,
    Content1: View,
    Content2: View,
    Content3: View,
    Content4: View,
    Content5: View,
    Content6: View,
    Content7: View,
    Content8: View,
    Content9: View,
    Content10: View,
    Content11: View,
    Content12: View,
    Content13: View,
    Content14: View,
    Content15: View,
    Content16: View
>: TableRowContent {
    public typealias RowContent = TupleView17<
        Content0,
        Content1,
        Content2,
        Content3,
        Content4,
        Content5,
        Content6,
        Content7,
        Content8,
        Content9,
        Content10,
        Content11,
        Content12,
        Content13,
        Content14,
        Content15,
        Content16
    >

    public var column0: TableColumn<RowValue, Content0>
    public var column1: TableColumn<RowValue, Content1>
    public var column2: TableColumn<RowValue, Content2>
    public var column3: TableColumn<RowValue, Content3>
    public var column4: TableColumn<RowValue, Content4>
    public var column5: TableColumn<RowValue, Content5>
    public var column6: TableColumn<RowValue, Content6>
    public var column7: TableColumn<RowValue, Content7>
    public var column8: TableColumn<RowValue, Content8>
    public var column9: TableColumn<RowValue, Content9>
    public var column10: TableColumn<RowValue, Content10>
    public var column11: TableColumn<RowValue, Content11>
    public var column12: TableColumn<RowValue, Content12>
    public var column13: TableColumn<RowValue, Content13>
    public var column14: TableColumn<RowValue, Content14>
    public var column15: TableColumn<RowValue, Content15>
    public var column16: TableColumn<RowValue, Content16>

    public var labels: [String] {
        [
            column0.label,
            column1.label,
            column2.label,
            column3.label,
            column4.label,
            column5.label,
            column6.label,
            column7.label,
            column8.label,
            column9.label,
            column10.label,
            column11.label,
            column12.label,
            column13.label,
            column14.label,
            column15.label,
            column16.label,
        ]
    }

    public init(
        _ column0: TableColumn<RowValue, Content0>,
        _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<RowValue, Content2>,
        _ column3: TableColumn<RowValue, Content3>,
        _ column4: TableColumn<RowValue, Content4>,
        _ column5: TableColumn<RowValue, Content5>,
        _ column6: TableColumn<RowValue, Content6>,
        _ column7: TableColumn<RowValue, Content7>,
        _ column8: TableColumn<RowValue, Content8>,
        _ column9: TableColumn<RowValue, Content9>,
        _ column10: TableColumn<RowValue, Content10>,
        _ column11: TableColumn<RowValue, Content11>,
        _ column12: TableColumn<RowValue, Content12>,
        _ column13: TableColumn<RowValue, Content13>,
        _ column14: TableColumn<RowValue, Content14>,
        _ column15: TableColumn<RowValue, Content15>,
        _ column16: TableColumn<RowValue, Content16>
    ) {
        self.column0 = column0
        self.column1 = column1
        self.column2 = column2
        self.column3 = column3
        self.column4 = column4
        self.column5 = column5
        self.column6 = column6
        self.column7 = column7
        self.column8 = column8
        self.column9 = column9
        self.column10 = column10
        self.column11 = column11
        self.column12 = column12
        self.column13 = column13
        self.column14 = column14
        self.column15 = column15
        self.column16 = column16
    }

    public func content(for row: RowValue) -> RowContent {
        TupleView17(
            column0.content(row),
            column1.content(row),
            column2.content(row),
            column3.content(row),
            column4.content(row),
            column5.content(row),
            column6.content(row),
            column7.content(row),
            column8.content(row),
            column9.content(row),
            column10.content(row),
            column11.content(row),
            column12.content(row),
            column13.content(row),
            column14.content(row),
            column15.content(row),
            column16.content(row)
        )
    }
}

public struct TupleTableRowContent18<
    RowValue,
    Content0: View,
    Content1: View,
    Content2: View,
    Content3: View,
    Content4: View,
    Content5: View,
    Content6: View,
    Content7: View,
    Content8: View,
    Content9: View,
    Content10: View,
    Content11: View,
    Content12: View,
    Content13: View,
    Content14: View,
    Content15: View,
    Content16: View,
    Content17: View
>: TableRowContent {
    public typealias RowContent = TupleView18<
        Content0,
        Content1,
        Content2,
        Content3,
        Content4,
        Content5,
        Content6,
        Content7,
        Content8,
        Content9,
        Content10,
        Content11,
        Content12,
        Content13,
        Content14,
        Content15,
        Content16,
        Content17
    >

    public var column0: TableColumn<RowValue, Content0>
    public var column1: TableColumn<RowValue, Content1>
    public var column2: TableColumn<RowValue, Content2>
    public var column3: TableColumn<RowValue, Content3>
    public var column4: TableColumn<RowValue, Content4>
    public var column5: TableColumn<RowValue, Content5>
    public var column6: TableColumn<RowValue, Content6>
    public var column7: TableColumn<RowValue, Content7>
    public var column8: TableColumn<RowValue, Content8>
    public var column9: TableColumn<RowValue, Content9>
    public var column10: TableColumn<RowValue, Content10>
    public var column11: TableColumn<RowValue, Content11>
    public var column12: TableColumn<RowValue, Content12>
    public var column13: TableColumn<RowValue, Content13>
    public var column14: TableColumn<RowValue, Content14>
    public var column15: TableColumn<RowValue, Content15>
    public var column16: TableColumn<RowValue, Content16>
    public var column17: TableColumn<RowValue, Content17>

    public var labels: [String] {
        [
            column0.label,
            column1.label,
            column2.label,
            column3.label,
            column4.label,
            column5.label,
            column6.label,
            column7.label,
            column8.label,
            column9.label,
            column10.label,
            column11.label,
            column12.label,
            column13.label,
            column14.label,
            column15.label,
            column16.label,
            column17.label,
        ]
    }

    public init(
        _ column0: TableColumn<RowValue, Content0>,
        _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<RowValue, Content2>,
        _ column3: TableColumn<RowValue, Content3>,
        _ column4: TableColumn<RowValue, Content4>,
        _ column5: TableColumn<RowValue, Content5>,
        _ column6: TableColumn<RowValue, Content6>,
        _ column7: TableColumn<RowValue, Content7>,
        _ column8: TableColumn<RowValue, Content8>,
        _ column9: TableColumn<RowValue, Content9>,
        _ column10: TableColumn<RowValue, Content10>,
        _ column11: TableColumn<RowValue, Content11>,
        _ column12: TableColumn<RowValue, Content12>,
        _ column13: TableColumn<RowValue, Content13>,
        _ column14: TableColumn<RowValue, Content14>,
        _ column15: TableColumn<RowValue, Content15>,
        _ column16: TableColumn<RowValue, Content16>,
        _ column17: TableColumn<RowValue, Content17>
    ) {
        self.column0 = column0
        self.column1 = column1
        self.column2 = column2
        self.column3 = column3
        self.column4 = column4
        self.column5 = column5
        self.column6 = column6
        self.column7 = column7
        self.column8 = column8
        self.column9 = column9
        self.column10 = column10
        self.column11 = column11
        self.column12 = column12
        self.column13 = column13
        self.column14 = column14
        self.column15 = column15
        self.column16 = column16
        self.column17 = column17
    }

    public func content(for row: RowValue) -> RowContent {
        TupleView18(
            column0.content(row),
            column1.content(row),
            column2.content(row),
            column3.content(row),
            column4.content(row),
            column5.content(row),
            column6.content(row),
            column7.content(row),
            column8.content(row),
            column9.content(row),
            column10.content(row),
            column11.content(row),
            column12.content(row),
            column13.content(row),
            column14.content(row),
            column15.content(row),
            column16.content(row),
            column17.content(row)
        )
    }
}

public struct TupleTableRowContent19<
    RowValue,
    Content0: View,
    Content1: View,
    Content2: View,
    Content3: View,
    Content4: View,
    Content5: View,
    Content6: View,
    Content7: View,
    Content8: View,
    Content9: View,
    Content10: View,
    Content11: View,
    Content12: View,
    Content13: View,
    Content14: View,
    Content15: View,
    Content16: View,
    Content17: View,
    Content18: View
>: TableRowContent {
    public typealias RowContent = TupleView19<
        Content0,
        Content1,
        Content2,
        Content3,
        Content4,
        Content5,
        Content6,
        Content7,
        Content8,
        Content9,
        Content10,
        Content11,
        Content12,
        Content13,
        Content14,
        Content15,
        Content16,
        Content17,
        Content18
    >

    public var column0: TableColumn<RowValue, Content0>
    public var column1: TableColumn<RowValue, Content1>
    public var column2: TableColumn<RowValue, Content2>
    public var column3: TableColumn<RowValue, Content3>
    public var column4: TableColumn<RowValue, Content4>
    public var column5: TableColumn<RowValue, Content5>
    public var column6: TableColumn<RowValue, Content6>
    public var column7: TableColumn<RowValue, Content7>
    public var column8: TableColumn<RowValue, Content8>
    public var column9: TableColumn<RowValue, Content9>
    public var column10: TableColumn<RowValue, Content10>
    public var column11: TableColumn<RowValue, Content11>
    public var column12: TableColumn<RowValue, Content12>
    public var column13: TableColumn<RowValue, Content13>
    public var column14: TableColumn<RowValue, Content14>
    public var column15: TableColumn<RowValue, Content15>
    public var column16: TableColumn<RowValue, Content16>
    public var column17: TableColumn<RowValue, Content17>
    public var column18: TableColumn<RowValue, Content18>

    public var labels: [String] {
        [
            column0.label,
            column1.label,
            column2.label,
            column3.label,
            column4.label,
            column5.label,
            column6.label,
            column7.label,
            column8.label,
            column9.label,
            column10.label,
            column11.label,
            column12.label,
            column13.label,
            column14.label,
            column15.label,
            column16.label,
            column17.label,
            column18.label,
        ]
    }

    public init(
        _ column0: TableColumn<RowValue, Content0>,
        _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<RowValue, Content2>,
        _ column3: TableColumn<RowValue, Content3>,
        _ column4: TableColumn<RowValue, Content4>,
        _ column5: TableColumn<RowValue, Content5>,
        _ column6: TableColumn<RowValue, Content6>,
        _ column7: TableColumn<RowValue, Content7>,
        _ column8: TableColumn<RowValue, Content8>,
        _ column9: TableColumn<RowValue, Content9>,
        _ column10: TableColumn<RowValue, Content10>,
        _ column11: TableColumn<RowValue, Content11>,
        _ column12: TableColumn<RowValue, Content12>,
        _ column13: TableColumn<RowValue, Content13>,
        _ column14: TableColumn<RowValue, Content14>,
        _ column15: TableColumn<RowValue, Content15>,
        _ column16: TableColumn<RowValue, Content16>,
        _ column17: TableColumn<RowValue, Content17>,
        _ column18: TableColumn<RowValue, Content18>
    ) {
        self.column0 = column0
        self.column1 = column1
        self.column2 = column2
        self.column3 = column3
        self.column4 = column4
        self.column5 = column5
        self.column6 = column6
        self.column7 = column7
        self.column8 = column8
        self.column9 = column9
        self.column10 = column10
        self.column11 = column11
        self.column12 = column12
        self.column13 = column13
        self.column14 = column14
        self.column15 = column15
        self.column16 = column16
        self.column17 = column17
        self.column18 = column18
    }

    public func content(for row: RowValue) -> RowContent {
        TupleView19(
            column0.content(row),
            column1.content(row),
            column2.content(row),
            column3.content(row),
            column4.content(row),
            column5.content(row),
            column6.content(row),
            column7.content(row),
            column8.content(row),
            column9.content(row),
            column10.content(row),
            column11.content(row),
            column12.content(row),
            column13.content(row),
            column14.content(row),
            column15.content(row),
            column16.content(row),
            column17.content(row),
            column18.content(row)
        )
    }
}

public struct TupleTableRowContent20<
    RowValue,
    Content0: View,
    Content1: View,
    Content2: View,
    Content3: View,
    Content4: View,
    Content5: View,
    Content6: View,
    Content7: View,
    Content8: View,
    Content9: View,
    Content10: View,
    Content11: View,
    Content12: View,
    Content13: View,
    Content14: View,
    Content15: View,
    Content16: View,
    Content17: View,
    Content18: View,
    Content19: View
>: TableRowContent {
    public typealias RowContent = TupleView20<
        Content0,
        Content1,
        Content2,
        Content3,
        Content4,
        Content5,
        Content6,
        Content7,
        Content8,
        Content9,
        Content10,
        Content11,
        Content12,
        Content13,
        Content14,
        Content15,
        Content16,
        Content17,
        Content18,
        Content19
    >

    public var column0: TableColumn<RowValue, Content0>
    public var column1: TableColumn<RowValue, Content1>
    public var column2: TableColumn<RowValue, Content2>
    public var column3: TableColumn<RowValue, Content3>
    public var column4: TableColumn<RowValue, Content4>
    public var column5: TableColumn<RowValue, Content5>
    public var column6: TableColumn<RowValue, Content6>
    public var column7: TableColumn<RowValue, Content7>
    public var column8: TableColumn<RowValue, Content8>
    public var column9: TableColumn<RowValue, Content9>
    public var column10: TableColumn<RowValue, Content10>
    public var column11: TableColumn<RowValue, Content11>
    public var column12: TableColumn<RowValue, Content12>
    public var column13: TableColumn<RowValue, Content13>
    public var column14: TableColumn<RowValue, Content14>
    public var column15: TableColumn<RowValue, Content15>
    public var column16: TableColumn<RowValue, Content16>
    public var column17: TableColumn<RowValue, Content17>
    public var column18: TableColumn<RowValue, Content18>
    public var column19: TableColumn<RowValue, Content19>

    public var labels: [String] {
        [
            column0.label,
            column1.label,
            column2.label,
            column3.label,
            column4.label,
            column5.label,
            column6.label,
            column7.label,
            column8.label,
            column9.label,
            column10.label,
            column11.label,
            column12.label,
            column13.label,
            column14.label,
            column15.label,
            column16.label,
            column17.label,
            column18.label,
            column19.label,
        ]
    }

    public init(
        _ column0: TableColumn<RowValue, Content0>,
        _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<RowValue, Content2>,
        _ column3: TableColumn<RowValue, Content3>,
        _ column4: TableColumn<RowValue, Content4>,
        _ column5: TableColumn<RowValue, Content5>,
        _ column6: TableColumn<RowValue, Content6>,
        _ column7: TableColumn<RowValue, Content7>,
        _ column8: TableColumn<RowValue, Content8>,
        _ column9: TableColumn<RowValue, Content9>,
        _ column10: TableColumn<RowValue, Content10>,
        _ column11: TableColumn<RowValue, Content11>,
        _ column12: TableColumn<RowValue, Content12>,
        _ column13: TableColumn<RowValue, Content13>,
        _ column14: TableColumn<RowValue, Content14>,
        _ column15: TableColumn<RowValue, Content15>,
        _ column16: TableColumn<RowValue, Content16>,
        _ column17: TableColumn<RowValue, Content17>,
        _ column18: TableColumn<RowValue, Content18>,
        _ column19: TableColumn<RowValue, Content19>
    ) {
        self.column0 = column0
        self.column1 = column1
        self.column2 = column2
        self.column3 = column3
        self.column4 = column4
        self.column5 = column5
        self.column6 = column6
        self.column7 = column7
        self.column8 = column8
        self.column9 = column9
        self.column10 = column10
        self.column11 = column11
        self.column12 = column12
        self.column13 = column13
        self.column14 = column14
        self.column15 = column15
        self.column16 = column16
        self.column17 = column17
        self.column18 = column18
        self.column19 = column19
    }

    public func content(for row: RowValue) -> RowContent {
        TupleView20(
            column0.content(row),
            column1.content(row),
            column2.content(row),
            column3.content(row),
            column4.content(row),
            column5.content(row),
            column6.content(row),
            column7.content(row),
            column8.content(row),
            column9.content(row),
            column10.content(row),
            column11.content(row),
            column12.content(row),
            column13.content(row),
            column14.content(row),
            column15.content(row),
            column16.content(row),
            column17.content(row),
            column18.content(row),
            column19.content(row)
        )
    }
}
