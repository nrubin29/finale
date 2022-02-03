import SwiftUI

struct ScoreTileModel {
    let title: String
    let value: Int?
    let icon: String
    let link: String
}

enum ScoreboardAlignment {
    case vertical
    case horizontal
}

prefix func !(alignment: ScoreboardAlignment) -> ScoreboardAlignment {
    switch alignment {
    case .vertical: return .horizontal
    case .horizontal: return .vertical
    }
}

struct Scoreboard: View {
    let themeColor: ThemeColor
    let alignment: ScoreboardAlignment
    let tiles: [ScoreTileModel]
    
    var body: some View {
        Stack(alignment: alignment) {
            ForEach(Array(tiles.enumerated()), id: \.element.title) { (index, model) in
                ScoreTile(themeColor: themeColor, model: model, alignment: alignment)
                if (alignment == .horizontal && index < tiles.count - 1) {
                    Divider()
                        .padding(.horizontal, 2)
                }
            }
        }
        .fixedSize()
    }
}

private struct ScoreTileVertical: View {
    let themeColor: ThemeColor
    let model: ScoreTileModel
    
    var body: some View {
        Link(destination: getLinkUrl("profileTab", queryItems: [URLQueryItem(name: "tab", value: model.link)])) {
            VStack {
                Image(model.icon)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .colorMultiply(themeColor.accent)
                Text(model.title)
                    .foregroundColor(themeColor.accent)
                    .bold()
                Text(model.value != nil ? numberFormatter.string(from: NSNumber(value: model.value!))! : "---")
                    .foregroundColor(themeColor.accent)
                    .bold()
            }
        }
    }
}

private struct ScoreTileHorizontal: View {
    let themeColor: ThemeColor
    let model: ScoreTileModel
    
    var body: some View {
        Link(destination: getLinkUrl("profileTab", queryItems: [URLQueryItem(name: "tab", value: model.link)])) {
            HStack {
                Text(model.value != nil ? numberFormatter.string(from: NSNumber(value: model.value!))! : "---")
                    .foregroundColor(themeColor.accent)
                    .bold()
                Image(model.icon)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .colorMultiply(themeColor.accent)
            }
        }
    }
}

private struct ScoreTile : View {
    let themeColor: ThemeColor
    let model: ScoreTileModel
    let alignment: ScoreboardAlignment
    
    var body: some View {
        switch (alignment) {
        case .vertical: ScoreTileHorizontal(themeColor: themeColor, model: model)
        case .horizontal: ScoreTileVertical(themeColor: themeColor, model: model)
        }
    }
}

private struct Stack<Content> : View where Content : View {
    let alignment: ScoreboardAlignment
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        switch (alignment) {
        case .vertical: VStack(content: content)
        case .horizontal: HStack(content: content)
        }
    }
}
