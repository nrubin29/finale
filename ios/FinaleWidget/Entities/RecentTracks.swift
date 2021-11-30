struct LRecentTracksResponse : Codable {
    let recenttracks: LRecentTracksResponseRecentTracks
}

struct LRecentTracksResponseRecentTracks : Codable {
    let track: [LRecentTracksResponseTrack]
    let attr: LAttr
    
    enum CodingKeys : String, CodingKey {
        case track
        case attr = "@attr"
    }
}

struct LRecentTracksResponseTrack : Codable, Identifiable {
    let name: String
    let url: String
    let image: [LImage]?
    let artist: LRecentTracksResponseTrackArtist
    let album: LRecentTracksResponseTrackAlbum
    let date: LRecentTracksResponseTrackDate?
    
    var images: [LImage] {
        get {
            return image ?? []
        }
    }
    
    var id: String {
        get {
            return url
        }
    }
}

struct LRecentTracksResponseTrackArtist : Codable {
    let name: String
    
    enum CodingKeys : String, CodingKey {
        case name = "#text"
    }
}

struct LRecentTracksResponseTrackAlbum : Codable {
    let title: String
    
    enum CodingKeys : String, CodingKey {
        case title = "#text"
    }
}

struct LRecentTracksResponseTrackDate : Codable {
    let uts: String
    let text: String
    
    enum CodingKeys : String, CodingKey {
        case uts
        case text = "#text"
    }
}
