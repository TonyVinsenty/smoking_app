import SwiftUI
import WidgetKit

// Home-screen widgets: the same four as on Android (android/.../ZeroWidgets.kt). The app hands over rates and texts
// (lib/app/home_widget.dart); the time is counted here, one timeline entry per minute.

private let sosURL = URL(string: "zero://sos")!

struct ZeroEntry: TimelineEntry {
  let date: Date
  let data: [String: Any]?
}

struct ZeroProvider: TimelineProvider {
  private func load() -> [String: Any]? {
    guard let json = WidgetStore.defaults?.string(forKey: WidgetStore.payloadKey) else { return nil }
    return (try? JSONSerialization.jsonObject(with: Data(json.utf8))) as? [String: Any]
  }

  func placeholder(in context: Context) -> ZeroEntry { ZeroEntry(date: Date(), data: nil) }

  func getSnapshot(in context: Context, completion: @escaping (ZeroEntry) -> Void) {
    completion(ZeroEntry(date: Date(), data: load()))
  }

  /// Two hours of minutes ahead, then the system asks again.
  func getTimeline(in context: Context, completion: @escaping (Timeline<ZeroEntry>) -> Void) {
    let data = load()
    let now = Date()
    let minute = Date(timeIntervalSince1970: (now.timeIntervalSince1970 / 60).rounded(.down) * 60)
    let entries = (0..<120).map { ZeroEntry(date: minute.addingTimeInterval(Double($0) * 60), data: data) }
    completion(Timeline(entries: entries, policy: .atEnd))
  }
}

/// What a widget shows at [now]: texts are ready-made by the app, numbers grow linearly from the attempt start.
struct ZeroStats {
  let data: [String: Any]
  let now: Date
  let dark: Bool

  func text(_ key: String) -> String { data[key] as? String ?? "" }

  func color(_ name: String) -> Color {
    let colors = data[dark ? "dark" : "light"] as? [String: Any]
    let argb = (colors?[name] as? NSNumber)?.int64Value ?? 0xFF00_0000
    return Color(
      .sRGB,
      red: Double((argb >> 16) & 0xFF) / 255,
      green: Double((argb >> 8) & 0xFF) / 255,
      blue: Double(argb & 0xFF) / 255,
      opacity: Double((argb >> 24) & 0xFF) / 255)
  }

  private var locale: Locale { Locale(identifier: text("locale")) }

  var start: Date? { (data["start"] as? NSNumber).map { Date(timeIntervalSince1970: $0.doubleValue / 1000) } }
  private var minutes: Int64 { start.map { max(0, Int64(now.timeIntervalSince($0) / 60)) } ?? 0 }

  private func number(_ n: Int64) -> String {
    let format = NumberFormatter()
    format.locale = locale
    format.numberStyle = .decimal
    format.maximumFractionDigits = 0
    return format.string(from: NSNumber(value: n)) ?? "\(n)"
  }

  /// CLDR plural category; only Russian is shipped, other languages fall back to one / other.
  private func form(_ key: String, _ n: Int64) -> String {
    let forms = data[key] as? [String: String] ?? [:]
    let category: String
    if locale.identifier.hasPrefix("ru") {
      let (d, h) = (n % 10, n % 100)
      category = d == 1 && h != 11 ? "one" : (2...4).contains(d) && !(12...14).contains(h) ? "few" : "many"
    } else {
      category = n == 1 ? "one" : "other"
    }
    return forms[category] ?? forms["other"] ?? ""
  }

  private func perDay(_ key: String) -> Int64 {
    Int64(((data[key] as? NSNumber)?.doubleValue ?? 0) * Double(minutes) / (24 * 60))
  }

  var days: String { number(minutes / (24 * 60)) }
  var daysWord: String { form("days", minutes / (24 * 60)) }
  var clock: String {
    text("clock").replacingOccurrences(of: "{h}", with: "\(minutes / 60 % 24)")
      .replacingOccurrences(of: "{m}", with: "\(minutes % 60)")
  }
  var money: String {
    start == nil ? "—" : text("money").replacingOccurrences(of: "{n}", with: number(perDay("moneyPerDay")))
  }
  var units: String {
    let n = perDay("unitsPerDay")
    return start == nil ? "—" : form("units", n).replacingOccurrences(of: "{n}", with: number(n))
  }
}

extension View {
  /// iOS 17 wants the background through containerBackground (and adds the margins itself).
  @ViewBuilder func widgetBackground(_ color: Color) -> some View {
    if #available(iOSApplicationExtension 17.0, *) {
      containerBackground(color, for: .widget)
    } else {
      padding(16).frame(maxWidth: .infinity, maxHeight: .infinity).background(color)
    }
  }
}

/// «без курения», the days in big figures, hours and minutes; «Новая попытка» between attempts.
struct TimeBlock: View {
  let s: ZeroStats
  var big: CGFloat = 40

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(s.text("smokeFree")).font(.system(size: 12, weight: .medium)).foregroundColor(s.color("muted"))
      Spacer(minLength: 4)
      if s.start == nil {
        Text(s.text("noAttempt")).font(.system(size: 20, weight: .heavy)).foregroundColor(s.color("primary"))
      } else {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
          Text(s.days).font(.system(size: big, weight: .black)).foregroundColor(s.color("primary"))
          Text(s.daysWord).font(.system(size: 15, weight: .medium)).foregroundColor(s.color("muted"))
        }
        .lineLimit(1).minimumScaleFactor(0.5)
        Text(s.clock).font(.system(size: 14, weight: .medium)).foregroundColor(s.color("muted")).lineLimit(1)
      }
      Spacer(minLength: 4)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

struct SosPill: View {
  let s: ZeroStats
  let title: String

  var body: some View {
    Text(title)
      .font(.system(size: 14, weight: .black)).tracking(0.5).lineLimit(1).minimumScaleFactor(0.6)
      .foregroundColor(s.color("onPrimary"))
      .frame(maxWidth: .infinity, minHeight: 36)
      .background(Capsule().fill(s.color("primary")))
  }
}

struct StatPill: View {
  let s: ZeroStats
  let label: String
  let value: String
  let valueColor: String
  let fill: String

  var body: some View {
    VStack(alignment: .leading, spacing: 1) {
      Text(label).font(.system(size: 12, weight: .medium)).foregroundColor(s.color("muted"))
      Text(value).font(.system(size: 18, weight: .black)).foregroundColor(s.color(valueColor))
    }
    .lineLimit(1).minimumScaleFactor(0.6)
    .padding(.horizontal, 12).padding(.vertical, 8)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(RoundedRectangle(cornerRadius: 14).fill(s.color(fill)))
  }
}

/// Before onboarding there is nothing to show yet: just the name, a tap opens the app.
struct EmptyZero: View {
  var body: some View {
    Text("Zero").font(.system(size: 24, weight: .black)).widgetBackground(Color(UIColor.systemBackground))
  }
}

struct ZeroWidgetView: View {
  enum Kind { case sos, timeSos, time, wide }

  let kind: Kind
  let entry: ZeroEntry
  @Environment(\.colorScheme) var scheme

  var body: some View {
    if let data = entry.data {
      let s = ZeroStats(data: data, now: entry.date, dark: scheme == .dark)
      switch kind {
      case .sos:
        VStack(spacing: 4) {
          Image(systemName: "wind").font(.system(size: 34, weight: .semibold))
          Text(s.text("sos")).font(.system(size: 30, weight: .black)).tracking(1)
          Text(s.text("sosShort")).font(.system(size: 14, weight: .medium)).multilineTextAlignment(.center)
        }
        .foregroundColor(s.color("onPrimary"))
        .widgetBackground(s.color("primary"))
        .widgetURL(sosURL)
      case .timeSos:
        // A small widget is one button on iPhone: all of it opens SOS.
        VStack(spacing: 0) {
          TimeBlock(s: s)
          SosPill(s: s, title: s.text("sos"))
        }
        .widgetBackground(s.color("card"))
        .widgetURL(sosURL)
      case .time:
        TimeBlock(s: s, big: 52).widgetBackground(s.color("card"))
      case .wide:
        HStack(spacing: 14) {
          VStack(spacing: 0) {
            TimeBlock(s: s)
            Link(destination: sosURL) { SosPill(s: s, title: s.text("sosLong")) }
          }
          VStack(spacing: 8) {
            StatPill(s: s, label: s.text("saved"), value: s.money, valueColor: "reward", fill: "rewardContainer")
            StatPill(
              s: s, label: s.text("notSmoked"), value: s.units, valueColor: "onPrimaryContainer", fill: "primaryContainer")
          }
        }
        .widgetBackground(s.color("card"))
      }
    } else {
      EmptyZero()
    }
  }
}

// Picker names: shown before Zero has run, so they live here rather than in the app's ARB strings.

struct SosWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "ZeroSos", provider: ZeroProvider()) { ZeroWidgetView(kind: .sos, entry: $0) }
      .configurationDisplayName("SOS")
      .description("Одно нажатие — и открывается SOS")
      .supportedFamilies([.systemSmall])
  }
}

struct TimeSosWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "ZeroTimeSos", provider: ZeroProvider()) { ZeroWidgetView(kind: .timeSos, entry: $0) }
      .configurationDisplayName("Время и SOS")
      .description("Время без курения; нажатие открывает SOS")
      .supportedFamilies([.systemSmall])
  }
}

struct TimeWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "ZeroTime", provider: ZeroProvider()) { ZeroWidgetView(kind: .time, entry: $0) }
      .configurationDisplayName("Время")
      .description("Время без курения")
      .supportedFamilies([.systemSmall])
  }
}

struct WideWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "ZeroWide", provider: ZeroProvider()) { ZeroWidgetView(kind: .wide, entry: $0) }
      .configurationDisplayName("Время, деньги и SOS")
      .description("Время без курения, сэкономленные деньги и кнопка SOS")
      .supportedFamilies([.systemMedium])
  }
}

@main
struct ZeroWidgets: WidgetBundle {
  var body: some Widget {
    SosWidget()
    TimeSosWidget()
    TimeWidget()
    WideWidget()
  }
}
