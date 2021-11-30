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

struct LAttr: Codable {
    var page: String
    var total: String
    var user: String
    var perPage: String
    var totalPages: String
}
