const {initializeApp} = require('firebase-admin/app');
const {getFirestore} = require('firebase-admin/firestore');
const {getMessaging} = require('firebase-admin/messaging');
const {onDocumentCreated} = require('firebase-functions/v2/firestore');
const strings = require('./strings.ru.json');
initializeApp();

// Only creation triggers a push: edits and read markers never notify recipients.
exports.notifyChatMessage = onDocumentCreated({
  document: 'chats/{chatId}/messages/{messageId}', region: 'europe-west1',
  maxInstances: 2, minInstances: 0, memory: '256MiB', retry: false,
}, async (event) => {
  const message = event.data?.data();
  if (!message || message.sys) return;
  const db = getFirestore();
  const chatId = event.params.chatId;
  const chatRef = db.doc(`chats/${chatId}`);
  const [chatSnapshot, stillExists] = await Promise.all([chatRef.get(), event.data.ref.get()]);
  if (!chatSnapshot.exists || !stillExists.exists) return;
  const chat = chatSnapshot.data();
  if (!chat.members.includes(message.from)) return;
  const sender = chat.names?.[message.from] || strings.appTitle;
  const title = chat.group && chat.title ? `${sender} · ${chat.title}` : sender;
  const body = (message.text || strings.chatPhoto).slice(0, 180);
  for (const uid of chat.members.filter((id) => id !== message.from)) {
    const devices = await db.collection(`users/${uid}/devices`).where('platform', '==', 'android').get();
    for (let offset = 0; offset < devices.docs.length; offset += 500) {
      const chunk = devices.docs.slice(offset, offset + 500).filter((d) => typeof d.data().token === 'string');
      if (!chunk.length) continue;
      const result = await getMessaging().sendEachForMulticast({
        tokens: chunk.map((d) => d.data().token),
        notification: {title, body},
        data: {chatId, messageId: event.params.messageId},
        android: {priority: 'high', ttl: 24 * 60 * 60 * 1000,
          notification: {channelId: 'chat_messages', icon: 'ic_notification', tag: chatId, sound: 'default'}},
      });
      await Promise.all(result.responses.map((response, index) => {
        if (['messaging/registration-token-not-registered', 'messaging/invalid-registration-token'].includes(response.error?.code)) {
          return chunk[index].ref.delete();
        }
        return Promise.resolve();
      }));
    }
  }
});
