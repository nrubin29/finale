import SwiftUI

let censorImages = false

let imageForegroundGradient = LinearGradient(gradient: Gradient(colors: [.clear, Color(.sRGBLinear, white: 0, opacity: 0.75)]), startPoint: .top, endPoint: .bottom)

enum EntityImageSize {
    case small
    case large
}

struct EntityImage : View {
    let imageUrl: String?
    let entityType: EntityType?
    let size: EntityImageSize
    
    @ViewBuilder
    private var imageView: some View {
        get {
            if let imageUrl = imageUrl, let url = URL(string: imageUrl), let imageData = try? Data(contentsOf: url), let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
            } else {
                Placeholder(entityType: entityType)
            }
        }
    }
    
    var body: some View {
        if censorImages {
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

private struct Placeholder : View {
    let entityType: EntityType?
    
    private var iconName: String {
        get {
            switch entityType {
            case .track: return "MusicNoteIcon"
            case .artist: return "ArtistIcon"
            case .album: return "AlbumIcon"
            default: return "AlbumIcon"
            }
        }
    }
    
    var body: some View {
        ZStack {
            Image(iconName)
                .resizable()
                .padding()
        }
        .background(Color("PlaceholderBackground"))
    }
}
