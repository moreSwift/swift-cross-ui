// This file was generated using gyb. Do not edit it directly. Edit
// TableRowBuilder.swift.gyb instead.

// swiftformat:options --allow-partial-wrapping true

/// A result builder for constructing a collection of table columns.
@resultBuilder
public struct TableRowBuilder<RowValue> {
    public static func buildBlock() -> EmptyTableRowContent<RowValue> {
        EmptyTableRowContent<RowValue>()
    }

    public static func buildBlock<
        Content0: View
    >(
        _ column0: TableColumn<RowValue, Content0>
    ) -> TupleTableRowContent1<
        RowValue, Content0
    > {
        TupleTableRowContent1(
            column0
        )
    }
    public static func buildBlock<
        Content0: View, Content1: View
    >(
        _ column0: TableColumn<RowValue, Content0>, _ column1: TableColumn<RowValue, Content1>
    ) -> TupleTableRowContent2<
        RowValue, Content0, Content1
    > {
        TupleTableRowContent2(
            column0, column1
        )
    }
    public static func buildBlock<
        Content0: View, Content1: View, Content2: View
    >(
        _ column0: TableColumn<RowValue, Content0>, _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<
            RowValue,
            Content2
        >
    ) -> TupleTableRowContent3<
        RowValue, Content0, Content1, Content2
    > {
        TupleTableRowContent3(
            column0, column1, column2
        )
    }
    public static func buildBlock<
        Content0: View, Content1: View, Content2: View, Content3: View
    >(
        _ column0: TableColumn<RowValue, Content0>, _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<
            RowValue,
            Content2
        >, _ column3: TableColumn<RowValue, Content3>
    ) -> TupleTableRowContent4<
        RowValue, Content0, Content1, Content2, Content3
    > {
        TupleTableRowContent4(
            column0, column1, column2, column3
        )
    }
    public static func buildBlock<
        Content0: View, Content1: View, Content2: View, Content3: View, Content4: View
    >(
        _ column0: TableColumn<RowValue, Content0>, _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<
            RowValue,
            Content2
        >, _ column3: TableColumn<RowValue, Content3>, _ column4: TableColumn<RowValue, Content4>
    ) -> TupleTableRowContent5<
        RowValue, Content0, Content1, Content2, Content3, Content4
    > {
        TupleTableRowContent5(
            column0, column1, column2, column3, column4
        )
    }
    public static func buildBlock<
        Content0: View, Content1: View, Content2: View, Content3: View, Content4: View,
        Content5: View
    >(
        _ column0: TableColumn<RowValue, Content0>, _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<
            RowValue,
            Content2
        >, _ column3: TableColumn<RowValue, Content3>, _ column4: TableColumn<RowValue, Content4>,
        _ column5: TableColumn<
            RowValue,
            Content5
        >
    ) -> TupleTableRowContent6<
        RowValue, Content0, Content1, Content2, Content3, Content4, Content5
    > {
        TupleTableRowContent6(
            column0, column1, column2, column3, column4, column5
        )
    }
    public static func buildBlock<
        Content0: View, Content1: View, Content2: View, Content3: View, Content4: View,
        Content5: View, Content6: View
    >(
        _ column0: TableColumn<RowValue, Content0>, _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<
            RowValue,
            Content2
        >, _ column3: TableColumn<RowValue, Content3>, _ column4: TableColumn<RowValue, Content4>,
        _ column5: TableColumn<
            RowValue,
            Content5
        >, _ column6: TableColumn<RowValue, Content6>
    ) -> TupleTableRowContent7<
        RowValue, Content0, Content1, Content2, Content3, Content4, Content5, Content6
    > {
        TupleTableRowContent7(
            column0, column1, column2, column3, column4, column5, column6
        )
    }
    public static func buildBlock<
        Content0: View, Content1: View, Content2: View, Content3: View, Content4: View,
        Content5: View, Content6: View, Content7: View
    >(
        _ column0: TableColumn<RowValue, Content0>, _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<
            RowValue,
            Content2
        >, _ column3: TableColumn<RowValue, Content3>, _ column4: TableColumn<RowValue, Content4>,
        _ column5: TableColumn<
            RowValue,
            Content5
        >, _ column6: TableColumn<RowValue, Content6>, _ column7: TableColumn<RowValue, Content7>
    ) -> TupleTableRowContent8<
        RowValue, Content0, Content1, Content2, Content3, Content4, Content5, Content6, Content7
    > {
        TupleTableRowContent8(
            column0, column1, column2, column3, column4, column5, column6, column7
        )
    }
    public static func buildBlock<
        Content0: View, Content1: View, Content2: View, Content3: View, Content4: View,
        Content5: View, Content6: View, Content7: View, Content8: View
    >(
        _ column0: TableColumn<RowValue, Content0>, _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<
            RowValue,
            Content2
        >, _ column3: TableColumn<RowValue, Content3>, _ column4: TableColumn<RowValue, Content4>,
        _ column5: TableColumn<
            RowValue,
            Content5
        >, _ column6: TableColumn<RowValue, Content6>, _ column7: TableColumn<RowValue, Content7>,
        _ column8: TableColumn<
            RowValue,
            Content8
        >
    ) -> TupleTableRowContent9<
        RowValue, Content0, Content1, Content2, Content3, Content4, Content5, Content6, Content7,
        Content8
    > {
        TupleTableRowContent9(
            column0, column1, column2, column3, column4, column5, column6, column7, column8
        )
    }
    public static func buildBlock<
        Content0: View, Content1: View, Content2: View, Content3: View, Content4: View,
        Content5: View, Content6: View, Content7: View, Content8: View, Content9: View
    >(
        _ column0: TableColumn<RowValue, Content0>, _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<
            RowValue,
            Content2
        >, _ column3: TableColumn<RowValue, Content3>, _ column4: TableColumn<RowValue, Content4>,
        _ column5: TableColumn<
            RowValue,
            Content5
        >, _ column6: TableColumn<RowValue, Content6>, _ column7: TableColumn<RowValue, Content7>,
        _ column8: TableColumn<
            RowValue,
            Content8
        >, _ column9: TableColumn<RowValue, Content9>
    ) -> TupleTableRowContent10<
        RowValue, Content0, Content1, Content2, Content3, Content4, Content5, Content6, Content7,
        Content8, Content9
    > {
        TupleTableRowContent10(
            column0, column1, column2, column3, column4, column5, column6, column7, column8, column9
        )
    }
    public static func buildBlock<
        Content0: View, Content1: View, Content2: View, Content3: View, Content4: View,
        Content5: View, Content6: View, Content7: View, Content8: View, Content9: View,
        Content10: View
    >(
        _ column0: TableColumn<RowValue, Content0>, _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<
            RowValue,
            Content2
        >, _ column3: TableColumn<RowValue, Content3>, _ column4: TableColumn<RowValue, Content4>,
        _ column5: TableColumn<
            RowValue,
            Content5
        >, _ column6: TableColumn<RowValue, Content6>, _ column7: TableColumn<RowValue, Content7>,
        _ column8: TableColumn<
            RowValue,
            Content8
        >, _ column9: TableColumn<RowValue, Content9>, _ column10: TableColumn<RowValue, Content10>
    ) -> TupleTableRowContent11<
        RowValue, Content0, Content1, Content2, Content3, Content4, Content5, Content6, Content7,
        Content8, Content9, Content10
    > {
        TupleTableRowContent11(
            column0, column1, column2, column3, column4, column5, column6, column7, column8,
            column9,
            column10
        )
    }
    public static func buildBlock<
        Content0: View, Content1: View, Content2: View, Content3: View, Content4: View,
        Content5: View, Content6: View, Content7: View, Content8: View, Content9: View,
        Content10: View, Content11: View
    >(
        _ column0: TableColumn<RowValue, Content0>, _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<
            RowValue,
            Content2
        >, _ column3: TableColumn<RowValue, Content3>, _ column4: TableColumn<RowValue, Content4>,
        _ column5: TableColumn<
            RowValue,
            Content5
        >, _ column6: TableColumn<RowValue, Content6>, _ column7: TableColumn<RowValue, Content7>,
        _ column8: TableColumn<
            RowValue,
            Content8
        >, _ column9: TableColumn<RowValue, Content9>, _ column10: TableColumn<RowValue, Content10>,
        _ column11: TableColumn<
            RowValue,
            Content11
        >
    ) -> TupleTableRowContent12<
        RowValue, Content0, Content1, Content2, Content3, Content4, Content5, Content6, Content7,
        Content8, Content9, Content10, Content11
    > {
        TupleTableRowContent12(
            column0, column1, column2, column3, column4, column5, column6, column7, column8,
            column9,
            column10, column11
        )
    }
    public static func buildBlock<
        Content0: View, Content1: View, Content2: View, Content3: View, Content4: View,
        Content5: View, Content6: View, Content7: View, Content8: View, Content9: View,
        Content10: View, Content11: View, Content12: View
    >(
        _ column0: TableColumn<RowValue, Content0>, _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<
            RowValue,
            Content2
        >, _ column3: TableColumn<RowValue, Content3>, _ column4: TableColumn<RowValue, Content4>,
        _ column5: TableColumn<
            RowValue,
            Content5
        >, _ column6: TableColumn<RowValue, Content6>, _ column7: TableColumn<RowValue, Content7>,
        _ column8: TableColumn<
            RowValue,
            Content8
        >, _ column9: TableColumn<RowValue, Content9>, _ column10: TableColumn<RowValue, Content10>,
        _ column11: TableColumn<
            RowValue,
            Content11
        >, _ column12: TableColumn<RowValue, Content12>
    ) -> TupleTableRowContent13<
        RowValue, Content0, Content1, Content2, Content3, Content4, Content5, Content6, Content7,
        Content8, Content9, Content10, Content11, Content12
    > {
        TupleTableRowContent13(
            column0, column1, column2, column3, column4, column5, column6, column7, column8,
            column9,
            column10, column11, column12
        )
    }
    public static func buildBlock<
        Content0: View, Content1: View, Content2: View, Content3: View, Content4: View,
        Content5: View, Content6: View, Content7: View, Content8: View, Content9: View,
        Content10: View, Content11: View, Content12: View, Content13: View
    >(
        _ column0: TableColumn<RowValue, Content0>, _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<
            RowValue,
            Content2
        >, _ column3: TableColumn<RowValue, Content3>, _ column4: TableColumn<RowValue, Content4>,
        _ column5: TableColumn<
            RowValue,
            Content5
        >, _ column6: TableColumn<RowValue, Content6>, _ column7: TableColumn<RowValue, Content7>,
        _ column8: TableColumn<
            RowValue,
            Content8
        >, _ column9: TableColumn<RowValue, Content9>, _ column10: TableColumn<RowValue, Content10>,
        _ column11: TableColumn<
            RowValue,
            Content11
        >, _ column12: TableColumn<RowValue, Content12>, _ column13: TableColumn<
            RowValue,
            Content13
        >
    ) -> TupleTableRowContent14<
        RowValue, Content0, Content1, Content2, Content3, Content4, Content5, Content6, Content7,
        Content8, Content9, Content10, Content11, Content12, Content13
    > {
        TupleTableRowContent14(
            column0, column1, column2, column3, column4, column5, column6, column7, column8,
            column9,
            column10, column11, column12, column13
        )
    }
    public static func buildBlock<
        Content0: View, Content1: View, Content2: View, Content3: View, Content4: View,
        Content5: View, Content6: View, Content7: View, Content8: View, Content9: View,
        Content10: View, Content11: View, Content12: View, Content13: View, Content14: View
    >(
        _ column0: TableColumn<RowValue, Content0>, _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<
            RowValue,
            Content2
        >, _ column3: TableColumn<RowValue, Content3>, _ column4: TableColumn<RowValue, Content4>,
        _ column5: TableColumn<
            RowValue,
            Content5
        >, _ column6: TableColumn<RowValue, Content6>, _ column7: TableColumn<RowValue, Content7>,
        _ column8: TableColumn<
            RowValue,
            Content8
        >, _ column9: TableColumn<RowValue, Content9>, _ column10: TableColumn<RowValue, Content10>,
        _ column11: TableColumn<
            RowValue,
            Content11
        >, _ column12: TableColumn<RowValue, Content12>, _ column13: TableColumn<
            RowValue,
            Content13
        >, _ column14: TableColumn<RowValue, Content14>
    ) -> TupleTableRowContent15<
        RowValue, Content0, Content1, Content2, Content3, Content4, Content5, Content6, Content7,
        Content8, Content9, Content10, Content11, Content12, Content13, Content14
    > {
        TupleTableRowContent15(
            column0, column1, column2, column3, column4, column5, column6, column7, column8,
            column9,
            column10, column11, column12, column13, column14
        )
    }
    public static func buildBlock<
        Content0: View, Content1: View, Content2: View, Content3: View, Content4: View,
        Content5: View, Content6: View, Content7: View, Content8: View, Content9: View,
        Content10: View, Content11: View, Content12: View, Content13: View, Content14: View,
        Content15: View
    >(
        _ column0: TableColumn<RowValue, Content0>, _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<
            RowValue,
            Content2
        >, _ column3: TableColumn<RowValue, Content3>, _ column4: TableColumn<RowValue, Content4>,
        _ column5: TableColumn<
            RowValue,
            Content5
        >, _ column6: TableColumn<RowValue, Content6>, _ column7: TableColumn<RowValue, Content7>,
        _ column8: TableColumn<
            RowValue,
            Content8
        >, _ column9: TableColumn<RowValue, Content9>, _ column10: TableColumn<RowValue, Content10>,
        _ column11: TableColumn<
            RowValue,
            Content11
        >, _ column12: TableColumn<RowValue, Content12>, _ column13: TableColumn<
            RowValue,
            Content13
        >, _ column14: TableColumn<RowValue, Content14>, _ column15: TableColumn<
            RowValue,
            Content15
        >
    ) -> TupleTableRowContent16<
        RowValue, Content0, Content1, Content2, Content3, Content4, Content5, Content6, Content7,
        Content8, Content9, Content10, Content11, Content12, Content13, Content14, Content15
    > {
        TupleTableRowContent16(
            column0, column1, column2, column3, column4, column5, column6, column7, column8,
            column9,
            column10, column11, column12, column13, column14, column15
        )
    }
    public static func buildBlock<
        Content0: View, Content1: View, Content2: View, Content3: View, Content4: View,
        Content5: View, Content6: View, Content7: View, Content8: View, Content9: View,
        Content10: View, Content11: View, Content12: View, Content13: View, Content14: View,
        Content15: View, Content16: View
    >(
        _ column0: TableColumn<RowValue, Content0>, _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<
            RowValue,
            Content2
        >, _ column3: TableColumn<RowValue, Content3>, _ column4: TableColumn<RowValue, Content4>,
        _ column5: TableColumn<
            RowValue,
            Content5
        >, _ column6: TableColumn<RowValue, Content6>, _ column7: TableColumn<RowValue, Content7>,
        _ column8: TableColumn<
            RowValue,
            Content8
        >, _ column9: TableColumn<RowValue, Content9>, _ column10: TableColumn<RowValue, Content10>,
        _ column11: TableColumn<
            RowValue,
            Content11
        >, _ column12: TableColumn<RowValue, Content12>, _ column13: TableColumn<
            RowValue,
            Content13
        >, _ column14: TableColumn<RowValue, Content14>, _ column15: TableColumn<
            RowValue,
            Content15
        >, _ column16: TableColumn<RowValue, Content16>
    ) -> TupleTableRowContent17<
        RowValue, Content0, Content1, Content2, Content3, Content4, Content5, Content6, Content7,
        Content8, Content9, Content10, Content11, Content12, Content13, Content14, Content15,
        Content16
    > {
        TupleTableRowContent17(
            column0, column1, column2, column3, column4, column5, column6, column7, column8,
            column9,
            column10, column11, column12, column13, column14, column15, column16
        )
    }
    public static func buildBlock<
        Content0: View, Content1: View, Content2: View, Content3: View, Content4: View,
        Content5: View, Content6: View, Content7: View, Content8: View, Content9: View,
        Content10: View, Content11: View, Content12: View, Content13: View, Content14: View,
        Content15: View, Content16: View, Content17: View
    >(
        _ column0: TableColumn<RowValue, Content0>, _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<
            RowValue,
            Content2
        >, _ column3: TableColumn<RowValue, Content3>, _ column4: TableColumn<RowValue, Content4>,
        _ column5: TableColumn<
            RowValue,
            Content5
        >, _ column6: TableColumn<RowValue, Content6>, _ column7: TableColumn<RowValue, Content7>,
        _ column8: TableColumn<
            RowValue,
            Content8
        >, _ column9: TableColumn<RowValue, Content9>, _ column10: TableColumn<RowValue, Content10>,
        _ column11: TableColumn<
            RowValue,
            Content11
        >, _ column12: TableColumn<RowValue, Content12>, _ column13: TableColumn<
            RowValue,
            Content13
        >, _ column14: TableColumn<RowValue, Content14>, _ column15: TableColumn<
            RowValue,
            Content15
        >, _ column16: TableColumn<RowValue, Content16>, _ column17: TableColumn<
            RowValue,
            Content17
        >
    ) -> TupleTableRowContent18<
        RowValue, Content0, Content1, Content2, Content3, Content4, Content5, Content6, Content7,
        Content8, Content9, Content10, Content11, Content12, Content13, Content14, Content15,
        Content16, Content17
    > {
        TupleTableRowContent18(
            column0, column1, column2, column3, column4, column5, column6, column7, column8,
            column9,
            column10, column11, column12, column13, column14, column15, column16, column17
        )
    }
    public static func buildBlock<
        Content0: View, Content1: View, Content2: View, Content3: View, Content4: View,
        Content5: View, Content6: View, Content7: View, Content8: View, Content9: View,
        Content10: View, Content11: View, Content12: View, Content13: View, Content14: View,
        Content15: View, Content16: View, Content17: View, Content18: View
    >(
        _ column0: TableColumn<RowValue, Content0>, _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<
            RowValue,
            Content2
        >, _ column3: TableColumn<RowValue, Content3>, _ column4: TableColumn<RowValue, Content4>,
        _ column5: TableColumn<
            RowValue,
            Content5
        >, _ column6: TableColumn<RowValue, Content6>, _ column7: TableColumn<RowValue, Content7>,
        _ column8: TableColumn<
            RowValue,
            Content8
        >, _ column9: TableColumn<RowValue, Content9>, _ column10: TableColumn<RowValue, Content10>,
        _ column11: TableColumn<
            RowValue,
            Content11
        >, _ column12: TableColumn<RowValue, Content12>, _ column13: TableColumn<
            RowValue,
            Content13
        >, _ column14: TableColumn<RowValue, Content14>, _ column15: TableColumn<
            RowValue,
            Content15
        >, _ column16: TableColumn<RowValue, Content16>, _ column17: TableColumn<
            RowValue,
            Content17
        >, _ column18: TableColumn<RowValue, Content18>
    ) -> TupleTableRowContent19<
        RowValue, Content0, Content1, Content2, Content3, Content4, Content5, Content6, Content7,
        Content8, Content9, Content10, Content11, Content12, Content13, Content14, Content15,
        Content16, Content17, Content18
    > {
        TupleTableRowContent19(
            column0, column1, column2, column3, column4, column5, column6, column7, column8,
            column9,
            column10, column11, column12, column13, column14, column15, column16, column17,
            column18
        )
    }
    public static func buildBlock<
        Content0: View, Content1: View, Content2: View, Content3: View, Content4: View,
        Content5: View, Content6: View, Content7: View, Content8: View, Content9: View,
        Content10: View, Content11: View, Content12: View, Content13: View, Content14: View,
        Content15: View, Content16: View, Content17: View, Content18: View, Content19: View
    >(
        _ column0: TableColumn<RowValue, Content0>, _ column1: TableColumn<RowValue, Content1>,
        _ column2: TableColumn<
            RowValue,
            Content2
        >, _ column3: TableColumn<RowValue, Content3>, _ column4: TableColumn<RowValue, Content4>,
        _ column5: TableColumn<
            RowValue,
            Content5
        >, _ column6: TableColumn<RowValue, Content6>, _ column7: TableColumn<RowValue, Content7>,
        _ column8: TableColumn<
            RowValue,
            Content8
        >, _ column9: TableColumn<RowValue, Content9>, _ column10: TableColumn<RowValue, Content10>,
        _ column11: TableColumn<
            RowValue,
            Content11
        >, _ column12: TableColumn<RowValue, Content12>, _ column13: TableColumn<
            RowValue,
            Content13
        >, _ column14: TableColumn<RowValue, Content14>, _ column15: TableColumn<
            RowValue,
            Content15
        >, _ column16: TableColumn<RowValue, Content16>, _ column17: TableColumn<
            RowValue,
            Content17
        >, _ column18: TableColumn<RowValue, Content18>, _ column19: TableColumn<
            RowValue,
            Content19
        >
    ) -> TupleTableRowContent20<
        RowValue, Content0, Content1, Content2, Content3, Content4, Content5, Content6, Content7,
        Content8, Content9, Content10, Content11, Content12, Content13, Content14, Content15,
        Content16, Content17, Content18, Content19
    > {
        TupleTableRowContent20(
            column0, column1, column2, column3, column4, column5, column6, column7, column8,
            column9,
            column10, column11, column12, column13, column14, column15, column16, column17,
            column18, column19
        )
    }
}
