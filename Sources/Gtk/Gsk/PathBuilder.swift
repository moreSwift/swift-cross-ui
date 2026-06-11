// import CGtk
//
// open class PathBuilder: GObject {
//     public init() {
//         super.init(gsk_path_builder_new())
//     }
//
//     public func move(to point: SIMD2<Double>) {
//         gsk_path_builder_move_to(opaquePointer, Float(point.x), Float(point.y))
//     }
//
//     public func line(to point: SIMD2<Double>) {
//         gsk_path_builder_line_to(opaquePointer, Float(point.x), Float(point.y))
//     }
//
//     public func curve(to point: SIMD2<Double>, controlPoint: SIMD2<Double>) {
//         gsk_path_builder_quad_to(
//             opaquePointer,
//             Float(controlPoint.x),
//             Float(controlPoint.y),
//             Float(point.x),
//             Float(point.y)
//         )
//     }
//
//     public func curve(
//         to point: SIMD2<Double>,
//         controlPoint1: SIMD2<Double>,
//         controlPoint2: SIMD2<Double>
//     ) {
//         gsk_path_builder_cubic_to(
//             opaquePointer,
//             Float(controlPoint1.x),
//             Float(controlPoint1.y),
//             Float(controlPoint2.x),
//             Float(controlPoint2.y),
//             Float(point.x),
//             Float(point.y)
//         )
//     }
//
//     public func appendRect(origin: SIMD2<Double>, size: SIMD2<Double>) {
//         let rect = graphene_rect_alloc()
//         graphene_rect_init(
//             rect,
//             Float(origin.x),
//             Float(origin.y),
//             Float(size.x),
//             Float(size.y)
//         )
//         gsk_path_builder_add_rect(opaquePointer, rect)
//         graphene_rect_free(rect)
//     }
//
//     public func appendCircle(center: SIMD2<Double>, radius: Double) {
//         let centerPoint = graphene_point_alloc()
//         graphene_point_init(centerPoint, Float(center.x), Float(center.y))
//         gsk_path_builder_add_circle(opaquePointer, centerPoint, Float(radius))
//         graphene_point_free(centerPoint)
//     }
//
//     public func appendArc(
//         withCenter center: SIMD2<Double>,
//         radius: Double,
//         startAngle: Double,
//         endAngle: Double,
//         clockwise: Bool
//     ) {
//         gsk_path_builder_line_to(
//            opaquePointer,
//            Float(center.x + cos(startAngle)),
//            Float(center.y + sin(endAngle))
//         )
//         gsk_path_builder_move_to(
//            opaquePointer,
//            Float(center.x + cos(endAngle)),
//            Float(center.y + sin(endAngle))
//         )
//     }
//
//     public consuming func finalize() -> OpaquePointer {
//         gsk_path_builder_free_to_path(opaquePointer)
//     }
// }
