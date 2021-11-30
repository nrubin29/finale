import WidgetKit
import SwiftUI
import Intents

struct StatisticsProvider: IntentTimelineProvider {
    private func createEntry(for configuration: StatisticsConfigurationIntent, in context: Context, completion: @escaping (StatisticsEntry) -> Void) {
        if configuration.username == nil || configuration.username!.isEmpty {
            completion(StatisticsEntry(date: Date(), numScrobbles: nil, numTracks: nil, numArtists: nil, numAlbums: nil, configuration: configuration))
            return
        }
        
        var numScrobbles: Int?
        var numTracks: Int?
        var numArtists: Int?
        var numAlbums: Int?
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        GetRecentTracksRequest(username: configuration.username!, period: configuration.period).getTotalCount { response in
            numScrobbles = response
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        GetTopTracksRequest(username: configuration.username!, period: configuration.period).getTotalCount { response in
            numTracks = response
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        GetTopArtistsRequest(username: configuration.username!, period: configuration.period).getTotalCount { response in
            numArtists = response
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        GetTopAlbumsRequest(username: configuration.username!, period: configuration.period).getTotalCount { response in
            numAlbums = response
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(StatisticsEntry(date: Date(), numScrobbles: numScrobbles, numTracks: numTracks, numArtists: numArtists, numAlbums: numAlbums, configuration: configuration))
        }
    }
    
    func placeholder(in context: Context) -> StatisticsEntry {
        StatisticsEntry(date: Date(), numScrobbles: 0, numTracks: 0, numArtists: 0, numAlbums: 0, configuration: StatisticsConfigurationIntent())
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
}

struct StatisticsEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: StatisticsProvider.Entry
    
    @ViewBuilder
    var body: some View {
        switch family {
        default: StatisticsWidgetEntryViewLarge(entry: entry)
        }
    }
}

struct StatisticsWidgetEntryViewLarge : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: StatisticsProvider.Entry
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color("WidgetBackgroundStart"), Color("WidgetBackgroundEnd")]), startPoint: .top, endPoint: .bottom)
            VStack(alignment: .leading) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Last.fm Statistics")
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
                } else {
                    HStack {
                        VStack {
                            Text(entry.numScrobbles != nil ? numberFormatter.string(from: NSNumber(value: entry.numScrobbles!))! : "---")
                                .foregroundColor(Color("AccentColor"))
                                .bold()
                            Text("Scrobbles")
                                .foregroundColor(Color("AccentColor"))
                                .bold()
                        }
                        VStack {
                            Text(entry.numAlbums != nil ? numberFormatter.string(from: NSNumber(value: entry.numAlbums!))! : "---")
                                .foregroundColor(Color("AccentColor"))
                                .bold()
                            Text("Albums")
                                .foregroundColor(Color("AccentColor"))
                                .bold()
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct StatisticsWidget: Widget {
    let kind: String = "StatisticsWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: StatisticsConfigurationIntent.self, provider: StatisticsProvider()) { entry in
            StatisticsEntryView(entry: entry)
        }
        .configurationDisplayName("Statistics")
        .description("Your statistics for a given period.")
        .supportedFamilies([.systemMedium])
    }
}

struct StatisticsWidget_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsEntryView(entry: StatisticsEntry(date: Date(), numScrobbles: 0, numTracks: 0, numArtists: 0, numAlbums: 0, configuration: StatisticsConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
