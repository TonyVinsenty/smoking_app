import Flutter
import UIKit
import WidgetKit

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
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "ZeroHomeWidget") {
      let bridge = HomeWidgetBridge(messenger: registrar.messenger())
      registrar.addSceneDelegate(bridge)
      homeWidget = bridge
    }
  }

  private var homeWidget: HomeWidgetBridge?

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

/// The home-screen widgets (ios/ZeroWidget): takes their data from Dart and brings their SOS taps (zero://sos) back.
final class HomeWidgetBridge: NSObject, FlutterSceneLifeCycleDelegate {
  private let channel: FlutterMethodChannel
  /// An SOS tap that started the app, collected by Dart once it is ready (launchAction).
  private var pending: String?

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "zero/home_widget", binaryMessenger: messenger)
    super.init()
    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "update":
        WidgetStore.defaults?.set(call.arguments as? String, forKey: WidgetStore.payloadKey)
        WidgetCenter.shared.reloadAllTimelines()
        result(nil)
      case "launchAction":
        result(self?.pending)
        self?.pending = nil
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private static func action(_ contexts: Set<UIOpenURLContext>) -> String? {
    contexts.first { $0.url.scheme == "zero" }?.url.host
  }

  @objc(scene:willConnectToSession:options:)
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions?) -> Bool {
    guard let action = Self.action(options?.urlContexts ?? []) else { return false }
    pending = action
    return true
  }

  @objc(scene:openURLContexts:)
  func scene(_ scene: UIScene, openURLContexts: Set<UIOpenURLContext>) -> Bool {
    guard let action = Self.action(openURLContexts) else { return false }
    channel.invokeMethod("open", arguments: action)
    return true
  }
}
