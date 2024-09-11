import UIKit
import Flutter
import GoogleMaps


@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("Your_Google_Map_Key_for_location_messages")
      
      UNUserNotificationCenter.current().delegate = self
      
      if #available(iOS 10, *) {
         UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ granted, error in }
      } else {
         application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
      }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
