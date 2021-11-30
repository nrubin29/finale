import CryptoKit
import Foundation

@available(iOS 13.0, *)
class Lastfm {
    private static func buildUrl(_ method: String, _ data: [String: Any]) -> URL {
        var allData = data.merging(["api_key": Env.apiKey, "method": method]) { (a, _) in return a }
        let hash = allData.keys.sorted().map({"\($0)\(allData[$0]!)"}).joined() + Env.apiSecret
        let signature = Insecure.MD5.hash(data: hash.data(using: .utf8)!).map { String(format: "%02hhx", $0) }.joined()
        allData["api_sig"] = signature
        allData["format"] = "json"
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "ws.audioscrobbler.com"
        components.path = "/2.0"
        components.queryItems = allData.map({URLQueryItem(name: $0, value: String(describing: $1))})
        return components.url!
    }
    
    fileprivate static func doRequest<T : Codable>(method: String, data: [String: Any], post: Bool = false, callback: @escaping (T?) -> Void) {
        let url = buildUrl(method, data)
        var request = URLRequest(url: url)
        
        if post {
            request.httpMethod = "post"
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, urlResponse, err in
            if let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                
                do {
                    let obj = try decoder.decode(T.self, from: data)
                    callback(obj)
                }
                
                catch {
                    print(error)
                    callback(nil)
                }
            }
        }
        
        task.resume()
    }
}

@available(iOS 13.0, *)
class GetRecentTracksRequest: LastfmAPIRequest {
    var username: String
    var period: Period
    
    init(username: String, period: Period) {
        self.username = username
        self.period = period
    }
    
    func doRequest(limit: Int, page: Int, callback: @escaping ([LRecentTracksResponseTrack]?) -> Void) {
        Lastfm.doRequest(method: "user.getRecentTracks", data: ["user": username, "period": period.apiValue, "limit": limit, "page": page]) { (recentTracksResponse: LRecentTracksResponse?) in callback(recentTracksResponse?.recenttracks.track) }
    }
    
    func getTotalCount(callback: @escaping (Int?) -> Void) {
        Lastfm.doRequest(method: "user.getRecentTracks", data: ["user": username, "period": period.apiValue, "limit": 1, "page": 1]) { (recentTracksResponse: LRecentTracksResponse?) in
            if let recentTracksResponse = recentTracksResponse {
                callback(Int(recentTracksResponse.recenttracks.attr.total))
            } else {
                callback(nil)
            }
        }
    }
}

@available(iOS 13.0, *)
class GetTopTracksRequest: LastfmAPIRequest {
    var username: String
    var period: Period
    
    init(username: String, period: Period) {
        self.username = username
        self.period = period
    }
    
    func doRequest(limit: Int, page: Int, callback: @escaping ([LTopTracksResponseTrack]?) -> Void) {
        Lastfm.doRequest(method: "user.getTopTracks", data: ["user": username, "period": period.apiValue, "limit": limit, "page": page]) { (topTracksResponse: LTopTracksResponse?) in callback(topTracksResponse?.toptracks.track) }
    }
    
    func getTotalCount(callback: @escaping (Int?) -> Void) {
        Lastfm.doRequest(method: "user.getTopTracks", data: ["user": username, "period": period.apiValue, "limit": 1, "page": 1]) { (topTracksResponse: LTopTracksResponse?) in
            if let topTracksResponse = topTracksResponse {
                callback(Int(topTracksResponse.toptracks.attr.total))
            } else {
                callback(nil)
            }
        }
    }
}

@available(iOS 13.0, *)
class GetTopArtistsRequest: LastfmAPIRequest {
    var username: String
    var period: Period
    
    init(username: String, period: Period) {
        self.username = username
        self.period = period
    }
    
    func doRequest(limit: Int, page: Int, callback: @escaping ([LTopArtistsResponseArtist]?) -> Void) {
        Lastfm.doRequest(method: "user.getTopArtists", data: ["user": username, "period": period.apiValue, "limit": limit, "page": page]) { (topArtistsResponse: LTopArtistsResponse?) in callback(topArtistsResponse?.topartists.artist) }
    }
    
    func getTotalCount(callback: @escaping (Int?) -> Void) {
        Lastfm.doRequest(method: "user.getTopArtists", data: ["user": username, "period": period.apiValue, "limit": 1, "page": 1]) { (topArtistsResponse: LTopArtistsResponse?) in
            if let topArtistsResponse = topArtistsResponse {
                callback(Int(topArtistsResponse.topartists.attr.total))
            } else {
                callback(nil)
            }
        }
    }
}

@available(iOS 13.0, *)
class GetTopAlbumsRequest: LastfmAPIRequest {
    var username: String
    var period: Period
    
    init(username: String, period: Period) {
        self.username = username
        self.period = period
    }
    
    func doRequest(limit: Int, page: Int, callback: @escaping ([LTopAlbumsResponseAlbum]?) -> Void) {
        Lastfm.doRequest(method: "user.getTopAlbums", data: ["user": username, "period": period.apiValue, "limit": limit, "page": page]) { (topAlbumsResponse: LTopAlbumsResponse?) in callback(topAlbumsResponse?.topalbums.album) }
    }
    
    func getTotalCount(callback: @escaping (Int?) -> Void) {
        Lastfm.doRequest(method: "user.getTopAlbums", data: ["user": username, "period": period.apiValue, "limit": 1, "page": 1]) { (topAlbumsResponse: LTopAlbumsResponse?) in
            if let topAlbumsResponse = topAlbumsResponse {
                callback(Int(topAlbumsResponse.topalbums.attr.total))
            } else {
                callback(nil)
            }
        }
    }
}

protocol LastfmAPIRequest {
    associatedtype T
    
    func doRequest(limit: Int, page: Int, callback: @escaping ([T]?) -> Void) -> Void
    
    func getTotalCount(callback: @escaping (Int?) -> Void) -> Void
}
