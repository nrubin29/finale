import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:universal_io/io.dart';

import 'time_safe_stream.dart';

enum NotificationType {
  spotifyCheckerOutOfSync(
      'Spotify Checker', 'Spotify is not sending scrobbles to Last.fm!');

  final String title;
  final String body;

  const NotificationType(this.title, this.body);
}

// This stream needs to be open for the entire lifetime of the app.
// ignore: close_sinks
final _notifications = ReplaySubject<Timestamped<NotificationType>>();

/// A stream of notifications that should be handled.
Stream<NotificationType> get notificationsStream =>
    _notifications.timeSafeStream();

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
  _notifications.addTimestamped(NotificationType.values[details.id!]);
}
