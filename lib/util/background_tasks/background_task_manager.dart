import 'package:finale/util/constants.dart';
import 'package:finale/util/preference.dart';
import 'package:universal_io/io.dart';
import 'package:workmanager/workmanager.dart';

import 'apple_music_scrobble.dart';
import 'spotify_checker.dart';

final _tasks = [
  if (Platform.isIOS) const AppleMusicScrobbleBackgroundTask(),
  const SpotifyCheckerBackgroundTask(),
];

Future<void> setup() async {
  await Workmanager().initialize(
    backgroundTaskDispatcher,
    isInDebugMode: isDebug,
  );

  await Future.wait(_tasks.map((task) => task.setup()));
}

@pragma('vm:entry-point')
void backgroundTaskDispatcher() {
  Workmanager().executeTask((taskName, _) async {
    final task = _tasks.singleWhere((element) => element.name == taskName);

    await Preference.setup();

    if (!await task.shouldRun) return false;

    return await task.run();
  });
}
