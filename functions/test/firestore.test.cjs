const {before, beforeEach, after, test} = require('node:test');
const fs = require('node:fs');
const path = require('node:path');
const {initializeTestEnvironment, assertSucceeds, assertFails} = require('@firebase/rules-unit-testing');
const {doc, setDoc, getDoc, updateDoc, serverTimestamp, Timestamp} = require('firebase/firestore');
let env;
before(async () => {
  env = await initializeTestEnvironment({projectId: 'demo-zero', firestore: {
    host: '127.0.0.1', port: 8087, rules: fs.readFileSync(path.join(__dirname, '../../firestore.rules'), 'utf8'),
  }});
});
beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'chats/alice_bob'), {members: ['alice', 'bob'], group: false, names: {alice: 'Alice', bob: 'Bob'}, last: {from: 'alice', text: 'Original', at: Timestamp.now()}, updatedAt: Timestamp.now()});
    await setDoc(doc(db, 'users/alice/friends/bob'), {code: 'BOBCODE1'});
    await setDoc(doc(db, 'users/bob/friends/alice'), {code: 'ALICE001'});
    await setDoc(doc(db, 'chats/alice_bob/messages/original'), {from: 'alice', text: 'Original', at: Timestamp.now()});
  });
});
after(async () => { await env?.cleanup(); });
const dbAs = (uid) => env.authenticatedContext(uid).firestore();

test('member replies with a verified quote; forged quotes and outsiders fail', async () => {
  const reply = {from: 'bob', text: 'Answer', at: serverTimestamp(), reply: {id: 'original', from: 'alice', text: 'Original'}};
  await assertSucceeds(setDoc(doc(dbAs('bob'), 'chats/alice_bob/messages/reply'), reply));
  await assertFails(setDoc(doc(dbAs('bob'), 'chats/alice_bob/messages/forged'), {...reply, reply: {...reply.reply, text: 'Forged'}}));
  await assertFails(setDoc(doc(dbAs('outsider'), 'chats/alice_bob/messages/intrusion'), {...reply, from: 'outsider'}));
});
test('only author edits text; author, timestamp and attachments stay immutable', async () => {
  const alice = doc(dbAs('alice'), 'chats/alice_bob/messages/original');
  await assertSucceeds(updateDoc(alice, {text: 'Edited', editedAt: serverTimestamp()}));
  await assertFails(updateDoc(doc(dbAs('bob'), 'chats/alice_bob/messages/original'), {text: 'Hijacked', editedAt: serverTimestamp()}));
  await assertFails(updateDoc(alice, {from: 'bob', text: 'Hijacked', editedAt: serverTimestamp()}));
  await assertFails(updateDoc(alice, {at: serverTimestamp(), editedAt: serverTimestamp()}));
  await assertFails(updateDoc(alice, {image: 'new attachment', editedAt: serverTimestamp()}));
  await assertFails(updateDoc(alice, {text: '', editedAt: serverTimestamp()}));
});
test('tokens are accessible only to their owner, including from friends', async () => {
  const device = 'users/alice/devices/phone';
  await assertSucceeds(setDoc(doc(dbAs('alice'), device), {token: 'test-token', platform: 'android', updatedAt: serverTimestamp()}));
  await assertSucceeds(getDoc(doc(dbAs('alice'), device)));
  await assertFails(getDoc(doc(dbAs('bob'), device)));
  await assertFails(setDoc(doc(dbAs('bob'), device), {token: 'attacker', platform: 'android', updatedAt: serverTimestamp()}));
});
test('notification aliases stay private and have bounded storage', async () => {
  const device = 'users/alice/devices/phone';
  const data = {token: 'test-token', platform: 'android', updatedAt: serverTimestamp(), aliasesJson: JSON.stringify({bob: 'Иван'})};
  await assertSucceeds(setDoc(doc(dbAs('alice'), device), data));
  await assertFails(getDoc(doc(dbAs('bob'), device)));
  await assertFails(updateDoc(doc(dbAs('bob'), device), {aliasesJson: '{}', updatedAt: serverTimestamp()}));
  await assertFails(setDoc(doc(dbAs('alice'), device), {...data, aliasesJson: {bob: 'Иван'}}));
  await assertFails(setDoc(doc(dbAs('alice'), device), {...data, aliasesJson: 'x'.repeat(50001)}));
});
