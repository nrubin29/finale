import UIKit
import Flutter
import workmanager

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private static let backgroundTasks = ["BackgroundScrobbling", "SpotifyChecker"]
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    
    AppDelegate.backgroundTasks.forEach { WorkmanagerPlugin.registerTask(withIdentifier: "com.nrubintech.finale.\($0)") }

    // For local notifications
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
