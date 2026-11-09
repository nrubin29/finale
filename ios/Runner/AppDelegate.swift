import UIKit
import Flutter
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // For local notifications
    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate

    // BGTaskScheduler only delivers tasks if their handlers are registered
    // before launch finishes, which is before the implicit engine exists.
    WorkmanagerPlugin.registerPeriodicTask(
        withIdentifier: "com.nrubintech.finale.BackgroundScrobbling",
        earliestBeginInSeconds: NSNumber(value: 60 * 60) // 1 hour
    )
    WorkmanagerPlugin.registerPeriodicTask(
        withIdentifier: "com.nrubintech.finale.SpotifyChecker",
        earliestBeginInSeconds: NSNumber(value: 3 * 60 * 60) // 3 hours
    )

    // Background tasks run in their own engine, which needs plugins too.
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
