import SwiftUI

let censorImages = false

let imageForegroundGradient = LinearGradient(gradient: Gradient(colors: [.clear, Color(.sRGBLinear, white: 0, opacity: 0.75)]), startPoint: .top, endPoint: .bottom)

enum EntityImageSize {
    case small
    case large
}

struct EntityImage : View {
    let imageUrl: String?
    let size: EntityImageSize
    
    private var imageView: some View {
        get {
            var imageUrl = self.imageUrl
            if imageUrl?.isEmpty ?? true {
                imageUrl = LTopAlbumsResponseAlbum.fake.imageUrl
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
