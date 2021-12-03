import SwiftUI

struct ScoreTileModel {
    let title: String
    let value: Int?
    let icon: String
}

struct Scoreboard: View {
    let tiles: [ScoreTileModel]
    
    var body: some View {
        HStack {
            ForEach(Array(tiles.enumerated()), id: \.element.title) { (index, model) in
                ScoreTile(model: model)
                if (index < tiles.count - 1) {
                    Divider()
                }
            }
        }
        .fixedSize()
    }
}

private struct ScoreTile: View {
    let model: ScoreTileModel
    
    var body: some View {
        VStack {
            Image(model.icon)
                .resizable()
                .frame(width: 30, height: 30)
                .colorMultiply(Color("AccentColor"))
            Text(model.title)
                .foregroundColor(Color("AccentColor"))
                .bold()
            Text(model.value != nil ? numberFormatter.string(from: NSNumber(value: model.value!))! : "---")
                .foregroundColor(Color("AccentColor"))
                .bold()
        }
    }
}
