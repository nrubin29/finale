/// Handles [QuickActions] and initial links by firing the corresponding
/// [ExternalAction]s.
library;

import 'package:app_links/app_links.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/util/external_actions/external_actions.dart';
import 'package:finale/util/profile_tab.dart';
import 'package:quick_actions/quick_actions.dart';

import 'time_safe_stream.dart';

Future<void> setup() async {
  final appLinks = AppLinks();
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

  appLinks.uriLinkStream.listen((uri) {
    _handleLink(uri);
  });
}

void _handleLink(Uri? uri) {
  if (uri == null) {
    return;
  } else if (uri.host == 'scrobbleonce') {
    externalActions.addTimestamped(.scrobbleOnce());
  } else if (uri.host == 'scrobblecontinuously') {
    externalActions.addTimestamped(.scrobbleContinuously());
  } else if (uri.host == 'album') {
    final name = uri.queryParameters['name']!;
    final artist = uri.queryParameters['artist']!;
    externalActions.addTimestamped(
      .viewAlbum(ConcreteBasicAlbum(name, ConcreteBasicArtist(artist))),
    );
  } else if (uri.host == 'artist') {
    final name = uri.queryParameters['name']!;
    externalActions.addTimestamped(.viewArtist(ConcreteBasicArtist(name)));
  } else if (uri.host == 'track') {
    final name = uri.queryParameters['name']!;
    final artist = uri.queryParameters['artist']!;
    externalActions.addTimestamped(
      .viewTrack(BasicConcreteTrack(name, artist, null)),
    );
  } else if (uri.host == 'profiletab') {
    final tabString = uri.queryParameters['tab'];
    ProfileTab tab;

    switch (tabString) {
      case 'scrobble':
        tab = .recentScrobbles;
        break;
      case 'artist':
        tab = .topArtists;
        break;
      case 'album':
        tab = .topAlbums;
        break;
      case 'track':
        tab = .topTracks;
        break;
      default:
        throw ArgumentError.value(tabString, 'tab', 'Unknown tab');
    }

    externalActions.addTimestamped(.viewTab(tab));
  }
}
