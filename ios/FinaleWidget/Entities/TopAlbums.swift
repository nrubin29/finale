import Foundation

struct LTopAlbumsResponse: Codable {
    let topalbums: LTopAlbumsResponseTopAlbums
}

struct LTopAlbumsResponseTopAlbums: Codable {
    let album: [LTopAlbumsResponseAlbum]
    let attr: LAttr
    
    enum CodingKeys: String, CodingKey {
        case album
        case attr = "@attr"
    }
}

struct LTopAlbumsResponseAlbum: Codable, Identifiable {
    let name: String
    let playcount: String
    let url: String
    let artist: LTopAlbumsResponseAlbumArtist
    let image: [LImage]?
    
    var images: [LImage] {
        get {
            return image ?? []
        }
    }
    
    var playCountFormatted: String {
        get {
            let playCount = Int(playcount)!
            let scrobbles = playCount == 1 ? "scrobble" : "scrobbles"
            return "\(numberFormatter.string(from: NSNumber(value: playCount))!) \(scrobbles)"
        }
    }
    
    var id: String {
        get {
            return url
        }
    }
    
    static let fake = LTopAlbumsResponseAlbum(name: "Album", playcount: "0", url: "", artist: LTopAlbumsResponseAlbumArtist(name: "Artist", url: ""), image: [LImage(url: "https://lastfm.freetls.fastly.net/i/u/avatar300s/c6f59c1e5e7240a4c0d427abd71f3dbb.jpg", size: "")])
}

struct LTopAlbumsResponseAlbumArtist: Codable {
    var name: String
    var url: String
}
