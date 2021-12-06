import Foundation

struct LTopAlbumsResponse : LastfmApiResponseWrapper {
    let response: LTopAlbumsResponseTopAlbums
    
    enum CodingKeys: String, CodingKey {
        case response = "topalbums"
    }
}

struct LTopAlbumsResponseTopAlbums : LastfmApiResponse {
    let entities: [LTopAlbumsResponseAlbum]
    let attr: LAttr
    
    enum CodingKeys: String, CodingKey {
        case entities = "album"
        case attr = "@attr"
    }
}

struct LTopAlbumsResponseAlbum : Entity {
    let name: String
    let playcount: String
    let url: String
    let artist: LTopAlbumsResponseAlbumArtist
    let image: [LImage]?
    
    var type: EntityType {
        get {
            return .album
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
    
    var imageUrl: String? {
        get {
            return image?.last?.url
        }
    }
    
    static func fake(id: Int? = nil) -> LTopAlbumsResponseAlbum {
        return LTopAlbumsResponseAlbum(name: "Album", playcount: "0", url: id != nil ? "\(id!)" : "", artist: LTopAlbumsResponseAlbumArtist(name: "Artist", url: ""), image: nil)
    }
}

struct LTopAlbumsResponseAlbumArtist : Codable {
    let name: String
    let url: String
}
