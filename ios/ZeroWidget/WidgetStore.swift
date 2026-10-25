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

  /// Sideloadly may rename the group when it re-signs, so the name comes from the profile.
  static let groupId: String = {
    let groups = profileEntitlements?["com.apple.security.application-groups"] as? [String] ?? []
    return groups.first(where: { $0.contains("smokingApp") }) ?? groups.first ?? defaultGroup
  }()

  /// Temporary: what signing allowed, shown by an empty widget so the owner can send a screenshot.
  static var diagnostics: String {
    let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupId) != nil
    let keychain = (profileEntitlements?["keychain-access-groups"] as? [String])?.joined(separator: ", ") ?? "-"
    return [
      "group: \(groupId)",
      "container: \(container ? "yes" : "no")",
      "profile: \(profileEntitlements == nil ? "none" : "\(profileEntitlements!.keys.sorted().count) keys")",
      "keychain: \(keychain)",
      "data: \(defaults?.string(forKey: payloadKey) == nil ? "no" : "yes")",
    ].joined(separator: "\n")
  }
}
