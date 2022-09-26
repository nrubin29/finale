import 'package:finale/util/external_actions.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:universal_io/io.dart';

import 'time_safe_stream.dart';

enum NotificationType {
  spotifyCheckerOutOfSync(
      'Spotify Checker',
      'Spotify is not sending scrobbles to Last.fm!',
      ExternalAction.openSpotifyChecker);

  final String title;
  final String body;
  final ExternalAction Function() externalActionFactory;

  const NotificationType(this.title, this.body, this.externalActionFactory);
}

Future<void> setup() async {
  const initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@drawable/music_note'),
    iOS: DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    ),
  );

  await FlutterLocalNotificationsPlugin().initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: didReceiveNotification,
    onDidReceiveBackgroundNotificationResponse: didReceiveNotification,
  );
}

Future<bool> requestPermission() async {
  if (Platform.isIOS) {
    return await FlutterLocalNotificationsPlugin()
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()!
            .requestPermissions(alert: true, badge: true, sound: true) ??
        false;
  } else if (Platform.isAndroid) {
    return await FlutterLocalNotificationsPlugin()
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()!
            .requestPermission() ??
        false;
  }

  return false;
}

Future<void> showNotification(NotificationType type) async {
  await FlutterLocalNotificationsPlugin().show(
    type.index,
    type.title,
    type.body,
    NotificationDetails(
        android: AndroidNotificationDetails(type.name, type.name)),
  );
}

@pragma('vm:entry-point')
void didReceiveNotification(NotificationResponse details) {
  externalActions.addTimestamped(
      NotificationType.values[details.id!].externalActionFactory());
}
