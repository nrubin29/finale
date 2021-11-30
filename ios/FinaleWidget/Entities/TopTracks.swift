struct LTopTracksResponse: Codable {
    let toptracks: LTopTracksResponseTopTracks
}

struct LTopTracksResponseTopTracks: Codable {
    let track: [LTopTracksResponseTrack]
    let attr: LAttr
    
    enum CodingKeys : String, CodingKey {
        case track
        case attr = "@attr"
    }
}

struct LTopTracksResponseTrack: Codable, Identifiable {
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

struct LTopTracksResponseTrackArtist: Codable {
    var name: String
    var url: String
}
