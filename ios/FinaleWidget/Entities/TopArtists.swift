import Foundation
import SwiftSoup

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
    private let image: [LImage]?
    var imageUrl: String?
    
    var type: EntityType {
        get {
            return .artist
        }
    }
    
    var value: String {
        get {
            formatScrobbles(playcount)
        }
    }
    
    func fetchImageUrl(callback: @escaping (String?) -> Void) {
        let task = URLSession.shared.dataTask(with: URL(string: url)!) { data, urlResponse, err in
            if let data = data, let html = String(data: data, encoding: .utf8), let doc = try? SwiftSoup.parse(html), let href = try? doc.select(".header-new-gallery--link").attr("href"), let slashIndex = href.lastIndex(of: "/") {
                let imageId = href[href.index(slashIndex, offsetBy: 1)...]
                callback("https://lastfm.freetls.fastly.net/i/u/300x300/\(imageId).jpg")
            } else {
                callback(nil)
            }
        }
        
        task.resume()
    }
}
