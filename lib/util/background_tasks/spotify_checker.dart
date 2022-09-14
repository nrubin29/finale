import 'package:collection/collection.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/spotify/spotify.dart';
import 'package:finale/util/preferences.dart';

import 'background_task.dart';

class SpotifyCheckerBackgroundTask extends BackgroundTask {
  const SpotifyCheckerBackgroundTask() : super('SpotifyChecker');

  @override
  Future<bool> get shouldRun async =>
      Preferences.spotifyEnabled.value && Preferences.hasSpotifyAuthData
      // TODO: && Preferences.spotifyCheckerEnabled.value
      ;

  @override
  Future<void> setup() async {
    super.setup();

    Preferences.spotifyEnabled.changes.listen(_onSpotifyChange);
    // TODO: Preferences.spotifyCheckerEnabled.changes.listen(_onSpotifyChange);
  }

  @override
  Future<bool> run() async {
    final latestLastfmTrack =
        (await GetRecentTracksRequest(Preferences.name.value!).getData(1, 1))
            .lastOrNull;

    final latestSpotifyTrack =
        (await Spotify.getRecentTracks(limit: 1)).lastOrNull;

    if (latestLastfmTrack != null && latestSpotifyTrack != null) {
      if (latestSpotifyTrack.playedAt.difference(latestLastfmTrack.date!) >
          const Duration(minutes: 15)) {
        print('Out of sync!');
      } else {
        print('In sync');
      }
    }

    return true;
  }

  void _onSpotifyChange(_) {
    register();
  }
}
