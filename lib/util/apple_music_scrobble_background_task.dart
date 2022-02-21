import 'package:finale/services/apple_music/apple_music.dart';
import 'package:finale/util/preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:workmanager/workmanager.dart';

const _taskName = Workmanager.iOSBackgroundProcessingTask;

class AppleMusicScrobbleBackgroundTask {
  static Future<void> setup() async {
    await Workmanager()
        .initialize(runAppleMusicScrobbleBackgroundTask, isInDebugMode: true);
    await _registerTask();
  }

  static Future<void> _registerTask(
      {Duration initialDelay = Duration.zero}) async {
    await Workmanager().cancelByUniqueName(_taskName);
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

      await Preferences().setup();

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
