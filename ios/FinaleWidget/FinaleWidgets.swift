import SwiftUI

@available(iOS 14.0, *)
@main
struct FinaleWidgets: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        TopEntitiesWidget()
        StatisticsWidget()
    }
}

func getLinkUrl(_ path: String, queryItems: [URLQueryItem]? = nil) -> URL {
    var components = URLComponents()
    components.scheme = "finale"
    components.path = "/\(path)"
    components.queryItems = queryItems
    return components.url!
}
