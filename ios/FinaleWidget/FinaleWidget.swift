import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    private func createEntry(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        if configuration.username == nil || configuration.username!.isEmpty {
            completion(SimpleEntry(date: Date(), albums: [], configuration: configuration))
            return
        }
        
        GetTopAlbumsRequest(username: configuration.username!, period: configuration.period).doRequest(limit: context.family.numItemsToDisplay, page: 1) { albums in
            completion(SimpleEntry(date: Date(), albums: albums ?? [], configuration: configuration))
        }
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), albums: (0..<context.family.numItemsToDisplay).map({ _ in LTopAlbumsResponseAlbum.fake }), configuration: ConfigurationIntent())
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        createEntry(for: configuration, in: context, completion: completion)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        createEntry(for: configuration, in: context) { entry in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let albums: [LTopAlbumsResponseAlbum]
    let configuration: ConfigurationIntent
}

struct FinaleWidgetEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: Provider.Entry
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall: FinaleWidgetEntryViewSmall(entry: entry)
        default: FinaleWidgetEntryViewLarge(entry: entry)
        }
    }
}

func getImageForAlbum(_ album: LTopAlbumsResponseAlbum?) -> UIImage? {
    var albumImageUrl = album?.images.last?.url
    if albumImageUrl == nil || albumImageUrl!.isEmpty {
        albumImageUrl = LTopAlbumsResponseAlbum.fake.images.last!.url
    }
    
    if let url = URL(string: albumImageUrl!), let imageData = try? Data(contentsOf: url), let uiImage = UIImage(data: imageData) {
        return uiImage
    }
    
    return nil
}

func getLinkUrl(_ album: LTopAlbumsResponseAlbum) -> URL {
    var components = URLComponents()
    components.scheme = "finale"
    components.path = "/album"
    components.queryItems = [URLQueryItem(name: "name", value: album.name), URLQueryItem(name: "artist", value: album.artist.name)]
    return components.url!
}

struct FinaleWidgetEntryViewSmall : View {
    var entry: Provider.Entry
    
    var album: LTopAlbumsResponseAlbum? {
        get {
            return entry.albums.first
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let uiImage = getImageForAlbum(album) {
                ZStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    LinearGradient(gradient: Gradient(colors: [.clear, Color(.sRGBLinear, white: 0, opacity: 0.75)]), startPoint: .top, endPoint: .bottom)
                }
            }
            VStack {
                Spacer()
                VStack(alignment: .leading) {
                    if entry.configuration.username == nil {
                        Text("Please enter your username in the widget settings.")
                            .bold()
                            .foregroundColor(.white)
                            .font(.subheadline)
                    } else if let album = album {
                        Text(album.name)
                            .bold()
                            .foregroundColor(.white)
                            .font(.subheadline)
                        Text(album.artist.name)
                            .foregroundColor(.white)
                            .font(.footnote)
                        Text(album.playCountFormatted)
                            .foregroundColor(.white)
                            .font(.footnote)
                    } else {
                        Text("You haven't scrobbled any albums in this period.")
                            .bold()
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }
                }
                .padding()
            }
        }
        .widgetURL(album != nil ? getLinkUrl(album!) : nil)
    }
}

struct FinaleWidgetEntryViewLarge : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: Provider.Entry
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color("WidgetBackgroundStart"), Color("WidgetBackgroundEnd")]), startPoint: .top, endPoint: .bottom)
            VStack(alignment: .leading) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Top Albums")
                        .bold()
                        .foregroundColor(Color("AccentColor"))
                    Text(entry.configuration.period.displayName)
                        .bold()
                        .font(.caption)
                        .foregroundColor(Color("AccentColor"))
                    Spacer()
                    Image(uiImage: UIImage(named: "FinaleIconWhite")!)
                        .resizable()
                        .frame(width: 15, height: 15)
                        .colorMultiply(Color("AccentColor"))
                }
                if entry.configuration.username == nil {
                    Text("Please enter your username in the widget settings.")
                        .foregroundColor(Color("AccentColor"))
                } else if !entry.albums.isEmpty {
                    LazyVGrid(columns: (0..<family.numColumns).map({_ in GridItem(.flexible())})) {
                        ForEach(entry.albums.prefix(family.numItemsToDisplay)) { album in
                            Link(destination: getLinkUrl(album)) {
                                VStack {
                                    if let uiImage = getImageForAlbum(album) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .mask(RoundedRectangle(cornerRadius: 5))
                                    }
                                    Text(album.playCountFormatted)
                                        .font(Font.system(size: 8))
                                        .foregroundColor(Color("AccentColor"))
                                        .bold()
                                }
                            }
                        }
                    }
                } else {
                    Text("You haven't scrobbled any albums in this period.")
                        .foregroundColor(Color("AccentColor"))
                }
            }
            .padding(.horizontal)
        }
    }
}

@main
struct FinaleWidget: Widget {
    let kind: String = "FinaleWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            FinaleWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Top Albums")
        .description("Your top albums for a given period.")
    }
}

struct FinaleWidget_Previews: PreviewProvider {
    static var previews: some View {
        FinaleWidgetEntryView(entry: SimpleEntry(date: Date(), albums: [LTopAlbumsResponseAlbum.fake], configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

extension WidgetFamily {
    var numItemsToDisplay: Int {
        get {
            switch self {
            case .systemSmall: return 1
            case .systemMedium: return 4
            case .systemLarge: return 12
            case .systemExtraLarge: return 24
            @unknown default: return 1
            }
        }
    }
    
    var numColumns: Int {
        get {
            switch self {
            case .systemSmall: return 1
            case .systemMedium: return 4
            case .systemLarge: return 4
            case .systemExtraLarge: return 8
            @unknown default: return 1
            }
        }
    }
}
