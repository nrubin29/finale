import 'package:finale/services/generic.dart';
import 'package:finale/util/profile_tab.dart';
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

  QuickAction.viewArtist(BasicArtist artist)
      : type = QuickActionType.viewArtist,
        value = artist;

  QuickAction.viewTrack(Track track)
      : type = QuickActionType.viewTrack,
        value = track;

  QuickAction.viewTab(ProfileTab tab)
      : type = QuickActionType.viewTab,
        value = tab;
}

enum QuickActionType {
  scrobbleOnce,
  scrobbleContinuously,
  viewAlbum,
  viewArtist,
  viewTrack,
  viewTab,
}

class QuickActionsManager {
  static QuickActionsManager? _instance;

  factory QuickActionsManager() => _instance ??= QuickActionsManager._();

  QuickActionsManager._();

  // This stream needs to be open for the entire lifetime of the app.
  // ignore: close_sinks
  final _quickActions = ReplaySubject<QuickAction>();

  /// A stream of [QuickAction]s.
  ///
  /// This stream will emit all recent [QuickAction]s to every subscriber. This
  /// deals with the issue where a [QuickAction] may be emitted before the
  /// subscriber is ready to handle it as well as the issue where a subscriber
  /// may receive [QuickAction]s that have already been handled.
  Stream<QuickAction> get quickActionStream =>
      _quickActions.where((action) =>
          DateTime.now().difference(action.timestamp) <
          const Duration(seconds: 1));

  Future<void> setup() async {
    const quickActions = QuickActions();
    await quickActions.initialize((type) {
      _handleLink(Uri(host: type));
    });
    await quickActions.setShortcutItems(const [
      ShortcutItem(
        type: 'scrobbleonce',
        localizedTitle: 'Recognize song',
        icon: 'add',
      ),
      ShortcutItem(
        type: 'scrobblecontinuously',
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

  void _handleLink(Uri? uri) {
    if (uri == null) {
      return;
    } else if (uri.host == 'scrobbleonce') {
      _quickActions.add(QuickAction.scrobbleOnce());
    } else if (uri.host == 'scrobblecontinuously') {
      _quickActions.add(QuickAction.scrobbleContinuously());
    } else if (uri.host == 'album') {
      final name = uri.queryParameters['name']!;
      final artist = uri.queryParameters['artist']!;
      _quickActions.add(QuickAction.viewAlbum(
          ConcreteBasicAlbum(name, ConcreteBasicArtist(artist))));
    } else if (uri.host == 'artist') {
      final name = uri.queryParameters['name']!;
      _quickActions.add(QuickAction.viewArtist(ConcreteBasicArtist(name)));
    } else if (uri.host == 'track') {
      final name = uri.queryParameters['name']!;
      final artist = uri.queryParameters['artist']!;
      _quickActions
          .add(QuickAction.viewTrack(BasicConcreteTrack(name, artist, null)));
    } else if (uri.host == 'profileTab') {
      final tabString = uri.queryParameters['tab'];
      ProfileTab tab;

      switch (tabString) {
        case 'scrobble':
          tab = ProfileTab.recentScrobbles;
          break;
        case 'artist':
          tab = ProfileTab.topArtists;
          break;
        case 'album':
          tab = ProfileTab.topAlbums;
          break;
        case 'track':
          tab = ProfileTab.topTracks;
          break;
        default:
          throw ArgumentError.value(tabString, 'tab', 'Unknown tab');
      }

      _quickActions.add(QuickAction.viewTab(tab));
    }
  }
}
