import 'package:finale/services/apple_music/apple_music.dart';
import 'package:finale/util/preferences.dart';

import 'background_task.dart';

class AppleMusicScrobbleBackgroundTask extends BackgroundTask {
  const AppleMusicScrobbleBackgroundTask() : super('BackgroundScrobbling');

  @override
  Future<bool> get shouldRun async =>
      Preferences.appleMusicEnabled.value &&
      Preferences.appleMusicBackgroundScrobblingEnabled.value &&
      await AppleMusic.authorizationStatus == AuthorizationStatus.authorized;

  @override
  Future<void> setup() async {
    super.setup();

    Preferences.appleMusicEnabled.changes.listen(_onAppleMusicChange);
    Preferences.appleMusicBackgroundScrobblingEnabled.changes
        .listen(_onAppleMusicChange);
  }

  @override
  Future<bool> run() async {
    final tracks = await const AMRecentTracksRequest().getAllData();
    var success = true;

    if (tracks.isNotEmpty) {
      success = await AppleMusic.scrobble(tracks);
    }

    await register(initialDelay: const Duration(hours: 1));
    return success;
  }

  void _onAppleMusicChange(_) {
    register();
  }
}
