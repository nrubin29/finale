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

struct LTopTracksResponseTrackArtist : Codable {
    let name: String
    let url: String
}
