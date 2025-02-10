import SwiftUI

func getLinkUrl(_ method: String, queryItems: [URLQueryItem]? = nil) -> URL {
    var components = URLComponents()
    components.scheme = "finale"
    components.host = method
    components.queryItems = queryItems
    return components.url!
}

struct FinaleWidget<Content>: View where Content: View {
    let themeColor: ThemeColor
    @ViewBuilder let content: () -> Content

    private var gradient: some View {
        return LinearGradient(
            gradient: Gradient(colors: [
                themeColor.gradientStart, themeColor.gradientEnd,
            ]), startPoint: .top, endPoint: .bottom)
    }

    var body: some View {
        if #available(iOS 17.0, *) {
            content()
                .containerBackground(for: .widget) {
                    gradient
                }
        } else {
            ZStack {
                gradient
                content()
            }
        }
    }
}

struct FinaleWidgetLarge<Content>: View where Content: View {
    let title: String
    let period: Period
    let username: String?
    let themeColor: ThemeColor
    let isPreview: Bool
    @ViewBuilder let content: () -> Content

    var body: some View {
        FinaleWidget(themeColor: themeColor) {
            VStack {
                TitleBar(title: title, period: period, themeColor: themeColor)
                    .safeWidgetAccentable()
                if !isPreview && username?.isEmpty ?? true {
                    Text("Please enter your username in the widget settings.")
                        .foregroundColor(themeColor.accent)
                        .frame(maxHeight: .infinity)
                        .safeWidgetAccentable()
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
    let themeColor: ThemeColor

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .bold()
                .foregroundColor(themeColor.accent)
            Text(period.displayName)
                .bold()
                .font(.caption)
                .foregroundColor(themeColor.accent)
            Spacer()
            HStack(alignment: .center) {
                Link(destination: getLinkUrl("scrobbleonce")) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundColor(themeColor.accent)
                }
                Link(destination: getLinkUrl("scrobblecontinuously")) {
                    Image(systemName: "infinity")
                        .resizable()
                        .frame(width: 20, height: 10)
                        .foregroundColor(themeColor.accent)
                }
                Image("FinaleIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                    .colorMultiply(themeColor.accent)
            }
        }
        .padding(.top)
    }
}

struct WidgetAccentableSafe: ViewModifier {
    var accentable: Bool

    func body(content: Content) -> some View {
        if #available(iOSApplicationExtension 16.0, *) {
            content
                .widgetAccentable(accentable)
        } else {
            content
        }
    }
}

extension View {
    func safeWidgetAccentable(_ accentable: Bool = true) -> some View {
        modifier(WidgetAccentableSafe(accentable: accentable))
    }
}
