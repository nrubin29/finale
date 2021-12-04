import SwiftUI

let censorImages = false

enum EntityImageSize {
    case small
    case large
}

struct EntityImage : View {
    let image: LImage?
    let size: EntityImageSize
    
    private var imageView: some View {
        get {
            var imageUrl = image?.url
            if imageUrl == nil || imageUrl!.isEmpty {
                imageUrl = LTopAlbumsResponseAlbum.fake.images.last!.url
            }
            
            if let url = URL(string: imageUrl!), let imageData = try? Data(contentsOf: url), let uiImage = UIImage(data: imageData) {
                return Image(uiImage: uiImage)
                    .resizable()
            }
            
            return Image("AlbumImage")
                .resizable()
        }
    }
    
    var body: some View {
        if (censorImages) {
            ZStack(alignment: size == .small ? .center : .top) {
                imageView
                    .blur(radius: 10)
                Text("Image hidden due to copyright")
                    .font(.system(size: size == .small ? 10 : 16))
                    .multilineTextAlignment(.center)
                    .padding(size == .small ? [] : .top)
            }
        } else {
            imageView
        }
    }
}
