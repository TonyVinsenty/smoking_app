import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../content/content.dart';
import '../domain/stats.dart';
import 'chat.dart';
import 'providers.dart';
import 'settings.dart';

/// Friends leaderboard on Firebase. Server layout (see firestore.rules):
/// - `users/{uid}`: nick, friend code and only the stats the user chose to share;
/// - `users/{uid}/friends/{friendUid}`: one doc per friend, on both sides (friendship is mutual);
/// - `codes/{code}`: code → uid + nick, readable only by someone who already knows the code;
/// - `avatars/{uid}`: the profile photo (a small JPEG as base64), visible like the profile. Kept apart from it,
///   so the 5-minute stats sync does not resend the photo to every friend.

/// What a user may show to friends.
enum ShareField { xp, badges, days, money }

/// Shown by default: level/XP and badges; days and money stay private until switched on.
const defaultShare = {ShareField.xp, ShareField.badges};

class ShareSettingsNotifier extends Notifier<Set<ShareField>> {
  static const _key = 'social.share';

  @override
  Set<ShareField> build() {
    final saved = ref.watch(prefsProvider).getStringList(_key);
    if (saved == null) return defaultShare;
    return {
      for (final f in ShareField.values)
        if (saved.contains(f.name)) f,
    };
  }

  void toggle(ShareField f) {
    state = state.contains(f) ? ({...state}..remove(f)) : {...state, f};
    ref.read(prefsProvider).setStringList(_key, [for (final f in state) f.name]);
  }
}

final shareSettingsProvider = NotifierProvider<ShareSettingsNotifier, Set<ShareField>>(ShareSettingsNotifier.new);

/// A profile as stored on the server; hidden stats are null.
class SocialProfile {
  const SocialProfile({
    required this.uid,
    required this.nick,
    required this.code,
    this.xp,
    this.badges,
    this.days,
    this.money,
  });

  final String uid;
  final String nick;
  final String code;
  final int? xp;
  final int? badges;
  final int? days;
  final int? money;

  factory SocialProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return SocialProfile(
      uid: doc.id,
      nick: d['nick'] as String? ?? '',
      code: d['code'] as String? ?? '',
      xp: d['xp'] as int?,
      badges: d['badges'] as int?,
      days: d['days'] as int?,
      money: d['money'] as int?,
    );
  }

  int? value(ShareField f) => switch (f) {
    ShareField.xp => xp,
    ShareField.badges => badges,
    ShareField.days => days,
    ShareField.money => money,
  };

  /// Only the stats this person shows, in the usual order.
  Map<ShareField, int> get shared => {for (final f in ShareField.values) f: ?value(f)};
}

/// The user's own numbers, computed the same way as on the home screen.
class MyStats {
  const MyStats({required this.xp, required this.badges, required this.days, required this.money});

  final int xp;
  final int badges;
  final int days;
  final int money;

  int value(ShareField f) => switch (f) {
    ShareField.xp => xp,
    ShareField.badges => badges,
    ShareField.days => days,
    ShareField.money => money,
  };
}

final myStatsProvider = Provider<MyStats?>((ref) {
  final content = ref.watch(contentProvider).value;
  final attempts = ref.watch(attemptsProvider).value;
  final products = ref.watch(productsProvider).value;
  final cravings = ref.watch(cravingsProvider).value;
  final unlocked = ref.watch(unlockedAchievementsProvider).value;
  final now = ref.watch(nowProvider).value ?? DateTime.now();
  if (content == null || attempts == null || products == null || cravings == null || unlocked == null) return null;
  final xpById = {for (final a in content.achievements) a.id: a.xp};
  final ids = unlocked.map((u) => u.achievementId).toSet();
  final current = attempts.where((a) => a.endedAt == null).firstOrNull;
  final duration = current == null ? Duration.zero : attemptDuration(current, now);
  return MyStats(
    xp: totalXp(attempts: attempts, cravings: cravings, achievementXp: ids.map((id) => xpById[id] ?? 0), now: now),
    badges: ids.where(xpById.containsKey).length,
    days: duration.inDays,
    money: current == null ? 0 : moneySaved(productsOf(products, current.id), duration).floor(),
  );
});

/// The longest name; the server allows up to 40, so there is room for spaces trimmed differently.
const maxNickLength = 30;

/// Whatever the user typed → the name to save: no extra spaces, at most [maxNickLength] characters.
String cleanNick(String input) {
  final nick = input.trim().replaceAll(RegExp(r'\s+'), ' ');
  final runes = nick.runes;
  return runes.length > maxNickLength ? String.fromCharCodes(runes.take(maxNickLength)).trimRight() : nick;
}

final _db = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

DocumentReference<Map<String, dynamic>> _userDoc(String uid) => _db.collection('users').doc(uid);
CollectionReference<Map<String, dynamic>> _friendsOf(String uid) => _userDoc(uid).collection('friends');
DocumentReference<Map<String, dynamic>> _codeDoc(String code) => _db.collection('codes').doc(code);
DocumentReference<Map<String, dynamic>> _avatarDoc(String uid) => _db.collection('avatars').doc(uid);

/// The photo is a JPEG of at most this many bytes (the server checks the base64 text, a third longer).
const maxAvatarBytes = 120000;

final authUserProvider = StreamProvider<User?>((ref) => _auth.authStateChanges());

/// The user's own profile; null until they joined (or after deleting the account).
final myProfileProvider = StreamProvider<SocialProfile?>((ref) {
  final user = ref.watch(authUserProvider).value;
  if (user == null) return Stream.value(null);
  return _userDoc(user.uid).snapshots().map((d) => d.exists ? SocialProfile.fromDoc(d) : null);
});

final friendIdsProvider = StreamProvider<List<String>>((ref) {
  final user = ref.watch(authUserProvider).value;
  if (user == null) return Stream.value(const []);
  return _friendsOf(user.uid).snapshots().map((s) => [for (final d in s.docs) d.id]);
});

/// A friend's profile; null when it is gone (account deleted or friendship removed by them).
/// Reading is allowed only once their side of the friendship exists, so a denied read is retried for a while.
final friendProfileProvider = StreamProvider.family<SocialProfile?, String>(
  (ref, uid) => _userDoc(uid).snapshots().map((d) => d.exists ? SocialProfile.fromDoc(d) : null),
  retry: (tries, _) => tries < 12 ? Duration(seconds: min(30, 1 << tries)) : null,
);

/// Someone's photo (own or a friend's); null when there is none or it cannot be read.
final avatarProvider = StreamProvider.family<Uint8List?, String>(
  (ref, uid) => _avatarDoc(uid).snapshots().map((d) {
    final img = d.data()?['img'];
    return img is String ? base64Decode(img) : null;
  }),
  retry: (tries, _) => tries < 12 ? Duration(seconds: min(30, 1 << tries)) : null,
);

/// "K7M4Q2XP" → "K7M4-Q2XP"; with [partial], also an unfinished "K7M4Q" → "K7M4-Q".
String formatCode(String code, {bool partial = false}) =>
    code.length == 8 || (partial && code.length > 4) ? '${code.substring(0, 4)}-${code.substring(4)}' : code;

/// Whatever the user typed or pasted → "K7M4Q2XP".
String normalizeCode(String input) => input.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');

/// No 0/O, 1/I/L: easy to read aloud and retype.
const _codeAlphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

class FriendLookup {
  const FriendLookup(this.uid, this.nick, this.code);
  final String uid;
  final String nick;
  final String code;
}

enum AddFriendError { notFound, self, network }

class SocialService {
  SocialService(this.ref);

  final Ref ref;
  Map<String, Object>? _lastSent;
  DateTime? _lastSentAt;

  String? get _uid => _auth.currentUser?.uid;

  /// Signs in anonymously, reserves a fresh friend code and publishes the profile.
  Future<void> join(String nick) async {
    final user = _auth.currentUser ?? (await _auth.signInAnonymously()).user!;
    final rnd = Random.secure();
    for (var attempt = 0; ; attempt++) {
      final code = List.generate(8, (_) => _codeAlphabet[rnd.nextInt(_codeAlphabet.length)]).join();
      try {
        // Fails if the code is taken: codes can only be created, never overwritten.
        await _codeDoc(code).set({'uid': user.uid, 'nick': nick});
        await _userDoc(user.uid).set(_payload(nick, code));
        return;
      } on FirebaseException {
        if (attempt >= 4) rethrow;
      }
    }
  }

  Future<void> changeNick(String nick) async {
    final me = ref.read(myProfileProvider).value;
    if (me == null) return;
    await _codeDoc(me.code).update({'nick': nick});
    await sync(force: true, nick: nick);
  }

  Future<void> setAvatar(Uint8List jpeg) async {
    final uid = _uid;
    if (uid == null || jpeg.length > maxAvatarBytes) return;
    await _avatarDoc(uid).set({'img': base64Encode(jpeg), 'at': FieldValue.serverTimestamp()});
    // The listener may have given up earlier (e.g. no connection); start it again to show the new photo.
    ref.invalidate(avatarProvider(uid));
  }

  Future<void> removeAvatar() async {
    final uid = _uid;
    if (uid == null) return;
    await _avatarDoc(uid).delete();
    ref.invalidate(avatarProvider(uid));
  }

  Future<FriendLookup?> lookup(String code) async {
    final doc = await _codeDoc(code).get();
    final d = doc.data();
    if (d == null) return null;
    return FriendLookup(d['uid'] as String, d['nick'] as String? ?? '', code);
  }

  /// Adds the friend on both sides; the server checks the code to allow writing into their list.
  Future<AddFriendError?> addFriend(String code) async {
    final me = ref.read(myProfileProvider).value;
    final uid = _uid;
    if (me == null || uid == null) return AddFriendError.network;
    if (code == me.code) return AddFriendError.self;
    try {
      final found = await lookup(code);
      if (found == null) return AddFriendError.notFound;
      final batch = _db.batch()
        ..set(_friendsOf(uid).doc(found.uid), {'code': found.code, 'at': FieldValue.serverTimestamp()})
        ..set(_friendsOf(found.uid).doc(uid), {'code': found.code, 'at': FieldValue.serverTimestamp()});
      await batch.commit();
      return null;
    } on FirebaseException {
      return AddFriendError.network;
    }
  }

  Future<void> removeFriend(String friendUid) async {
    final uid = _uid;
    if (uid == null) return;
    final batch = _db.batch()
      ..delete(_friendsOf(uid).doc(friendUid))
      ..delete(_friendsOf(friendUid).doc(uid));
    await batch.commit();
  }

  /// Erases everything on the server: own chat messages and chat memberships, friendships on both sides,
  /// the code, the photo, the profile, the sign-in.
  Future<void> deleteAccount() async {
    final uid = _uid;
    if (uid == null) return;
    await ref.read(chatServiceProvider).leaveAll();
    final me = ref.read(myProfileProvider).value;
    final friends = await _friendsOf(uid).get();
    final batch = _db.batch();
    for (final f in friends.docs) {
      batch
        ..delete(f.reference)
        ..delete(_friendsOf(f.id).doc(uid));
    }
    if (me != null) batch.delete(_codeDoc(me.code));
    batch
      ..delete(_avatarDoc(uid))
      ..delete(_userDoc(uid));
    await batch.commit();
    _lastSent = null;
    await _auth.currentUser?.delete();
  }

  /// Publishes the shared stats when they changed: right away when [force]d (settings changed),
  /// otherwise at most every 5 minutes so the live money counter does not write every second.
  Future<void> sync({bool force = false, String? nick}) async {
    final me = ref.read(myProfileProvider).value;
    final uid = _uid;
    if (me == null || uid == null) return;
    final payload = _payload(nick ?? me.nick, me.code);
    final now = DateTime.now();
    final same = _lastSent != null && _mapEquals(_lastSent!, payload);
    if (same && nick == null) return;
    if (!force && _lastSentAt != null && now.difference(_lastSentAt!) < const Duration(minutes: 5)) return;
    _lastSent = payload;
    _lastSentAt = now;
    // A full overwrite, so a stat that was switched off disappears from the server.
    await _userDoc(uid).set({...payload, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Map<String, Object> _payload(String nick, String code) {
    final stats = ref.read(myStatsProvider);
    final share = ref.read(shareSettingsProvider);
    return {
      'nick': nick,
      'code': code,
      if (stats != null)
        for (final f in share) f.name: stats.value(f),
    };
  }

  static bool _mapEquals(Map<String, Object> a, Map<String, Object> b) =>
      a.length == b.length && a.entries.every((e) => b[e.key] == e.value);
}

final socialServiceProvider = Provider<SocialService>(SocialService.new);

/// Keeps the server copy of the shared stats fresh while the app runs (watched by HomeShell).
final socialSyncProvider = Provider<void>((ref) {
  final service = ref.read(socialServiceProvider);
  void run({bool force = false}) => unawaited(service.sync(force: force).catchError((_) {}));
  ref.listen(myStatsProvider, (_, _) => run());
  ref.listen(shareSettingsProvider, (_, _) => run(force: true));
  ref.listen(myProfileProvider, (prev, next) {
    if (prev?.value == null && next.value != null) run(force: true);
  });
});
