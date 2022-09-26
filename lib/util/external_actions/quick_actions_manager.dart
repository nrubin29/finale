/// Handles [QuickActions] and initial links by firing the corresponding
/// [ExternalAction]s.

import 'package:finale/services/generic.dart';
import 'package:finale/util/external_actions/external_actions.dart';
import 'package:finale/util/profile_tab.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:uni_links/uni_links.dart';

import 'time_safe_stream.dart';

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
    externalActions.addTimestamped(ExternalAction.scrobbleOnce());
  } else if (uri.host == 'scrobblecontinuously') {
    externalActions.addTimestamped(ExternalAction.scrobbleContinuously());
  } else if (uri.host == 'album') {
    final name = uri.queryParameters['name']!;
    final artist = uri.queryParameters['artist']!;
    externalActions.addTimestamped(ExternalAction.viewAlbum(
        ConcreteBasicAlbum(name, ConcreteBasicArtist(artist))));
  } else if (uri.host == 'artist') {
    final name = uri.queryParameters['name']!;
    externalActions
        .addTimestamped(ExternalAction.viewArtist(ConcreteBasicArtist(name)));
  } else if (uri.host == 'track') {
    final name = uri.queryParameters['name']!;
    final artist = uri.queryParameters['artist']!;
    externalActions.addTimestamped(
        ExternalAction.viewTrack(BasicConcreteTrack(name, artist, null)));
  } else if (uri.host == 'profiletab') {
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

    externalActions.addTimestamped(ExternalAction.viewTab(tab));
  }
}
