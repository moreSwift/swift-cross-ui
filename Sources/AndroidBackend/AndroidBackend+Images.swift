import SwiftCrossUI
import AndroidKit
import SwiftJava

@JavaClass("java.nio.Buffer")
class JavaNioBuffer: JavaObject {
}

extension JavaClass where JavaClass_T == AndroidKit.ByteBuffer {
    @JavaStaticMethod
    func wrap(_ array: [UInt8]) -> AndroidKit.ByteBuffer?
}

extension AndroidKit.Bitmap {
    @JavaMethod
    func copyPixelsFromBuffer(_ src: JavaNioBuffer?)
}

extension AndroidKit.ImageView {
    @JavaMethod
    func setImageBitmap(_ bm: AndroidKit.Bitmap?)
}

// swiftlint:disable force_try
extension AndroidBackend: BackendFeatures.Images {
    public var requiresImageUpdateOnScaleFactorChange: Bool { false }

    public func createImageView() -> Widget {
        AndroidKit.ImageView(Self.activity, environment: Self.env)
    }

    public func updateImageView(
        _ imageView: Widget,
        rgbaData: [UInt8],
        width: Int,
        height: Int,
        targetWidth: Int,
        targetHeight: Int,
        dataHasChanged: Bool,
        environment: EnvironmentValues
    ) {
        guard dataHasChanged else { return }

        let imageView = imageView.as(AndroidKit.ImageView.self)!

        let bitmap = try! JavaClass<AndroidKit.Bitmap>().createBitmap(
            Int32(width),
            Int32(height),
            try! JavaClass<AndroidKit.Bitmap.Config>().ARGB_8888,
            true
        )!

        let buffer = try! JavaClass<AndroidKit.ByteBuffer>().wrap(rgbaData)!

        bitmap.copyPixelsFromBuffer(buffer.as(JavaNioBuffer.self)!)

        imageView.setImageBitmap(bitmap)
    }
}
