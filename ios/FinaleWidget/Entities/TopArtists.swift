struct LTopArtistsResponse : LastfmApiResponseWrapper {
    let response: LTopArtistsResponseTopArtists
    
    enum CodingKeys : String, CodingKey {
        case response = "topartists"
    }
}

struct LTopArtistsResponseTopArtists : LastfmApiResponse {
    let entities: [LTopArtistsResponseArtist]
    let attr: LAttr
    
    enum CodingKeys : String, CodingKey {
        case entities = "artist"
        case attr = "@attr"
    }
}

struct LTopArtistsResponseArtist : Entity {
    let name: String
    let playcount: String
    let url: String
    let image: [LImage]?
    
    var value: String {
        get {
            formatScrobbles(playcount)
        }
    }
    
    var images: [LImage] {
        get {
            return image ?? []
        }
    }
}
