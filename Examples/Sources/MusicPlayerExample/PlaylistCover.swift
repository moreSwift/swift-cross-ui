import Foundation
import SwiftCrossUI

struct PlaylistCover: View {
    var image: URL?
    var dimension: Int
    var cornerRadius: Int

    var body: some View {
        Group {
            if let image = image {
                Image(image)
                    .resizable()
            } else {
                Color.gray
            }
        }
        .aspectRatio(1, contentMode: .fill)
        .frame(width: dimension, height: dimension)
        .cornerRadius(cornerRadius)
    }
}
