import WidgetKit
import SwiftUI
import Intents

struct TopEntitiesProvider: IntentTimelineProvider {
    private func createEntry(for configuration: TopEntitiesConfigurationIntent, in context: Context, completion: @escaping (TopEntitiesEntry) -> Void) {
        if configuration.username == nil || configuration.username!.isEmpty {
            completion(TopEntitiesEntry(date: Date(), albums: [], configuration: configuration))
            return
        }
        
        GetTopAlbumsRequest(username: configuration.username!, period: configuration.period).doRequest(limit: context.family.numItemsToDisplay, page: 1) { albums in
            completion(TopEntitiesEntry(date: Date(), albums: albums ?? [], configuration: configuration))
        }
    }
    
    func placeholder(in context: Context) -> TopEntitiesEntry {
        TopEntitiesEntry(date: Date(), albums: (0..<context.family.numItemsToDisplay).map({ _ in LTopAlbumsResponseAlbum.fake }), configuration: TopEntitiesConfigurationIntent())
    }
    
    func getSnapshot(for configuration: TopEntitiesConfigurationIntent, in context: Context, completion: @escaping (TopEntitiesEntry) -> ()) {
        createEntry(for: configuration, in: context, completion: completion)
    }
    
    func getTimeline(for configuration: TopEntitiesConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        createEntry(for: configuration, in: context) { entry in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}

struct TopEntitiesEntry: TimelineEntry {
    let date: Date
    let albums: [LTopAlbumsResponseAlbum]
    let configuration: TopEntitiesConfigurationIntent
}

struct TopEntitiesEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: TopEntitiesProvider.Entry
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall: TopEntitiesWidgetEntryViewSmall(entry: entry)
        default: TopEntitiesWidgetEntryViewLarge(entry: entry)
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
    return getLinkUrl("album", queryItems: [URLQueryItem(name: "name", value: album.name), URLQueryItem(name: "artist", value: album.artist.name)])
}

func getLinkUrl(_ path: String, queryItems: [URLQueryItem]? = nil) -> URL {
    var components = URLComponents()
    components.scheme = "finale"
    components.path = "/\(path)"
    components.queryItems = queryItems
    return components.url!
}

struct TopEntitiesWidgetEntryViewSmall : View {
    var entry: TopEntitiesProvider.Entry
    
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

struct TopEntitiesWidgetEntryViewLarge : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: TopEntitiesProvider.Entry
    
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
                    HStack(alignment: .center) {
                        Link(destination: getLinkUrl("scrobbleOnce")) {
                            Image(systemName: "plus")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .foregroundColor(Color("AccentColor"))
                        }
                        Link(destination: getLinkUrl("scrobbleContinuously")) {
                            Image(systemName: "infinity")
                            .resizable()
                            .frame(width: 20, height: 10)
                            .foregroundColor(Color("AccentColor"))
                        }
                        Image(uiImage: UIImage(named: "FinaleIconWhite")!)
                            .resizable()
                            .frame(width: 15, height: 15)
                            .colorMultiply(Color("AccentColor"))
                    }
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

struct TopEntitiesWidget: Widget {
    let kind: String = "TopEntitiesWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: TopEntitiesConfigurationIntent.self, provider: TopEntitiesProvider()) { entry in
            TopEntitiesEntryView(entry: entry)
        }
        .configurationDisplayName("Top Albums")
        .description("Your top albums for a given period.")
    }
}

struct TopEntitiesWidget_Previews: PreviewProvider {
    static var previews: some View {
        TopEntitiesEntryView(entry: TopEntitiesEntry(date: Date(), albums: [LTopAlbumsResponseAlbum.fake], configuration: TopEntitiesConfigurationIntent()))
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
