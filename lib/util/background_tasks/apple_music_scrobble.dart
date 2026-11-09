import 'package:finale/services/apple_music/apple_music.dart';
import 'package:finale/util/preferences.dart';

import 'background_task.dart';

class AppleMusicScrobbleBackgroundTask extends BackgroundTask {
  const AppleMusicScrobbleBackgroundTask()
    : super('BackgroundScrobbling', frequency: const Duration(hours: 1));

  @override
  Future<bool> isEnabled() async =>
      Preferences.appleMusicEnabled.value &&
      Preferences.appleMusicBackgroundScrobblingEnabled.value &&
      await AppleMusic.authorizationStatus == .authorized;

  @override
  Future<void> setup() async {
    super.setup();

    Preferences.appleMusicEnabled.changes.listen(_onAppleMusicChange);
    Preferences.appleMusicBackgroundScrobblingEnabled.changes.listen(
      _onAppleMusicChange,
    );
  }

  @override
  Future<bool> run() async => await AppleMusic.scrobbleRecentTracks() != null;

  void _onAppleMusicChange(_) {
    register();
  }
}
