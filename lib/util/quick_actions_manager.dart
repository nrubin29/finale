import 'package:quick_actions/quick_actions.dart';
import 'package:rxdart/rxdart.dart';

enum QuickAction { scrobbleOnce, scrobbleContinuously }

class QuickActionsManager {
  // This stream needs to be open for the entire lifetime of the app.
  // ignore: close_sinks
  static final quickActionStream = BehaviorSubject<QuickAction>();

  static Future<void> setup() async {
    final quickActions = QuickActions();
    await quickActions.initialize((type) {
      quickActionStream.add(type == 'scrobble_once'
          ? QuickAction.scrobbleOnce
          : QuickAction.scrobbleContinuously);
    });
    await quickActions.setShortcutItems(const [
      ShortcutItem(
        type: 'scrobble_once',
        localizedTitle: 'Recognize song',
        icon: 'add',
      ),
      ShortcutItem(
        type: 'scrobble_continuously',
        localizedTitle: 'Recognize continuously',
        icon: 'all_inclusive',
      ),
    ]);
  }
}
