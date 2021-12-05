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
    
    static let fake = LTopAlbumsResponseAlbum(name: "Album", playcount: "0", url: "", artist: LTopAlbumsResponseAlbumArtist(name: "Artist", url: ""), image: [LImage(url: "https://lastfm.freetls.fastly.net/i/u/avatar300s/c6f59c1e5e7240a4c0d427abd71f3dbb.jpg", size: "")])
}

struct LTopAlbumsResponseAlbumArtist : Codable {
    let name: String
    let url: String
}
