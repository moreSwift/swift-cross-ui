import CGtk3
import Gtk3
@_spi(Backends) import SwiftCrossUI

extension Gtk3Backend: BackendFeatures.Images {
    public var requiresImageUpdateOnScaleFactorChange: Bool { true }

    public func createImageView() -> Widget {
        let imageView = Gtk3.Image()
        return imageView
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
        let imageView = imageView as! Gtk3.Image

        // Check if the resulting image would be empty
        guard targetWidth > 0, targetHeight > 0 else {
            imageView.clear()
            return
        }

        let pixbuf = Pixbuf(
            rgbaData: rgbaData,
            width: width,
            height: height
        )

        let surface = pixbuf.hidpiAwareScaled(
            toLogicalWidth: targetWidth,
            andLogicalHeight: targetHeight,
            for: imageView
        )

        imageView.setCairoSurface(surface)
        imageView.show()
    }
}
