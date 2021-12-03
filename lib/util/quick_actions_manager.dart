import 'package:finale/services/generic.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uni_links/uni_links.dart';

class QuickAction {
  final QuickActionType type;
  final dynamic value;
  final timestamp = DateTime.now();

  QuickAction.scrobbleOnce()
      : type = QuickActionType.scrobbleOnce,
        value = null;

  QuickAction.scrobbleContinuously()
      : type = QuickActionType.scrobbleContinuously,
        value = null;

  QuickAction.viewAlbum(BasicAlbum album)
      : type = QuickActionType.viewAlbum,
        value = album;

  QuickAction.viewTab(EntityType tab)
      : type = QuickActionType.viewTab,
        value = tab;
}

enum QuickActionType { scrobbleOnce, scrobbleContinuously, viewAlbum, viewTab }

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
  static Stream<QuickAction> get quickActionStream =>
      _quickActions.where((action) =>
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
    } else if (uri.path == '/scrobbleOnce') {
      _quickActions.add(QuickAction.scrobbleOnce());
    } else if (uri.path == '/scrobbleContinuously') {
      _quickActions.add(QuickAction.scrobbleContinuously());
    } else if (uri.path == '/album') {
      final name = uri.queryParameters['name']!;
      final artist = uri.queryParameters['artist']!;
      _quickActions.add(QuickAction.viewAlbum(
          ConcreteBasicAlbum(name, ConcreteBasicArtist(artist))));
    } else if (uri.path == '/profileTab') {
      final tabString = uri.queryParameters['tab'];
      EntityType tab;

      switch (tabString) {
        case 'scrobble':
          tab = EntityType.playlist;
          break;
        case 'artist':
          tab = EntityType.artist;
          break;
        case 'album':
          tab = EntityType.album;
          break;
        case 'track':
          tab = EntityType.track;
          break;
        default:
          throw ArgumentError.value(tabString, 'tab', 'Unknown tab');
      }

      _quickActions.add(QuickAction.viewTab(tab));
    }
  }
}
