import SwiftUI

let widgetBackgroundGradient = LinearGradient(gradient: Gradient(colors: [Color("WidgetBackgroundStart"), Color("WidgetBackgroundEnd")]), startPoint: .top, endPoint: .bottom)

func getLinkUrl(_ path: String, queryItems: [URLQueryItem]? = nil) -> URL {
    var components = URLComponents()
    components.scheme = "finale"
    components.path = "/\(path)"
    components.queryItems = queryItems
    return components.url!
}

struct FinaleWidgetLarge<Content> : View where Content : View {
    let title: String
    let period: Period
    let username: String?
    let isPreview: Bool
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        ZStack {
            widgetBackgroundGradient
            VStack {
                TitleBar(title: title, period: period)
                if !isPreview && username?.isEmpty ?? true {
                    Text("Please enter your username in the widget settings.")
                        .foregroundColor(Color("AccentColor"))
                        .frame(maxHeight: .infinity)
                } else {
                    content()
                        .padding(.bottom)
                        .frame(maxHeight: .infinity)
                }
            }
            .padding(.horizontal)
        }
    }
}

private struct TitleBar: View {
    let title: String
    let period: Period
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .bold()
                .foregroundColor(Color("AccentColor"))
            Text(period.displayName)
                .bold()
                .font(.caption)
                .foregroundColor(Color("AccentColor"))
            Spacer()
            HStack(alignment: .center) {
                Link(destination: getLinkUrl("scrobbleOnce")) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundColor(Color("AccentColor"))
                }
                Link(destination: getLinkUrl("scrobbleContinuously")) {
                    Image(systemName: "infinity")
                        .resizable()
                        .frame(width: 20, height: 10)
                        .foregroundColor(Color("AccentColor"))
                }
                Image("FinaleIconWhite")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .colorMultiply(Color("AccentColor"))
            }
        }
        .padding(.top)
    }
}
