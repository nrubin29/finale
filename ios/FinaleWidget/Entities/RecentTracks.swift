struct LRecentTracksResponse : LastfmApiResponseWrapper {
    let response: LRecentTracksResponseRecentTracks
    
    enum CodingKeys : String, CodingKey {
        case response = "recenttracks"
    }
}

struct LRecentTracksResponseRecentTracks : LastfmApiResponse {
    let entities: [LRecentTracksResponseTrack]
    let attr: LAttr
    
    enum CodingKeys : String, CodingKey {
        case entities = "track"
        case attr = "@attr"
    }
}

struct LRecentTracksResponseTrack : Entity {
    let name: String
    let url: String
    let artist: LRecentTracksResponseTrackArtist
    let album: LRecentTracksResponseTrackAlbum
    let date: LRecentTracksResponseTrackDate?
    
    var type: EntityType {
        get {
            return .track
        }
    }
    
    var value: String {
        get {
            return date?.text ?? "Scrobbling now"
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
