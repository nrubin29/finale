import Foundation

let numberFormatter: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    return numberFormatter
}()

func formatScrobbles(_ value: String) -> String {
    let playCount = Int(value)!
    let scrobbles = playCount == 1 ? "scrobble" : "scrobbles"
    return "\(numberFormatter.string(from: NSNumber(value: playCount))!) \(scrobbles)"
}

protocol Entity : Codable {
    var type: EntityType { get }
    var name: String { get }
    var subtitle: String? { get }
    var value: String { get }
    var url: String { get }
    var imageUrl: String? { get }
    func fetchImageUrl(callback: @escaping (String?) -> Void)
}

extension Entity {
    var subtitle: String? {
        get {
            return nil
        }
    }
    
    var imageUrl: String? {
        get {
            return nil
        }
    }
    
    func fetchImageUrl(callback: @escaping (String?) -> Void) {
        callback(imageUrl)
    }
}

extension EntityType {
    var displayName: String {
        get {
            switch self {
            case .track: return "Tracks"
            case .artist: return "Artists"
            case .album: return "Albums"
            case .unknown: fallthrough
            @unknown default: return "Charts"
            }
        }
    }
}

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

struct LAttr : Codable {
    let page: String
    let total: String
    let user: String
    let perPage: String
    let totalPages: String
}
