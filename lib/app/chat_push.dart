import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/social.dart';
import '../features/friends/chat_screen.dart';
import 'notifications.dart';

final chatPushRegistrationProvider = FutureProvider<void>((ref) async {
  final uid = ref.watch(myProfileProvider).value?.uid;
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android || uid == null) return;
  final messaging = FirebaseMessaging.instance;
  var disposed = false;
  String? previous;
  final devices = FirebaseFirestore.instance.collection('users').doc(uid).collection('devices');
  String deviceId(String token) => base64Url.encode(utf8.encode(token)).replaceAll('=', '');
  Future<void> save(String token) async {
    if (disposed) return;
    await devices.doc(deviceId(token)).set({
      'token': token,
      'platform': 'android',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    if (previous != null && previous != token) await devices.doc(deviceId(previous!)).delete();
    previous = token;
  }

  ref.onDispose(() => disposed = true);
  await Notifications.prepareChatChannel();
  final permission = await messaging.requestPermission();
  if (permission.authorizationStatus == AuthorizationStatus.denied || disposed) return;
  final subscription = messaging.onTokenRefresh.listen((token) => unawaited(save(token).catchError((_) {})));
  ref.onDispose(() => unawaited(subscription.cancel()));
  final token = await messaging.getToken();
  if (token != null) await save(token);
});

/// Notification taps wait for onboarding and the social profile before opening a chat.
class ChatPushSync extends ConsumerStatefulWidget {
  const ChatPushSync({super.key, required this.navigatorKey, required this.child});
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;
  @override
  ConsumerState<ChatPushSync> createState() => _ChatPushSyncState();
}

class _ChatPushSyncState extends ConsumerState<ChatPushSync> with WidgetsBindingObserver {
  StreamSubscription<RemoteMessage>? _opened;
  StreamSubscription<RemoteMessage>? _foreground;
  String? _pending;

  @override
  void initState() {
    super.initState();
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    WidgetsBinding.instance.addObserver(this);
    Notifications.onChatTap = _open;
    _opened = FirebaseMessaging.onMessageOpenedApp.listen((message) => _open(message.data['chatId']));
    _foreground = FirebaseMessaging.onMessage.listen((message) {
      final id = message.data['chatId'];
      if (id is String && id != ChatScreen.activeChatId) {
        unawaited(
          Notifications.showChat(
            id,
            message.notification?.title ?? '',
            message.notification?.body ?? '',
          ).catchError((_) {}),
        );
      }
    });
    unawaited(_initial());
  }

  Future<void> _initial() async {
    try {
      final remote = await FirebaseMessaging.instance.getInitialMessage();
      final local = await Notifications.chatLaunchPayload();
      if (mounted) _open(remote?.data['chatId'] ?? local);
    } catch (_) {
      /* A notification must never prevent normal startup. */
    }
  }

  void _open(Object? id) {
    if (!mounted || id is! String || !RegExp(r'^[A-Za-z0-9_-]{1,1500}$').hasMatch(id)) return;
    _pending = id;
    _flush();
  }

  void _flush() {
    if (_pending == null || ref.read(myProfileProvider).value == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _pending == null) return;
      final context = widget.navigatorKey.currentContext;
      if (context == null) return;
      final id = _pending!;
      _pending = null;
      if (ChatScreen.activeChatId != id) unawaited(ChatScreen.open(context, id));
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Notifications.onChatTap = null;
    unawaited(_opened?.cancel());
    unawaited(_foreground?.cancel());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) ref.invalidate(chatPushRegistrationProvider);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(chatPushRegistrationProvider);
    ref.listen(myProfileProvider, (_, next) {
      if (next.value != null) _flush();
    });
    return widget.child;
  }
}
