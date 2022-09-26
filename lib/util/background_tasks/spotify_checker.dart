import 'package:collection/collection.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/spotify/spotify.dart';
import 'package:finale/util/external_actions/notifications.dart';
import 'package:finale/util/preferences.dart';

import 'background_task.dart';

class SpotifyCheckerBackgroundTask extends BackgroundTask {
  static const _maxDelta = Duration(minutes: 15);

  const SpotifyCheckerBackgroundTask() : super('SpotifyChecker');

  @override
  Future<bool> get shouldRun async =>
      Preferences.spotifyEnabled.value &&
      Preferences.hasSpotifyAuthData &&
      Preferences.spotifyCheckerEnabled.value;

  @override
  Future<void> setup() async {
    super.setup();

    Preferences.spotifyEnabled.changes.listen(_onSpotifyChange);
    Preferences.spotifyCheckerEnabled.changes.listen(_onSpotifyChange);
  }

  @override
  Future<bool> run() async {
    final latestLastfmTrack =
        (await GetRecentTracksRequest(Preferences.name.value!).getData(1, 1))
            .lastOrNull;

    final latestSpotifyTrack =
        (await Spotify.getRecentTracks(limit: 1)).lastOrNull;

    if (latestLastfmTrack != null &&
        latestSpotifyTrack != null &&
        latestSpotifyTrack.playedAt.difference(latestLastfmTrack.date!) >
            _maxDelta) {
      showNotification(NotificationType.spotifyCheckerOutOfSync);
    }

    await register(initialDelay: const Duration(hours: 3));

    return true;
  }

  void _onSpotifyChange(_) {
    register();
  }
}
