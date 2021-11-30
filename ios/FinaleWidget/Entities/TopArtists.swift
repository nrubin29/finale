struct LTopArtistsResponse: Codable {
    let topartists: LTopArtistsResponseTopArtists
}

struct LTopArtistsResponseTopArtists: Codable {
    let artist: [LTopArtistsResponseArtist]
    let attr: LAttr
    
    enum CodingKeys : String, CodingKey {
        case artist
        case attr = "@attr"
    }
}

struct LTopArtistsResponseArtist: Codable, Identifiable {
    let name: String
    let playcount: String
    let url: String
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
