import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:universal_io/io.dart';

Future<void> setup() async {
  const initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('app_icon'),
    iOS: IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    ),
  );

  await FlutterLocalNotificationsPlugin().initialize(
    initializationSettings,
    onSelectNotification: (payload) async {
      if (kDebugMode) {
        print(payload);
      }
    },
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

Future<void> showNotification(String title, String body) async {
  await FlutterLocalNotificationsPlugin().show(0, title, body, null);
}
