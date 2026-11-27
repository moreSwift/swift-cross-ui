@_spi(Backends) import SwiftCrossUI
import WinUI
import Foundation

// swiftlint:disable force_try
extension WinUIBackend: BackendFeatures.Images {
    public var requiresImageUpdateOnScaleFactorChange: Bool { false }

    public func createImageView() -> Widget {
        WinUI.Image()
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
        let imageView = imageView as! WinUI.Image
        let bitmap = WriteableBitmap(Int32(width), Int32(height))
        let buffer = try! bitmap.pixelBuffer.buffer!
        memcpy(buffer, rgbaData, min(Int(bitmap.pixelBuffer.length), rgbaData.count))

        // Convert RGBA to BGRA in-place, and apply janky transparency fix until we
        // figure out how to fix WinUI image blending (non-black transparent pixels
        // just don't seem to get blended at all, or at least pixels that are white
        // enough, haven't tested many colours).
        for i in 0..<(width * height) {
            let offset = i * 4
            if buffer[offset + 3] == 0 {
                // If transparent, make the pixel black (this is the janky blending fix).
                buffer[offset] = 0
                buffer[offset + 1] = 0
                buffer[offset + 2] = 0
            } else {
                // Swap R and B (RGBA to BGRA)
                let tmp = buffer[offset]
                buffer[offset] = buffer[offset + 2]
                buffer[offset + 2] = tmp
            }
        }

        imageView.source = bitmap
    }
}
