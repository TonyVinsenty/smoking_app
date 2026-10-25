import Foundation
import Security

/// Where the app leaves the widgets' data (lib/app/home_widget.dart). Built into both the app and the widget extension.
///
/// With a proper signature this is a shared App Group. Sideloadly with a free Apple ID gives no App Group, but signs
/// the widget with the app's own App ID, so the keychain under that ID is shared too: the payload goes there as well.
enum WidgetStore {
  private static let defaultGroup = "group.com.tonyvinsenty.smokingApp"
  private static let payloadKey = "payload"

  /// The App Group's defaults, only when the signature really grants the group.
  private static var groupDefaults: UserDefaults? {
    FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupId) == nil
      ? nil : UserDefaults(suiteName: groupId)
  }

  static var payload: String? {
    get { groupDefaults?.string(forKey: payloadKey) ?? Keychain.read() }
    set {
      groupDefaults?.set(newValue, forKey: payloadKey)
      Keychain.write(newValue)
    }
  }

  /// The entitlement the running process really got from its signature (Security's SecTask, looked up at run time
  /// because iOS does not declare it); nil when it is missing.
  static func entitlement(_ key: String) -> Any? {
    typealias Create = @convention(c) (CFAllocator?) -> UnsafeMutableRawPointer?
    typealias Copy = @convention(c) (UnsafeMutableRawPointer, CFString, UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer?
    guard let security = dlopen("/System/Library/Frameworks/Security.framework/Security", RTLD_NOW),
      let createSymbol = dlsym(security, "SecTaskCreateFromSelf"),
      let copySymbol = dlsym(security, "SecTaskCopyValueForEntitlement"),
      let task = unsafeBitCast(createSymbol, to: Create.self)(nil)
    else { return nil }
    defer { Unmanaged<AnyObject>.fromOpaque(task).release() }
    guard let value = unsafeBitCast(copySymbol, to: Copy.self)(task, key as CFString, nil) else { return nil }
    return Unmanaged<AnyObject>.fromOpaque(value).takeRetainedValue()
  }

  /// Sideloadly may rename the group when it re-signs, so the name comes from the signature.
  static let groupId: String = {
    let groups = entitlement("com.apple.security.application-groups") as? [String] ?? []
    return groups.first(where: { $0.contains("smokingApp") }) ?? groups.first ?? defaultGroup
  }()

  /// One generic password under the App ID's own access group, which the app and the widget share when they are
  /// signed with the same App ID.
  private enum Keychain {
    private static var query: [String: Any] {
      var query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: "zero.widget",
        kSecAttrAccount as String: WidgetStore.payloadKey,
      ]
      if let appId = WidgetStore.entitlement("application-identifier") as? String { query[kSecAttrAccessGroup as String] = appId }
      return query
    }

    static func read() -> String? {
      var item: CFTypeRef?
      var request = query
      request[kSecReturnData as String] = true
      guard SecItemCopyMatching(request as CFDictionary, &item) == errSecSuccess, let data = item as? Data else {
        return nil
      }
      return String(data: data, encoding: .utf8)
    }

    static func write(_ value: String?) {
      SecItemDelete(query as CFDictionary)
      guard let value else { return }
      var item = query
      item[kSecValueData as String] = Data(value.utf8)
      item[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
      SecItemAdd(item as CFDictionary, nil)
    }
  }
}
