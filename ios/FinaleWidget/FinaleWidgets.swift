import SwiftUI

@main
struct FinaleWidgets: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        TopEntitiesWidget()
        StatisticsWidget()
    }
}
