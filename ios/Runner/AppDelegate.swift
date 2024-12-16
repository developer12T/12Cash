import Flutter
import UIKit
import GoogleMaps
import AppTrackingTransparency

@main
@objc class AppDelegate: FlutterAppDelegate {
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      // Google Maps API Key setup
    GMSServices.provideAPIKey("APIKEY")
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  override func applicationDidBecomeActive(_ application: UIApplication) {
    // Ensure the app is active and the UI is loaded before requesting tracking authorization
      if #available(iOS 14, *) {
          ATTrackingManager.requestTrackingAuthorization { status in
              switch status {
              case .authorized:
                  print("Tracking authorized.")
              case .denied, .restricted:
                  print("Tracking not authorized.")
                  // Handle the case if tracking is denied or restricted
              case .notDetermined:
                  print("Tracking not determined.")
              @unknown default:
                  print("Unknown tracking status.")
              }
          }
      } else {
          // Fallback on earlier versions
      }
  }
}
