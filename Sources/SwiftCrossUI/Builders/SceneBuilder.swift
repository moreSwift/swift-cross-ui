// This file was generated using gyb. Do not edit it directly. Edit
// SceneBuilder.swift.gyb instead.

// swiftformat:options --allow-partial-wrapping true

/// Builds an app's root scene by composing other scenes together.
@resultBuilder
public struct SceneBuilder {
    /// A single scene doesn't need to get wrapped, simply pass it straight through.
    public static func buildBlock<Content: Scene>(_ content: Content) -> Content {
        return content
    }

    public static func buildBlock<
        Scene0: Scene, Scene1: Scene
    >(
        _ scene0: Scene0, _ scene1: Scene1
    ) -> TupleScene2<
        Scene0, Scene1
    > {
        return TupleScene2(
            scene0, scene1
        )
    }

    public static func buildBlock<
        Scene0: Scene, Scene1: Scene, Scene2: Scene
    >(
        _ scene0: Scene0, _ scene1: Scene1, _ scene2: Scene2
    ) -> TupleScene3<
        Scene0, Scene1, Scene2
    > {
        return TupleScene3(
            scene0, scene1, scene2
        )
    }

    public static func buildBlock<
        Scene0: Scene, Scene1: Scene, Scene2: Scene, Scene3: Scene
    >(
        _ scene0: Scene0, _ scene1: Scene1, _ scene2: Scene2, _ scene3: Scene3
    ) -> TupleScene4<
        Scene0, Scene1, Scene2, Scene3
    > {
        return TupleScene4(
            scene0, scene1, scene2, scene3
        )
    }

    public static func buildBlock<
        Scene0: Scene, Scene1: Scene, Scene2: Scene, Scene3: Scene, Scene4: Scene
    >(
        _ scene0: Scene0, _ scene1: Scene1, _ scene2: Scene2, _ scene3: Scene3, _ scene4: Scene4
    ) -> TupleScene5<
        Scene0, Scene1, Scene2, Scene3, Scene4
    > {
        return TupleScene5(
            scene0, scene1, scene2, scene3, scene4
        )
    }

    public static func buildBlock<
        Scene0: Scene, Scene1: Scene, Scene2: Scene, Scene3: Scene, Scene4: Scene, Scene5: Scene
    >(
        _ scene0: Scene0, _ scene1: Scene1, _ scene2: Scene2, _ scene3: Scene3, _ scene4: Scene4,
        _ scene5: Scene5
    ) -> TupleScene6<
        Scene0, Scene1, Scene2, Scene3, Scene4, Scene5
    > {
        return TupleScene6(
            scene0, scene1, scene2, scene3, scene4, scene5
        )
    }

    public static func buildBlock<
        Scene0: Scene, Scene1: Scene, Scene2: Scene, Scene3: Scene, Scene4: Scene, Scene5: Scene,
        Scene6: Scene
    >(
        _ scene0: Scene0, _ scene1: Scene1, _ scene2: Scene2, _ scene3: Scene3, _ scene4: Scene4,
        _ scene5: Scene5, _ scene6: Scene6
    ) -> TupleScene7<
        Scene0, Scene1, Scene2, Scene3, Scene4, Scene5, Scene6
    > {
        return TupleScene7(
            scene0, scene1, scene2, scene3, scene4, scene5, scene6
        )
    }

    public static func buildBlock<
        Scene0: Scene, Scene1: Scene, Scene2: Scene, Scene3: Scene, Scene4: Scene, Scene5: Scene,
        Scene6: Scene, Scene7: Scene
    >(
        _ scene0: Scene0, _ scene1: Scene1, _ scene2: Scene2, _ scene3: Scene3, _ scene4: Scene4,
        _ scene5: Scene5, _ scene6: Scene6, _ scene7: Scene7
    ) -> TupleScene8<
        Scene0, Scene1, Scene2, Scene3, Scene4, Scene5, Scene6, Scene7
    > {
        return TupleScene8(
            scene0, scene1, scene2, scene3, scene4, scene5, scene6, scene7
        )
    }

    public static func buildBlock<
        Scene0: Scene, Scene1: Scene, Scene2: Scene, Scene3: Scene, Scene4: Scene, Scene5: Scene,
        Scene6: Scene, Scene7: Scene, Scene8: Scene
    >(
        _ scene0: Scene0, _ scene1: Scene1, _ scene2: Scene2, _ scene3: Scene3, _ scene4: Scene4,
        _ scene5: Scene5, _ scene6: Scene6, _ scene7: Scene7, _ scene8: Scene8
    ) -> TupleScene9<
        Scene0, Scene1, Scene2, Scene3, Scene4, Scene5, Scene6, Scene7, Scene8
    > {
        return TupleScene9(
            scene0, scene1, scene2, scene3, scene4, scene5, scene6, scene7, scene8
        )
    }

    public static func buildBlock<
        Scene0: Scene, Scene1: Scene, Scene2: Scene, Scene3: Scene, Scene4: Scene, Scene5: Scene,
        Scene6: Scene, Scene7: Scene, Scene8: Scene, Scene9: Scene
    >(
        _ scene0: Scene0, _ scene1: Scene1, _ scene2: Scene2, _ scene3: Scene3, _ scene4: Scene4,
        _ scene5: Scene5, _ scene6: Scene6, _ scene7: Scene7, _ scene8: Scene8, _ scene9: Scene9
    ) -> TupleScene10<
        Scene0, Scene1, Scene2, Scene3, Scene4, Scene5, Scene6, Scene7, Scene8, Scene9
    > {
        return TupleScene10(
            scene0, scene1, scene2, scene3, scene4, scene5, scene6, scene7, scene8, scene9
        )
    }

    public static func buildBlock<
        Scene0: Scene, Scene1: Scene, Scene2: Scene, Scene3: Scene, Scene4: Scene, Scene5: Scene,
        Scene6: Scene, Scene7: Scene, Scene8: Scene, Scene9: Scene, Scene10: Scene
    >(
        _ scene0: Scene0, _ scene1: Scene1, _ scene2: Scene2, _ scene3: Scene3, _ scene4: Scene4,
        _ scene5: Scene5, _ scene6: Scene6, _ scene7: Scene7, _ scene8: Scene8,
        _ scene9: Scene9,
        _ scene10: Scene10
    ) -> TupleScene11<
        Scene0, Scene1, Scene2, Scene3, Scene4, Scene5, Scene6, Scene7, Scene8, Scene9, Scene10
    > {
        return TupleScene11(
            scene0, scene1, scene2, scene3, scene4, scene5, scene6, scene7, scene8, scene9, scene10
        )
    }

    public static func buildBlock<
        Scene0: Scene, Scene1: Scene, Scene2: Scene, Scene3: Scene, Scene4: Scene, Scene5: Scene,
        Scene6: Scene, Scene7: Scene, Scene8: Scene, Scene9: Scene, Scene10: Scene,
        Scene11: Scene
    >(
        _ scene0: Scene0, _ scene1: Scene1, _ scene2: Scene2, _ scene3: Scene3, _ scene4: Scene4,
        _ scene5: Scene5, _ scene6: Scene6, _ scene7: Scene7, _ scene8: Scene8,
        _ scene9: Scene9,
        _ scene10: Scene10, _ scene11: Scene11
    ) -> TupleScene12<
        Scene0, Scene1, Scene2, Scene3, Scene4, Scene5, Scene6, Scene7, Scene8, Scene9, Scene10,
        Scene11
    > {
        return TupleScene12(
            scene0, scene1, scene2, scene3, scene4, scene5, scene6, scene7, scene8, scene9, scene10,
            scene11
        )
    }

    public static func buildBlock<
        Scene0: Scene, Scene1: Scene, Scene2: Scene, Scene3: Scene, Scene4: Scene, Scene5: Scene,
        Scene6: Scene, Scene7: Scene, Scene8: Scene, Scene9: Scene, Scene10: Scene,
        Scene11: Scene, Scene12: Scene
    >(
        _ scene0: Scene0, _ scene1: Scene1, _ scene2: Scene2, _ scene3: Scene3, _ scene4: Scene4,
        _ scene5: Scene5, _ scene6: Scene6, _ scene7: Scene7, _ scene8: Scene8,
        _ scene9: Scene9,
        _ scene10: Scene10, _ scene11: Scene11, _ scene12: Scene12
    ) -> TupleScene13<
        Scene0, Scene1, Scene2, Scene3, Scene4, Scene5, Scene6, Scene7, Scene8, Scene9, Scene10,
        Scene11, Scene12
    > {
        return TupleScene13(
            scene0, scene1, scene2, scene3, scene4, scene5, scene6, scene7, scene8, scene9, scene10,
            scene11, scene12
        )
    }

    public static func buildBlock<
        Scene0: Scene, Scene1: Scene, Scene2: Scene, Scene3: Scene, Scene4: Scene, Scene5: Scene,
        Scene6: Scene, Scene7: Scene, Scene8: Scene, Scene9: Scene, Scene10: Scene,
        Scene11: Scene, Scene12: Scene, Scene13: Scene
    >(
        _ scene0: Scene0, _ scene1: Scene1, _ scene2: Scene2, _ scene3: Scene3, _ scene4: Scene4,
        _ scene5: Scene5, _ scene6: Scene6, _ scene7: Scene7, _ scene8: Scene8,
        _ scene9: Scene9,
        _ scene10: Scene10, _ scene11: Scene11, _ scene12: Scene12, _ scene13: Scene13
    ) -> TupleScene14<
        Scene0, Scene1, Scene2, Scene3, Scene4, Scene5, Scene6, Scene7, Scene8, Scene9, Scene10,
        Scene11, Scene12, Scene13
    > {
        return TupleScene14(
            scene0, scene1, scene2, scene3, scene4, scene5, scene6, scene7, scene8, scene9, scene10,
            scene11, scene12, scene13
        )
    }

    public static func buildBlock<
        Scene0: Scene, Scene1: Scene, Scene2: Scene, Scene3: Scene, Scene4: Scene, Scene5: Scene,
        Scene6: Scene, Scene7: Scene, Scene8: Scene, Scene9: Scene, Scene10: Scene,
        Scene11: Scene, Scene12: Scene, Scene13: Scene, Scene14: Scene
    >(
        _ scene0: Scene0, _ scene1: Scene1, _ scene2: Scene2, _ scene3: Scene3, _ scene4: Scene4,
        _ scene5: Scene5, _ scene6: Scene6, _ scene7: Scene7, _ scene8: Scene8,
        _ scene9: Scene9,
        _ scene10: Scene10, _ scene11: Scene11, _ scene12: Scene12, _ scene13: Scene13,
        _ scene14: Scene14
    ) -> TupleScene15<
        Scene0, Scene1, Scene2, Scene3, Scene4, Scene5, Scene6, Scene7, Scene8, Scene9, Scene10,
        Scene11, Scene12, Scene13, Scene14
    > {
        return TupleScene15(
            scene0, scene1, scene2, scene3, scene4, scene5, scene6, scene7, scene8, scene9, scene10,
            scene11, scene12, scene13, scene14
        )
    }

    public static func buildBlock<
        Scene0: Scene, Scene1: Scene, Scene2: Scene, Scene3: Scene, Scene4: Scene, Scene5: Scene,
        Scene6: Scene, Scene7: Scene, Scene8: Scene, Scene9: Scene, Scene10: Scene,
        Scene11: Scene, Scene12: Scene, Scene13: Scene, Scene14: Scene, Scene15: Scene
    >(
        _ scene0: Scene0, _ scene1: Scene1, _ scene2: Scene2, _ scene3: Scene3, _ scene4: Scene4,
        _ scene5: Scene5, _ scene6: Scene6, _ scene7: Scene7, _ scene8: Scene8,
        _ scene9: Scene9,
        _ scene10: Scene10, _ scene11: Scene11, _ scene12: Scene12, _ scene13: Scene13,
        _ scene14: Scene14, _ scene15: Scene15
    ) -> TupleScene16<
        Scene0, Scene1, Scene2, Scene3, Scene4, Scene5, Scene6, Scene7, Scene8, Scene9, Scene10,
        Scene11, Scene12, Scene13, Scene14, Scene15
    > {
        return TupleScene16(
            scene0, scene1, scene2, scene3, scene4, scene5, scene6, scene7, scene8, scene9, scene10,
            scene11, scene12, scene13, scene14, scene15
        )
    }

    public static func buildBlock<
        Scene0: Scene, Scene1: Scene, Scene2: Scene, Scene3: Scene, Scene4: Scene, Scene5: Scene,
        Scene6: Scene, Scene7: Scene, Scene8: Scene, Scene9: Scene, Scene10: Scene,
        Scene11: Scene, Scene12: Scene, Scene13: Scene, Scene14: Scene, Scene15: Scene,
        Scene16: Scene
    >(
        _ scene0: Scene0, _ scene1: Scene1, _ scene2: Scene2, _ scene3: Scene3, _ scene4: Scene4,
        _ scene5: Scene5, _ scene6: Scene6, _ scene7: Scene7, _ scene8: Scene8,
        _ scene9: Scene9,
        _ scene10: Scene10, _ scene11: Scene11, _ scene12: Scene12, _ scene13: Scene13,
        _ scene14: Scene14, _ scene15: Scene15, _ scene16: Scene16
    ) -> TupleScene17<
        Scene0, Scene1, Scene2, Scene3, Scene4, Scene5, Scene6, Scene7, Scene8, Scene9, Scene10,
        Scene11, Scene12, Scene13, Scene14, Scene15, Scene16
    > {
        return TupleScene17(
            scene0, scene1, scene2, scene3, scene4, scene5, scene6, scene7, scene8, scene9, scene10,
            scene11, scene12, scene13, scene14, scene15, scene16
        )
    }

    public static func buildBlock<
        Scene0: Scene, Scene1: Scene, Scene2: Scene, Scene3: Scene, Scene4: Scene, Scene5: Scene,
        Scene6: Scene, Scene7: Scene, Scene8: Scene, Scene9: Scene, Scene10: Scene,
        Scene11: Scene, Scene12: Scene, Scene13: Scene, Scene14: Scene, Scene15: Scene,
        Scene16: Scene, Scene17: Scene
    >(
        _ scene0: Scene0, _ scene1: Scene1, _ scene2: Scene2, _ scene3: Scene3, _ scene4: Scene4,
        _ scene5: Scene5, _ scene6: Scene6, _ scene7: Scene7, _ scene8: Scene8,
        _ scene9: Scene9,
        _ scene10: Scene10, _ scene11: Scene11, _ scene12: Scene12, _ scene13: Scene13,
        _ scene14: Scene14, _ scene15: Scene15, _ scene16: Scene16, _ scene17: Scene17
    ) -> TupleScene18<
        Scene0, Scene1, Scene2, Scene3, Scene4, Scene5, Scene6, Scene7, Scene8, Scene9, Scene10,
        Scene11, Scene12, Scene13, Scene14, Scene15, Scene16, Scene17
    > {
        return TupleScene18(
            scene0, scene1, scene2, scene3, scene4, scene5, scene6, scene7, scene8, scene9, scene10,
            scene11, scene12, scene13, scene14, scene15, scene16, scene17
        )
    }

    public static func buildBlock<
        Scene0: Scene, Scene1: Scene, Scene2: Scene, Scene3: Scene, Scene4: Scene, Scene5: Scene,
        Scene6: Scene, Scene7: Scene, Scene8: Scene, Scene9: Scene, Scene10: Scene,
        Scene11: Scene, Scene12: Scene, Scene13: Scene, Scene14: Scene, Scene15: Scene,
        Scene16: Scene, Scene17: Scene, Scene18: Scene
    >(
        _ scene0: Scene0, _ scene1: Scene1, _ scene2: Scene2, _ scene3: Scene3, _ scene4: Scene4,
        _ scene5: Scene5, _ scene6: Scene6, _ scene7: Scene7, _ scene8: Scene8,
        _ scene9: Scene9,
        _ scene10: Scene10, _ scene11: Scene11, _ scene12: Scene12, _ scene13: Scene13,
        _ scene14: Scene14, _ scene15: Scene15, _ scene16: Scene16, _ scene17: Scene17,
        _ scene18: Scene18
    ) -> TupleScene19<
        Scene0, Scene1, Scene2, Scene3, Scene4, Scene5, Scene6, Scene7, Scene8, Scene9, Scene10,
        Scene11, Scene12, Scene13, Scene14, Scene15, Scene16, Scene17, Scene18
    > {
        return TupleScene19(
            scene0, scene1, scene2, scene3, scene4, scene5, scene6, scene7, scene8, scene9, scene10,
            scene11, scene12, scene13, scene14, scene15, scene16, scene17, scene18
        )
    }

    public static func buildBlock<
        Scene0: Scene, Scene1: Scene, Scene2: Scene, Scene3: Scene, Scene4: Scene, Scene5: Scene,
        Scene6: Scene, Scene7: Scene, Scene8: Scene, Scene9: Scene, Scene10: Scene,
        Scene11: Scene, Scene12: Scene, Scene13: Scene, Scene14: Scene, Scene15: Scene,
        Scene16: Scene, Scene17: Scene, Scene18: Scene, Scene19: Scene
    >(
        _ scene0: Scene0, _ scene1: Scene1, _ scene2: Scene2, _ scene3: Scene3, _ scene4: Scene4,
        _ scene5: Scene5, _ scene6: Scene6, _ scene7: Scene7, _ scene8: Scene8,
        _ scene9: Scene9,
        _ scene10: Scene10, _ scene11: Scene11, _ scene12: Scene12, _ scene13: Scene13,
        _ scene14: Scene14, _ scene15: Scene15, _ scene16: Scene16, _ scene17: Scene17,
        _ scene18: Scene18, _ scene19: Scene19
    ) -> TupleScene20<
        Scene0, Scene1, Scene2, Scene3, Scene4, Scene5, Scene6, Scene7, Scene8, Scene9, Scene10,
        Scene11, Scene12, Scene13, Scene14, Scene15, Scene16, Scene17, Scene18, Scene19
    > {
        return TupleScene20(
            scene0, scene1, scene2, scene3, scene4, scene5, scene6, scene7, scene8, scene9, scene10,
            scene11, scene12, scene13, scene14, scene15, scene16, scene17, scene18, scene19
        )
    }
}
