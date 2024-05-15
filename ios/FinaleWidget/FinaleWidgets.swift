import SwiftUI

@available(iOS 15.0, *)
@main
struct FinaleWidgets: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        TopEntitiesWidget()
        StatisticsWidget()
    }
}
