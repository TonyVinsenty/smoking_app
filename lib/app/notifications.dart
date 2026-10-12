import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../content/content.dart';
import '../data/providers.dart';
import '../data/settings.dart';
import '../l10n/app_localizations.dart';

/// Rare, supportive notifications: one per health milestone of the current attempt (from day 1 on),
/// scheduled ahead so they arrive with the app closed. Never at night.
class Notifications {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  /// Milestone notifications use their minute count (a day or more) as id.
  static const _diaryId = 1;

  static NotificationDetails _details({bool diary = false}) {
    final l = lookupAppLocalizations(const Locale('ru'));
    return NotificationDetails(
      android: AndroidNotificationDetails(
        diary ? 'diary' : 'milestones',
        diary ? l.diaryChannel : l.notificationChannel,
        channelDescription: diary ? l.diaryChannelHint : l.notificationChannelHint,
        importance: Importance.defaultImportance,
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }

  static Future<void> _init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  /// Asks for the permission (Android 13+ / iOS); the system shows the dialog only while it is allowed to.
  static Future<void> requestPermission() async {
    await _init();
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      sound: true,
    );
  }

  /// Replaces all pending notifications with the milestones still ahead of [startedAt] and the next
  /// «Дневник самочувствия» reminder at [diaryAt] (when overdue — the next such time of day).
  static Future<void> reschedule(DateTime? startedAt, List<HealthMilestone> milestones, {DateTime? diaryAt}) async {
    await _init();
    await _plugin.cancelAllPendingNotifications();
    if (diaryAt != null) {
      await requestPermission();
      var at = diaryAt;
      final now = DateTime.now();
      if (!at.isAfter(now)) {
        at = DateTime(now.year, now.month, now.day, at.hour, at.minute);
        if (!at.isAfter(now)) at = DateTime(now.year, now.month, now.day + 1, at.hour, at.minute);
      }
      final l = lookupAppLocalizations(const Locale('ru'));
      await _plugin.zonedSchedule(
        id: _diaryId,
        scheduledDate: tz.TZDateTime.from(at.toUtc(), tz.UTC),
        notificationDetails: _details(diary: true),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: l.diaryNotificationTitle,
        body: l.diaryNotificationBody,
      );
    }
    if (startedAt == null) return;
    await requestPermission();
    final now = DateTime.now();
    final seen = <int>{};
    for (final m in milestones) {
      // The first hours are covered by the home screen; several milestones at one moment → one notification.
      if (m.afterMinutes < 24 * 60 || !seen.add(m.afterMinutes)) continue;
      final at = daytime(startedAt.add(Duration(minutes: m.afterMinutes)));
      if (!at.isAfter(now)) continue;
      await _plugin.zonedSchedule(
        id: m.afterMinutes,
        scheduledDate: tz.TZDateTime.from(at.toUtc(), tz.UTC),
        notificationDetails: _details(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: m.title,
        body: m.description,
      );
    }
  }

  /// Moves a moment from the quiet hours (21:00–10:00) to the next 10:00. Android may deliver
  /// up to an hour late, so from 20:00 on it already counts as evening.
  static DateTime daytime(DateTime t) {
    if (t.hour >= 10 && t.hour < 20) return t;
    final morning = DateTime(t.year, t.month, t.day, 10);
    return t.hour < 10 ? morning : DateTime(t.year, t.month, t.day + 1, 10);
  }
}

/// Keeps the scheduled notifications in sync with the current attempt and the settings switch.
final notificationSchedulerProvider = FutureProvider<void>((ref) async {
  final enabled = ref.watch(notificationsEnabledProvider);
  final attempts = await ref.watch(attemptsProvider.future);
  final current = attempts.where((a) => a.endedAt == null).firstOrNull;
  final content = await ref.watch(contentProvider.future);
  final diary = ref.watch(diaryReminderProvider);
  final entries = await ref.watch(wellbeingProvider.future);
  await Notifications.reschedule(
    enabled ? current?.startedAt : null,
    content.milestones,
    diaryAt: diary.dueAt(entries.lastOrNull?.at),
  );
});
