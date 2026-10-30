import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings.dart';
import 'social.dart';

/// Chats between friends: one-to-one and groups of up to [maxChatMembers]. Text and emoji only.
/// Server layout: chats/{id} (members, names, the last message for the list) and chats/{id}/messages/{id}.
/// A one-to-one chat has a fixed id built from both uids, so there is never a second one.

const maxChatMembers = 5;
const maxMessageLength = 1000;
const maxGroupTitleLength = 40;
const maxChatImageBytes = 220000;

/// Events in a group, shown as a grey line instead of a bubble.
enum ChatEvent { created, added, left, renamed }

final _db = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

CollectionReference<Map<String, dynamic>> get _chats => _db.collection('chats');
CollectionReference<Map<String, dynamic>> _messagesOf(String chatId) => _chats.doc(chatId).collection('messages');

/// A server time is null while the user's own write has not reached the server yet.
Map<String, dynamic> _data(DocumentSnapshot<Map<String, dynamic>> d) => d.data() ?? const {};

DateTime? _time(Object? v) => v is Timestamp ? v.toDate() : null;

ChatEvent? _event(Object? v) => ChatEvent.values.where((e) => e.name == v).firstOrNull;

String directChatId(String a, String b) => a.compareTo(b) < 0 ? '${a}_$b' : '${b}_$a';

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.from,
    required this.text,
    this.at,
    this.event,
    this.image,
    this.pending = false,
    this.failed = false,
  });

  factory ChatMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = _data(d);
    return ChatMessage(
      id: d.id,
      from: m['from'] as String? ?? '',
      text: m['text'] as String? ?? '',
      at: _time(m['at']),
      event: _event(m['sys']),
      image: m['image'] as String?,
      pending: d.metadata.hasPendingWrites,
    );
  }

  final String id;
  final String from;

  /// The message; for an event — the names added or the new group title.
  final String text;
  final DateTime? at;
  final ChatEvent? event;
  final String? image;
  final bool pending;
  final bool failed;

  Uint8List? get imageBytes {
    final value = image;
    if (value == null) return null;
    try {
      return base64Decode(value);
    } catch (_) {
      return null;
    }
  }
}

class Chat {
  const Chat({
    required this.id,
    required this.members,
    required this.group,
    required this.names,
    this.title,
    this.last,
  });

  factory Chat.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = _data(d);
    final last = m['last'];
    return Chat(
      id: d.id,
      members: [for (final u in m['members'] as List? ?? const []) u as String],
      group: m['group'] == true,
      names: {for (final MapEntry(:key, :value) in (m['names'] as Map? ?? const {}).entries) '$key': '$value'},
      title: m['title'] as String?,
      last: last is Map
          ? ChatMessage(
              id: '',
              from: last['from'] as String? ?? '',
              text: last['text'] as String? ?? '',
              at: _time(last['at']),
              event: _event(last['sys']),
            )
          : null,
    );
  }

  final String id;
  final List<String> members;
  final bool group;

  /// Names as last written by each person (also of those who left): a group may include people
  /// who are not the user's friends, and their profiles cannot be read.
  final Map<String, String> names;
  final String? title;
  final ChatMessage? last;

  /// The other person of a one-to-one chat (also after they left it by deleting their account).
  String? otherThan(String me) =>
      group ? null : members.where((u) => u != me).firstOrNull ?? names.keys.where((u) => u != me).firstOrNull;
}

/// All chats the user is in, the latest conversation first.
final chatsProvider = StreamProvider<List<Chat>>((ref) {
  final user = ref.watch(authUserProvider).value;
  if (user == null) return Stream.value(const []);
  return _chats.where('members', arrayContains: user.uid).snapshots().map((s) {
    final chats = [for (final d in s.docs) Chat.fromDoc(d)];
    // Not yet on the server = just sent, so the newest.
    final now = DateTime(3000);
    return chats..sort((a, b) => (b.last?.at ?? now).compareTo(a.last?.at ?? now));
  });
});

/// One chat; null while a one-to-one chat has no messages yet (it is created with the first one).
final chatProvider = StreamProvider.family<Chat?, String>(
  (ref, id) => _chats.doc(id).snapshots().map((d) => d.exists ? Chat.fromDoc(d) : null),
);

/// The newest [limit] messages of a chat, newest first; the screen raises the limit when scrolled up.
final messagesProvider = StreamProvider.family<List<ChatMessage>, ({String chatId, int limit})>(
  (ref, key) =>
      _messagesOf(key.chatId)
          .orderBy('at', descending: true)
          .limit(key.limit)
          .snapshots()
          .map((s) => [for (final d in s.docs) ChatMessage.fromDoc(d)]),
);

/// Per-member server read markers. A sender can see the marker only for people in this chat.
final chatReadsProvider = StreamProvider.family<Map<String, DateTime>, String>((ref, chatId) {
  final me = ref.watch(authUserProvider).value?.uid;
  if (me == null) return Stream.value(const {});
  return _chats.doc(chatId).collection('reads').snapshots().map((s) {
    return {
      for (final d in s.docs)
        if (_time(d.data()['at']) case final at?) d.id: at,
    };
  });
});

/// When the user last saw each chat (time of the last message they saw), kept on the phone.
class ChatReadNotifier extends Notifier<Map<String, DateTime>> {
  static const _key = 'chat_read';

  @override
  Map<String, DateTime> build() {
    final raw = ref.watch(prefsProvider).getString(_key);
    if (raw == null) return const {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return {for (final e in map.entries) e.key: DateTime.fromMicrosecondsSinceEpoch(e.value as int)};
  }

  void markRead(String chatId, DateTime at) {
    final seen = state[chatId];
    if (seen != null && !at.isAfter(seen)) return;
    state = {...state, chatId: at};
    ref
        .read(prefsProvider)
        .setString(_key, jsonEncode({for (final e in state.entries) e.key: e.value.microsecondsSinceEpoch}));
  }
}

final chatReadProvider = NotifierProvider<ChatReadNotifier, Map<String, DateTime>>(ChatReadNotifier.new);

/// Messages from others the user has not seen yet in a chat (up to 99). A friend leaving a one-to-one chat
/// (deleting their account) leaves no message, so it is not counted.
final unreadCountProvider = StreamProvider.family<int, String>((ref, chatId) {
  final me = ref.watch(authUserProvider).value?.uid;
  final chat = ref.watch(chatsProvider.select((c) => c.value?.where((c) => c.id == chatId).firstOrNull));
  final seen = ref.watch(chatReadProvider.select((r) => r[chatId]));
  final last = chat?.last;
  if (me == null ||
      last == null ||
      last.from == me ||
      (!(chat?.group ?? true) && last.event == ChatEvent.left) ||
      last.at == null ||
      (seen != null && !last.at!.isAfter(seen))) {
    return Stream.value(0);
  }
  Query<Map<String, dynamic>> query = _messagesOf(chatId);
  if (seen != null) {
    query = query.where('at', isGreaterThan: Timestamp.fromMicrosecondsSinceEpoch(seen.microsecondsSinceEpoch));
  }
  query = query.orderBy('at').limit(99);
  // At least one: the last message is known to be new even if the query is not answered yet.
  return query.snapshots().map(
    (s) => [for (final d in s.docs) d.data()['from']].where((f) => f != me).length.clamp(1, 99),
  );
});

/// Unread messages in all chats, for the badge on the «Друзья» tab.
final totalUnreadProvider = Provider<int>((ref) {
  final chats = ref.watch(chatsProvider).value ?? const [];
  return chats.fold(0, (total, c) => total + (ref.watch(unreadCountProvider(c.id)).value ?? 0));
});

class ChatService {
  ChatService(this.ref);

  final Ref ref;

  String get _me => _auth.currentUser!.uid;
  String get _myNick => ref.read(myProfileProvider).value?.nick ?? '';

  Future<void> deleteMessage(String chatId, String messageId, String deletedPreview) async {
    final message = _messagesOf(chatId).doc(messageId);
    final chat = _chats.doc(chatId);
    await _db.runTransaction((transaction) async {
      final messageSnapshot = await transaction.get(message);
      if (!messageSnapshot.exists) return;
      final chatSnapshot = await transaction.get(chat);
      final data = chatSnapshot.data();
      final last = data?['last'];
      final messageAt = messageSnapshot.data()?['at'];
      final lastAt = last is Map ? last['at'] : null;
      final lastIsDeletedMessage =
          last is Map &&
          last['from'] == _me &&
          messageAt is Timestamp &&
          lastAt is Timestamp &&
          lastAt.seconds == messageAt.seconds &&
          lastAt.nanoseconds == messageAt.nanoseconds;
      transaction.delete(message);
      if (lastIsDeletedMessage) {
        transaction.update(chat, {
          'last': {'from': _me, 'text': deletedPreview, 'at': last['at']},
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Map<String, Object> _last(String text, [ChatEvent? event]) => {
    'from': _me,
    'text': text.length > 200 ? text.substring(0, 200) : text,
    'at': FieldValue.serverTimestamp(),
    'sys': ?event?.name,
  };

  Map<String, Object> _message(String text, [ChatEvent? event, String? image]) => {
    'from': _me,
    'text': text,
    'at': FieldValue.serverTimestamp(),
    'sys': ?event?.name,
    if (image != null) 'image': image,
  };

  /// Sends a message; the first message to a friend also creates the one-to-one chat ([friend] and their name).
  Future<String> send(
    String chatId,
    String text, {
    Chat? chat,
    (String uid, String nick)? friend,
    String? image,
  }) async {
    final messageRef = _messagesOf(chatId).doc();
    final preview = image == null ? text : (text.isEmpty ? '📷 Фото' : text);
    final batch = _db.batch()..set(messageRef, _message(text, null, image));
    if (chat == null && friend != null) {
      final (uid, nick) = friend;
      batch.set(_chats.doc(chatId), {
        'members': [_me, uid]..sort(),
        'group': false,
        'names': {_me: _myNick, uid: nick},
        'last': _last(preview),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      batch.update(_chats.doc(chatId), {
        'last': _last(preview),
        'names.$_me': _myNick,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    return messageRef.id;
  }

  Future<void> markRead(String chatId) async {
    final uid = _me;
    await _chats.doc(chatId).collection('reads').doc(uid).set({'at': FieldValue.serverTimestamp()});
  }

  /// A new group with the given friends; returns its id.
  Future<String> createGroup(Map<String, String> friends, String title) async {
    final ref = _chats.doc();
    final batch = _db.batch()
      ..set(ref, {
        'members': [_me, ...friends.keys],
        'group': true,
        if (title.isNotEmpty) 'title': title,
        'names': {_me: _myNick, ...friends},
        'last': _last(title, ChatEvent.created),
        'updatedAt': FieldValue.serverTimestamp(),
      })
      ..set(_messagesOf(ref.id).doc(), _message(title, ChatEvent.created));
    await batch.commit();
    return ref.id;
  }

  /// Adds the user's friends ([uid] → name) to a group.
  Future<void> addMembers(Chat chat, Map<String, String> friends) async {
    final names = friends.values.join(', ');
    final batch = _db.batch()
      ..update(_chats.doc(chat.id), {
        'members': FieldValue.arrayUnion(friends.keys.toList()),
        for (final MapEntry(:key, :value) in friends.entries) 'names.$key': value,
        'last': _last(names, ChatEvent.added),
        'updatedAt': FieldValue.serverTimestamp(),
      })
      ..set(_messagesOf(chat.id).doc(), _message(names, ChatEvent.added));
    await batch.commit();
  }

  Future<void> rename(Chat chat, String title) async {
    final batch = _db.batch()
      ..update(_chats.doc(chat.id), {
        'title': title.isEmpty ? FieldValue.delete() : title,
        'last': _last(title, ChatEvent.renamed),
        'updatedAt': FieldValue.serverTimestamp(),
      })
      ..set(_messagesOf(chat.id).doc(), _message(title, ChatEvent.renamed));
    await batch.commit();
  }

  /// Leaves a chat; the user's messages stay. The last one to leave a group removes it completely.
  Future<void> leave(Chat chat) async {
    final myReadRef = _chats.doc(chat.id).collection('reads').doc(_me);
    if (chat.members.length <= 1) {
      final messages = await _messagesOf(chat.id).get();
      final reads = await _chats.doc(chat.id).collection('reads').get();
      await _deleteAll([for (final d in messages.docs) d.reference, for (final d in reads.docs) d.reference]);
      await _chats.doc(chat.id).delete();
      return;
    }
    final batch = _db.batch()
      ..delete(myReadRef)
      ..update(_chats.doc(chat.id), {
        'members': FieldValue.arrayRemove([_me]),
        'last': _last('', ChatEvent.left),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    if (chat.group) batch.set(_messagesOf(chat.id).doc(), _message('', ChatEvent.left));
    await batch.commit();
  }

  /// For deleting the account: erases the user's messages and leaves every chat.
  Future<void> leaveAll() async {
    final chats = await _chats.where('members', arrayContains: _me).get();
    for (final d in chats.docs) {
      final chat = Chat.fromDoc(d);
      final mine = await _messagesOf(chat.id).where('from', isEqualTo: _me).get();
      await _deleteAll([for (final m in mine.docs) m.reference]);
      await leave(chat);
    }
  }

  Future<void> _deleteAll(List<DocumentReference> refs) async {
    for (var i = 0; i < refs.length; i += 400) {
      final batch = _db.batch();
      for (final r in refs.skip(i).take(400)) {
        batch.delete(r);
      }
      await batch.commit();
    }
  }
}

final chatServiceProvider = Provider<ChatService>(ChatService.new);
