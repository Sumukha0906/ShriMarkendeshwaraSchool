import Flutter
import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, MessagingDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Initialize Firebase natively with explicit options (no GoogleService-Info.plist needed)
    // This ensures Auth is ready before APNs token callbacks fire
    if FirebaseApp.app() == nil {
      let options = FirebaseOptions(
        googleAppID: "1:1026624818994:ios:9a7568dac9cfaa82ed112b",
        gcmSenderID: "1026624818994"
      )
      options.apiKey       = "AIzaSyBEm9H4XW3VOysEl6ZObQdEx_FMOUoP1u4"
      options.projectID    = "school-management-applic-42008"
      options.bundleID     = "com.educonnect.educonnect"
      options.storageBucket = "school-management-applic-42008.firebasestorage.app"
      FirebaseApp.configure(options: options)
    }

    Messaging.messaging().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  // Forward APNs token to Firebase Auth and Messaging
  override func application(_ application: UIApplication,
                             didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Auth.auth().setAPNSToken(deviceToken, type: .unknown)
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  // Forward silent push to Firebase Auth first
  override func application(_ application: UIApplication,
                             didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                             fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    if Auth.auth().canHandleNotification(userInfo) {
      completionHandler(.noData)
      return
    }
    super.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
  }

  // Forward reCAPTCHA URL callback to Firebase Auth
  override func application(_ application: UIApplication,
                             open url: URL,
                             options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    if Auth.auth().canHandle(url) {
      return true
    }
    return super.application(application, open: url, options: options)
  }

  // MessagingDelegate stub
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {}
}
