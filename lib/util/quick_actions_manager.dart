import 'package:finale/services/generic.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uni_links/uni_links.dart';

class QuickAction {
  final QuickActionType type;
  final Entity? entity;
  final timestamp = DateTime.now();

  QuickAction.scrobbleOnce()
      : type = QuickActionType.scrobbleOnce,
        entity = null;

  QuickAction.scrobbleContinuously()
      : type = QuickActionType.scrobbleContinuously,
        entity = null;

  QuickAction.viewAlbum(BasicAlbum album)
      : type = QuickActionType.viewAlbum,
        entity = album;
}

enum QuickActionType { scrobbleOnce, scrobbleContinuously, viewAlbum }

class QuickActionsManager {
  // This stream needs to be open for the entire lifetime of the app.
  // ignore: close_sinks
  static final _quickActions = ReplaySubject<QuickAction>();

  /// A stream of [QuickAction]s.
  ///
  /// This stream will emit all recent [QuickAction]s to every subscriber. This
  /// deals with the issue where a [QuickAction] may be emitted before the
  /// subscriber is ready to handle it as well as the issue where a subscriber
  /// may receive [QuickAction]s that have already been handled.
  static Stream<QuickAction> get quickActionStream => _quickActions
      .where((action) =>
          DateTime.now().difference(action.timestamp) <
          const Duration(seconds: 1));

  static Future<void> setup() async {
    const quickActions = QuickActions();
    await quickActions.initialize((type) {
      _quickActions.add(type == 'scrobble_once'
          ? QuickAction.scrobbleOnce()
          : QuickAction.scrobbleContinuously());
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

    try {
      final initialUri = await getInitialUri();
      _handleLink(initialUri);
    } on FormatException {
      // Do nothing.
    }

    uriLinkStream.listen((uri) {
      _handleLink(uri);
    });
  }

  static void _handleLink(Uri? uri) {
    if (uri == null) {
      return;
    } else if (uri.path == '/album') {
      final name = uri.queryParameters['name']!;
      final artist = uri.queryParameters['artist']!;
      _quickActions.add(QuickAction.viewAlbum(
          ConcreteBasicAlbum(name, ConcreteBasicArtist(artist))));
    }
  }
}
