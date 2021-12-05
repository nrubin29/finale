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
    let image: [LImage]?
    
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
    
    var images: [LImage] {
        get {
            return image ?? []
        }
    }
}

struct LTopTracksResponseTrackArtist : Codable {
    let name: String
    let url: String
}
