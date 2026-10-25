import Foundation

/// Where the app leaves the widgets' data (lib/app/home_widget.dart): a shared App Group. Built into both the app
/// and the widget extension.
enum WidgetStore {
  static let payloadKey = "payload"
  private static let defaultGroup = "group.com.tonyvinsenty.smokingApp"

  static var defaults: UserDefaults? { UserDefaults(suiteName: groupId) }

  /// Entitlements of the bundle's own provisioning profile (nil when there is none).
  static let profileEntitlements: [String: Any]? = {
    guard let url = Bundle.main.url(forResource: "embedded", withExtension: "mobileprovision"),
      let data = try? Data(contentsOf: url),
      let start = data.range(of: Data("<?xml".utf8)),
      let end = data.range(of: Data("</plist>".utf8), in: start.lowerBound..<data.endIndex),
      let profile = try? PropertyListSerialization.propertyList(
        from: data.subdata(in: start.lowerBound..<end.upperBound), format: nil) as? [String: Any]
    else { return nil }
    return profile["Entitlements"] as? [String: Any]
  }()

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

  /// Sideloadly may rename the group when it re-signs, so the name comes from the signature (or the profile).
  static let groupId: String = {
    let groups = entitlement("com.apple.security.application-groups") as? [String]
      ?? profileEntitlements?["com.apple.security.application-groups"] as? [String] ?? []
    return groups.first(where: { $0.contains("smokingApp") }) ?? groups.first ?? defaultGroup
  }()

  /// Temporary: what signing allowed, shown by an empty widget (and under the version in the app's settings) so
  /// the owner can send a screenshot.
  static var diagnostics: String {
    let groups = (entitlement("com.apple.security.application-groups") as? [String])?.joined(separator: ", ") ?? "-"
    let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupId) != nil
    return [
      "id: \(entitlement("application-identifier") as? String ?? "-")",
      "groups: \(groups)",
      "group: \(groupId)",
      "container: \(container ? "yes" : "no")",
      "profile: \(profileEntitlements == nil ? "none" : "\(profileEntitlements!.count) keys")",
      "data: \(defaults?.string(forKey: payloadKey) == nil ? "no" : "yes")",
    ].joined(separator: "\n")
  }
}
