import WidgetKit
import SwiftUI
import Intents

struct StatisticsProvider: IntentTimelineProvider {
    private func createEntry(for configuration: StatisticsConfigurationIntent, in context: Context, completion: @escaping (StatisticsEntry) -> Void) {
        guard let username = configuration.username, !username.isEmpty else {
            completion(StatisticsEntry(date: Date(), numScrobbles: nil, numTracks: nil, numArtists: nil, numAlbums: nil, configuration: configuration, isPreview: context.isPreview))
            return
        }
        
        var numScrobbles: Int?
        var numTracks: Int?
        var numArtists: Int?
        var numAlbums: Int?
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        GetRecentTracksRequest(username: username, period: configuration.period).getTotalCount { count in
            numScrobbles = count
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        GetTopTracksRequest(username: username, period: configuration.period).getTotalCount { count in
            numTracks = count
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        GetTopArtistsRequest(username: username, period: configuration.period).getTotalCount { count in
            numArtists = count
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        GetTopAlbumsRequest(username: username, period: configuration.period).getTotalCount { count in
            numAlbums = count
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(StatisticsEntry(date: Date(), numScrobbles: numScrobbles, numTracks: numTracks, numArtists: numArtists, numAlbums: numAlbums, configuration: configuration, isPreview: context.isPreview))
        }
    }
    
    func placeholder(in context: Context) -> StatisticsEntry {
        StatisticsEntry(date: Date(), numScrobbles: 0, numTracks: 0, numArtists: 0, numAlbums: 0, configuration: StatisticsConfigurationIntent(), isPreview: context.isPreview)
    }
    
    func getSnapshot(for configuration: StatisticsConfigurationIntent, in context: Context, completion: @escaping (StatisticsEntry) -> ()) {
        createEntry(for: configuration, in: context, completion: completion)
    }
    
    func getTimeline(for configuration: StatisticsConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        createEntry(for: configuration, in: context) { entry in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}

struct StatisticsEntry: TimelineEntry {
    let date: Date
    let numScrobbles: Int?
    let numTracks: Int?
    let numArtists: Int?
    let numAlbums: Int?
    let configuration: StatisticsConfigurationIntent
    let isPreview: Bool
}

private func getScoreTiles(_ entry: StatisticsProvider.Entry) -> [ScoreTileModel] {
    return [
        ScoreTileModel(title: "Scrobbles", value: entry.numScrobbles, icon: "PlaylistIcon", link: "scrobble"),
        ScoreTileModel(title: "Artists", value: entry.numArtists, icon: "ArtistIcon", link: "artist"),
        ScoreTileModel(title: "Albums", value: entry.numAlbums, icon: "AlbumIcon", link: "album"),
        ScoreTileModel(title: "Tracks", value: entry.numTracks, icon: "MusicNoteIcon", link: "track"),
    ]
}

struct StatisticsEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: StatisticsProvider.Entry
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall: StatisticsWidgetEntryViewSmall(entry: entry)
        default: StatisticsWidgetEntryViewLarge(entry: entry)
        }
    }
}

struct StatisticsWidgetEntryViewSmall : View {
    var entry: StatisticsProvider.Entry
    
    var body: some View {
        FinaleWidget(themeColor: entry.configuration.themeColor) {
            if !entry.isPreview && entry.configuration.username?.isEmpty ?? true {
                VStack {
                    Image("FinaleIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .colorMultiply(entry.configuration.themeColor.accent)
                    Text("Please enter your username in the widget settings.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(entry.configuration.themeColor.accent)
                }
                .padding()
            } else {
                Scoreboard(themeColor: entry.configuration.themeColor, alignment: .vertical, tiles: getScoreTiles(entry))
                    .padding()
            }
        }
    }
}

struct StatisticsWidgetEntryViewLarge : View {
    var entry: StatisticsProvider.Entry
    
    var body: some View {
        FinaleWidgetLarge(title: "Last.fm Stats", period: entry.configuration.period, username: entry.configuration.username, themeColor: entry.configuration.themeColor, isPreview: entry.isPreview) {
            Scoreboard(themeColor: entry.configuration.themeColor, alignment: .horizontal, tiles: getScoreTiles(entry))
        }
    }
}

@available(iOS 15.0, *)
struct StatisticsWidget: Widget {
    let kind: String = "StatisticsWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: StatisticsConfigurationIntent.self, provider: StatisticsProvider()) { entry in
            StatisticsEntryView(entry: entry)
        }
        .configurationDisplayName("Statistics")
        .description("Your statistics for a given period.")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}

struct StatisticsWidget_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsEntryView(entry: StatisticsEntry(date: Date(), numScrobbles: 0, numTracks: 0, numArtists: 0, numAlbums: 0, configuration: StatisticsConfigurationIntent(), isPreview: true))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
