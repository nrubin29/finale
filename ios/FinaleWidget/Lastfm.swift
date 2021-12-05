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
    
    static func getFullTrack(from simpleTrack: LTopTracksResponseTrack, callback: @escaping (LTrack?) -> Void) {
        doRequest(method: "track.getInfo", data: ["track": simpleTrack.name, "artist": simpleTrack.artist.name]) { (trackResponse: LTrackInfoResponse?) in
            callback(trackResponse?.track)
        }
    }
}

@available(iOS 13.0, *)
class GetRecentTracksRequest: LastfmApiRequest {
    var username: String
    var period: Period
    
    init(username: String, period: Period) {
        self.username = username
        self.period = period
    }
    
    func doRequest(limit: Int, page: Int, callback: @escaping (LRecentTracksResponse?) -> Void) {
        Lastfm.doRequest(method: "user.getRecentTracks", data: ["user": username, "period": period.apiValue, "limit": limit, "page": page], callback: callback)
    }
}

@available(iOS 13.0, *)
class GetTopTracksRequest: LastfmApiRequest {
    var username: String
    var period: Period
    
    init(username: String, period: Period) {
        self.username = username
        self.period = period
    }
    
    func doRequest(limit: Int, page: Int, callback: @escaping (LTopTracksResponse?) -> Void) {
        Lastfm.doRequest(method: "user.getTopTracks", data: ["user": username, "period": period.apiValue, "limit": limit, "page": page], callback: callback)
    }
}

@available(iOS 13.0, *)
class GetTopArtistsRequest: LastfmApiRequest {
    var username: String
    var period: Period
    
    init(username: String, period: Period) {
        self.username = username
        self.period = period
    }
    
    func doRequest(limit: Int, page: Int, callback: @escaping (LTopArtistsResponse?) -> Void) {
        Lastfm.doRequest(method: "user.getTopArtists", data: ["user": username, "period": period.apiValue, "limit": limit, "page": page], callback: callback)
    }
}

@available(iOS 13.0, *)
class GetTopAlbumsRequest: LastfmApiRequest {
    var username: String
    var period: Period
    
    init(username: String, period: Period) {
        self.username = username
        self.period = period
    }
    
    func doRequest(limit: Int, page: Int, callback: @escaping (LTopAlbumsResponse?) -> Void) {
        Lastfm.doRequest(method: "user.getTopAlbums", data: ["user": username, "period": period.apiValue, "limit": limit, "page": page], callback: callback)
    }
}

protocol LastfmApiRequest {
    associatedtype ResponseWrapper: LastfmApiResponseWrapper
    
    func doRequest(limit: Int, page: Int, callback: @escaping (ResponseWrapper?) -> Void) -> Void
}

extension LastfmApiRequest {
    func getEntities(limit: Int, page: Int, callback: @escaping ([ResponseWrapper.Response.E]?) -> Void) -> Void {
        doRequest(limit: limit, page: page) { wrapper in
            callback(wrapper?.response.entities)
        }
    }
    
    func getTotalCount(callback: @escaping (Int?) -> Void) -> Void {
        doRequest(limit: 1, page: 1) { wrapper in
            if let wrapper = wrapper {
                callback(Int(wrapper.response.attr.total))
            } else {
                callback(nil)
            }
        }
    }
}

protocol LastfmApiResponseWrapper : Codable {
    associatedtype Response : LastfmApiResponse
    
    var response: Response { get }
}

protocol LastfmApiResponse : Codable {
    associatedtype E : Entity
    
    var entities: [E] { get }
    var attr: LAttr { get }
}
