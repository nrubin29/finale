import SwiftUI

let censorImages = false

private let imageForegroundGradient = LinearGradient(
    gradient: Gradient(colors: [
        .clear, Color(.sRGBLinear, white: 0, opacity: 0.75),
    ]), startPoint: .top, endPoint: .bottom
)

@available(iOSApplicationExtension 16.0, *)
private struct DynamicImageForegroundGradient: View {
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    var body: some View {
        if widgetRenderingMode == .fullColor {
            imageForegroundGradient
        } else {
            EmptyView()
        }
    }
}

struct ImageForegroundGradient: View {
    var body: some View {
        if #available(iOSApplicationExtension 16.0, *) {
            DynamicImageForegroundGradient()
        } else {
            imageForegroundGradient
        }
    }
}

enum EntityImageSize {
    case small
    case large
}

struct EntityImage: View {
    let imageUrl: String?
    let entityType: EntityType?
    let size: EntityImageSize

    @ViewBuilder
    private var imageView: some View {
        if let imageUrl = imageUrl, let url = URL(string: imageUrl),
            let imageData = try? Data(contentsOf: url),
            let uiImage = UIImage(data: imageData)
        {
            if #available(iOSApplicationExtension 18.0, *) {
                Image(uiImage: uiImage)
                    .resizable()
                    .widgetAccentedRenderingMode(.fullColor)
            } else {
                Image(uiImage: uiImage)
                    .resizable()
            }
        } else {
            Placeholder(entityType: entityType)
        }
    }

    var body: some View {
        if censorImages {
            ZStack(alignment: size == .small ? .center : .top) {
                imageView
                    .blur(radius: 10)
                Text("Image hidden due to copyright")
                    .font(.system(size: size == .small ? 10 : 16))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 1)
                    .multilineTextAlignment(.center)
                    .padding(size == .small ? [] : .top)
            }
        } else {
            imageView
        }
    }
}

private struct Placeholder: View {
    let entityType: EntityType?

    private var iconName: String {
        switch entityType {
        case .track: return "MusicNoteIcon"
        case .artist: return "ArtistIcon"
        case .album: return "AlbumIcon"
        default: return "AlbumIcon"
        }
    }

    var body: some View {
        ZStack {
            if #available(iOSApplicationExtension 18.0, *) {
                Image(iconName)
                    .resizable()
                    .widgetAccentedRenderingMode(.fullColor)
                    .padding()
            } else {
                Image(iconName)
                    .resizable()
                    .padding()
            }
        }
        .background(Color("PlaceholderBackground"))
    }
}
