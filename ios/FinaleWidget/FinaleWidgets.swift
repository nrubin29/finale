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
