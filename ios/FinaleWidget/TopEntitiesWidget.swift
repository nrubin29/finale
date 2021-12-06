import WidgetKit
import SwiftUI
import Intents

struct TopEntitiesProvider: IntentTimelineProvider {
    private func createEntry(for configuration: TopEntitiesConfigurationIntent, in context: Context, completion: @escaping (TopEntitiesEntry) -> Void) {
        guard let username = configuration.username, !username.isEmpty else {
            completion(TopEntitiesEntry(date: Date(), entities: [], configuration: configuration, isPreview: context.isPreview))
            return
        }
        
        switch configuration.type {
        case .track: GetTopTracksRequest(username: username, period: configuration.period).getEntities(limit: context.family.numItemsToDisplay, page: 1) { entities in
            var imageUrls: [String : String?] = [:]
            let dispatchGroup = DispatchGroup()
            
            for entity in entities ?? [] {
                dispatchGroup.enter()
                entity.fetchImageUrl { result in
                    imageUrls[entity.url] = result
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(TopEntitiesEntry(date: Date(), entities: entities ?? [], imageUrlMap: imageUrls, configuration: configuration, isPreview: context.isPreview))
            }
        }
        case .artist: GetTopArtistsRequest(username: username, period: configuration.period).getEntities(limit: context.family.numItemsToDisplay, page: 1) { entities in
            var imageUrls: [String : String?] = [:]
            let dispatchGroup = DispatchGroup()
            
            for entity in entities ?? [] {
                dispatchGroup.enter()
                entity.fetchImageUrl { result in
                    imageUrls[entity.url] = result
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(TopEntitiesEntry(date: Date(), entities: entities ?? [], imageUrlMap: imageUrls, configuration: configuration, isPreview: context.isPreview))
            }
        }
        case .unknown: fallthrough
        case .album: GetTopAlbumsRequest(username: username, period: configuration.period).getEntities(limit: context.family.numItemsToDisplay, page: 1) { entities in
            completion(TopEntitiesEntry(date: Date(), entities: entities ?? [], configuration: configuration, isPreview: context.isPreview))
        }
        default: fatalError("Unknown entity type \(configuration.type)")
        }
    }
    
    func placeholder(in context: Context) -> TopEntitiesEntry {
        let entities = (0..<context.family.numItemsToDisplay).map({ i in LTopAlbumsResponseAlbum.fake(id: i) })
        return TopEntitiesEntry(date: Date(), entities: entities, configuration: TopEntitiesConfigurationIntent(), isPreview: context.isPreview)
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

struct TopEntitiesEntry : TimelineEntry {
    let date: Date
    let entities: [Entity]
    // Map from entity URL (unique value) to entity image URL
    var imageUrlMap: [String : String?]? = nil
    let configuration: TopEntitiesConfigurationIntent
    let isPreview: Bool
    
    var imageUrls: [String : String?] {
        get {
            return imageUrlMap ?? .init(uniqueKeysWithValues: entities.map { ($0.url, $0.imageUrl) })
        }
    }
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

private func getLinkUrl(_ entity: Entity) -> URL {
    if let track = entity as? LTopTracksResponseTrack {
        return getLinkUrl("track", queryItems: [URLQueryItem(name: "name", value: track.name), URLQueryItem(name: "artist", value: track.artist.name)])
    } else if let album = entity as? LTopAlbumsResponseAlbum {
        return getLinkUrl("album", queryItems: [URLQueryItem(name: "name", value: album.name), URLQueryItem(name: "artist", value: album.artist.name)])
    } else if let artist = entity as? LTopArtistsResponseArtist {
        return getLinkUrl("artist", queryItems: [URLQueryItem(name: "name", value: artist.name)])
    }
    
    fatalError("Unknown entity type for getLinkUrl(): \(entity)")
}

struct TopEntitiesWidgetEntryViewSmall : View {
    var entry: TopEntitiesProvider.Entry
    
    var entity: Entity? {
        get {
            if entry.isPreview {
                return LTopAlbumsResponseAlbum.fake()
            } else {
                return entry.entities.first
            }
        }
    }
    
    var imageUrl: String? {
        get {
            if let entity = entity, let imageUrl = entry.imageUrls[entity.url] {
                return imageUrl
            } else {
                return nil
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            EntityImage(imageUrl: imageUrl, entityType: entity?.type, size: .large)
                .aspectRatio(contentMode: .fit)
            if (entry.configuration.showTitles ?? 1) == 1 {
                imageForegroundGradient
            }
            VStack {
                Spacer()
                VStack(alignment: .leading) {
                    if !entry.isPreview && entry.configuration.username == nil {
                        Text("Please enter your username in the widget settings.")
                            .bold()
                            .foregroundColor(.white)
                            .font(.subheadline)
                    } else if let entity = entity {
                        if (entry.configuration.showTitles ?? 1) == 1 {
                            Text(entity.name)
                                .bold()
                                .foregroundColor(.white)
                                .font(.subheadline)
                            if let subtitle = entity.subtitle {
                                Text(subtitle)
                                    .foregroundColor(.white)
                                    .font(.footnote)
                            }
                            Text(entity.value)
                                .foregroundColor(.white)
                                .font(.footnote)
                        }
                    } else {
                        Text("You haven't scrobbled any \(entry.configuration.type.displayName.lowercased()) in this period.")
                            .bold()
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }
                }
                .padding()
            }
        }
        .widgetURL(entity != nil ? getLinkUrl(entity!) : nil)
    }
}

struct TopEntitiesWidgetEntryViewLarge : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: TopEntitiesProvider.Entry
    
    var entities: [Entity] {
        get {
            if entry.isPreview {
                return (0..<family.numItemsToDisplay).map({ i in LTopAlbumsResponseAlbum.fake(id: i) })
            } else {
                return entry.entities
            }
        }
    }
    
    private func unnest<T>(_ optional: T??) -> T? {
        if let inner = optional {
            return inner
        } else {
            return nil
        }
    }
    
    var body: some View {
        FinaleWidgetLarge(title: "Top \(entry.configuration.type.displayName)", period: entry.configuration.period, username: entry.configuration.username, isPreview: entry.isPreview) {
            if !entities.isEmpty {
                LazyVGrid(columns: (0..<family.numColumns).map({_ in GridItem(.flexible())})) {
                    ForEach(entities, id: \.url) { entity in
                        Link(destination: getLinkUrl(entity)) {
                            VStack {
                                ZStack(alignment: .bottom) {
                                    EntityImage(imageUrl: unnest(entry.imageUrls[entity.url]), entityType: entity.type, size: .small)
                                        .aspectRatio(contentMode: .fill)
                                    if (entry.configuration.showTitles ?? 1) == 1 {
                                        imageForegroundGradient
                                        Text(entity.name)
                                            .font(Font.system(size: 8))
                                            .foregroundColor(.white)
                                            .bold()
                                            .multilineTextAlignment(.center)
                                            .padding(2)
                                    }
                                }
                                .mask(RoundedRectangle(cornerRadius: 5))
                                Text(entity.value)
                                    .font(Font.system(size: 8))
                                    .foregroundColor(Color("AccentColor"))
                                    .bold()
                            }
                        }
                    }
                }
            } else {
                Text("You haven't scrobbled any \(entry.configuration.type.displayName.lowercased()) in this period.")
                    .foregroundColor(Color("AccentColor"))
            }
        }
    }
}

struct TopEntitiesWidget: Widget {
    let kind: String = "TopEntitiesWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: TopEntitiesConfigurationIntent.self, provider: TopEntitiesProvider()) { entry in
            TopEntitiesEntryView(entry: entry)
        }
        .configurationDisplayName("Top Charts")
        .description("Your top albums, artists, or tracks for a given period.")
    }
}

struct TopEntitiesWidget_Previews: PreviewProvider {
    static var previews: some View {
        TopEntitiesEntryView(entry: TopEntitiesEntry(date: Date(), entities: [LTopAlbumsResponseAlbum.fake()], configuration: TopEntitiesConfigurationIntent(), isPreview: true))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

private extension WidgetFamily {
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
