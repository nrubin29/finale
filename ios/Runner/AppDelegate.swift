import UIKit
import Flutter
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    WorkmanagerPlugin.registerPeriodicTask(
        withIdentifier: "com.nrubintech.finale.BackgroundScrobbling",
        frequency: NSNumber(value: 60 * 60) // 1 hour
    )
    WorkmanagerPlugin.registerPeriodicTask(
        withIdentifier: "com.nrubintech.finale.SpotifyChecker",
        frequency: NSNumber(value: 3 * 60 * 60) // 3 hours
    )

    // For local notifications
    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
