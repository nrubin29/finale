import 'package:finale/services/apple_music/apple_music.dart';
import 'package:workmanager/workmanager.dart';

class AppleMusicScrobbleBackgroundTask {
  static const _taskName = 'AppleMusicScrobble';

  static Future<void> setup() async {
    await Workmanager().initialize(_runTask, isInDebugMode: true);
    await _registerTask();
  }

  static Future<void> _registerTask(
      {Duration initialDelay = Duration.zero}) async {
    await Workmanager().registerOneOffTask(_taskName, _taskName,
        initialDelay: initialDelay,
        constraints: Constraints(networkType: NetworkType.connected));
  }

  static void _runTask() {
    Workmanager().executeTask((task, inputData) async {
      print("Running background task: $task");

      if (task == _taskName) {
        final tracks = await AppleMusic.getRecentTracks();
        final success = await AppleMusic.scrobble(tracks);

        await _registerTask(initialDelay: const Duration(hours: 1));
        return success;
      }

      return false;
    });
  }
}
