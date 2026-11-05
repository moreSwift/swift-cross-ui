@_spi(Backends) import SwiftCrossUI

extension DummyBackend: BackendFeatures.Images {
    public var requiresImageUpdateOnScaleFactorChange: Bool { false }

    public func createImageView() -> Widget {
        ImageView()
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
        let imageView = imageView as! ImageView
        imageView.rgbaData = rgbaData
        imageView.pixelWidth = width
        imageView.pixelHeight = height
    }
}
