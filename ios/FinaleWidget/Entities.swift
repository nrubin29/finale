import Foundation

let numberFormatter: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    return numberFormatter
}()

@available(iOS 12.0, *)
extension Period {
    var apiValue: String {
        get {
            switch self {
            case .overall: return "overall"
            case .sevenDay: return "7day"
            case .oneMonth: return "1month"
            case .threeMonth: return "3month"
            case .sixMonth: return "6month"
            case .twelveMonth: return "12month"
            case .unknown: fallthrough
            @unknown default: return "overall"
            }
        }
    }
    
    var displayName: String {
        get {
            switch self {
            case .overall: return "All Time"
            case .sevenDay: return "7 Days"
            case .oneMonth: return "1 Month"
            case .threeMonth: return "3 Months"
            case .sixMonth: return "6 Months"
            case .twelveMonth: return "12 Months"
            case .unknown: fallthrough
            @unknown default: return "All Time"
            }
        }
    }
}

struct LImage : Codable {
    let url: String
    let size: String
    
    enum CodingKeys : String, CodingKey {
        case url = "#text"
        case size
    }
}

// MARK: LTopAlbumsResponse

struct LTopAlbumsResponse: Codable {
    let topalbums: LTopAlbumsResponseTopAlbums
}

struct LTopAlbumsResponseTopAlbums: Codable {
    let album: [LTopAlbumsResponseAlbum]
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
