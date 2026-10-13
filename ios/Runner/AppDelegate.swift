import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "ZeroAppIcon") {
      let channel = FlutterMethodChannel(name: "zero/app_icon", binaryMessenger: registrar.messenger())
      channel.setMethodCallHandler(Self.handleAppIcon)
    }
  }

  /// Switches between AppIcon (9a, default) and the alternate sets AppIcon-<id> in Assets.xcassets.
  private static func handleAppIcon(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "set", let id = call.arguments as? String else {
      result(FlutterMethodNotImplemented)
      return
    }
    guard UIApplication.shared.supportsAlternateIcons else {
      result(FlutterError(code: "unsupported", message: "Alternate icons are not supported", details: nil))
      return
    }
    UIApplication.shared.setAlternateIconName(id == "9a" ? nil : "AppIcon-\(id)") { error in
      DispatchQueue.main.async {
        if let error = error {
          result(FlutterError(code: "failed", message: error.localizedDescription, details: nil))
        } else {
          result(nil)
        }
      }
    }
  }
}
