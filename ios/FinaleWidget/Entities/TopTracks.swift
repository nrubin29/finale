struct LTopTracksResponse : LastfmApiResponseWrapper {
    let response: LTopTracksResponseTopTracks
    
    enum CodingKeys : String, CodingKey {
        case response = "toptracks"
    }
}

struct LTopTracksResponseTopTracks : LastfmApiResponse {
    let entities: [LTopTracksResponseTrack]
    let attr: LAttr
    
    enum CodingKeys : String, CodingKey {
        case entities = "track"
        case attr = "@attr"
    }
}

struct LTopTracksResponseTrack : Entity {
    let name: String
    let playcount: String
    let url: String
    let artist: LTopTracksResponseTrackArtist
    
    var type: EntityType {
        get {
            return .track
        }
    }
    
    var subtitle: String? {
        get {
            return artist.name
        }
    }
    
    var value: String {
        get {
            return formatScrobbles(playcount)
        }
    }
    
    func fetchImageUrl(callback: @escaping (String?) -> Void) {
        Lastfm.getFullTrack(from: self) { track in
            callback(track?.album?.image.last?.url)
        }
    }
}

struct LTopTracksResponseTrackArtist : Codable {
    let name: String
    let url: String
}
