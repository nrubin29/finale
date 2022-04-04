import 'package:finale/services/apple_music/apple_music.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/util/preference.dart';
import 'package:finale/util/preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences_ios/shared_preferences_ios.dart';
import 'package:workmanager/workmanager.dart';

const _taskName = Workmanager.iOSBackgroundProcessingTask;

class AppleMusicScrobbleBackgroundTask {
  static Future<void> setup() async {
    await Workmanager().initialize(runAppleMusicScrobbleBackgroundTask,
        isInDebugMode: isDebug);

    if (Preferences.appleMusicBackgroundScrobblingEnabled.value) {
      await _registerTask();
    }

    Preferences.appleMusicEnabled.changes.listen(_onAppleMusicChange);
    Preferences.appleMusicBackgroundScrobblingEnabled.changes
        .listen(_onAppleMusicChange);
  }

  static void _onAppleMusicChange(_) async {
    if (Preferences.appleMusicEnabled.value &&
        Preferences.appleMusicBackgroundScrobblingEnabled.value) {
      await _registerTask();
    } else {
      await _cancelTask();
    }
  }

  static Future<void> _cancelTask() async {
    await Workmanager().cancelByUniqueName(_taskName);
  }

  static Future<void> _registerTask(
      {Duration initialDelay = Duration.zero}) async {
    await _cancelTask();

    if (await AppleMusic.authorizationStatus !=
        AuthorizationStatus.authorized) {
      return;
    }

    try {
      await Workmanager().registerOneOffTask(_taskName, _taskName,
          initialDelay: initialDelay,
          constraints: Constraints(
              networkType: NetworkType.connected, requiresCharging: false));
    } on PlatformException {
      if (kDebugMode) {
        print('Unable to register background task. This is expected in the '
            'simulator.');
      }
    }
  }
}

void runAppleMusicScrobbleBackgroundTask() {
  Workmanager().executeTask((task, _) async {
    if (task == _taskName) {
      if (await AppleMusic.authorizationStatus !=
          AuthorizationStatus.authorized) {
        return false;
      }

      // Necessary due to https://github.com/flutter/flutter/issues/98473.
      SharedPreferencesIOS.registerWith();
      await Preference.setup();

      final tracks = await AppleMusic.getRecentTracks();
      var success = true;

      if (tracks.isNotEmpty) {
        success = await AppleMusic.scrobble(tracks);
      }

      await AppleMusicScrobbleBackgroundTask._registerTask(
          initialDelay: const Duration(hours: 1));

      return success;
    }

    return false;
  });
}
