import {test} from 'node:test';
import assert from 'node:assert/strict';
import {DatabaseSync} from 'node:sqlite';
import {readFileSync} from 'node:fs';
import worker, {poll} from '../src/index.mjs';

const project = 'zero-91cc8';
const root = `projects/${project}/databases/(default)/documents`;
const now = Date.parse('2026-11-06T10:00:00Z');
const stamp = '2026-11-06T09:59:40.123456789Z';
const str = (value) => ({stringValue: value});
function fixture({withCursor = true, people = ['alice', 'bob'], source = 'alice', system = false, failure, aliasByUser = {}, group = false, groupTitle = ''} = {}) {
  const sqlite = new DatabaseSync(':memory:');
  sqlite.exec(readFileSync(new URL('../schema.sql', import.meta.url), 'utf8'));
  function statement(sql, values = []) {
    return {bind: (...args) => statement(sql, args), first: async () => sqlite.prepare(sql).get(...values) ?? null, run: async () => sqlite.prepare(sql).run(...values)};
  }
  if (withCursor) sqlite.prepare('INSERT INTO state VALUES(?, ?)').run('cursor', JSON.stringify({at: '2026-11-06T09:59:00Z'}));
  const message = {name: `${root}/chats/chat/messages/m1`, fields: {from: str(source), text: str('hello'), at: {timestampValue: stamp}, ...(system ? {sys: str('created')} : {})}};
  const sent = [];
  const queries = [];
  const env = {PUSH_ENABLED: 'true', FIREBASE_PROJECT_ID: project, DB: {prepare: statement}};
  const options = {now, credentials: {project_id: project}, accessToken: 'fake', fetch: async (url, init) => {
    const body = init.body ? JSON.parse(init.body) : null;
    if (url.endsWith('/documents:runQuery')) {
      queries.push(body.structuredQuery);
      return Response.json(body.structuredQuery.startAt?.values[1]?.referenceValue === message.name ? [] : [{document: message}]);
    }
    if (url.endsWith('/documents/chats/chat')) return Response.json({fields: {group: {booleanValue: group}, title: str(groupTitle), members: {arrayValue: {values: people.map(str)}}, names: {mapValue: {fields: {alice: str('Alice')}}}}});
    if (/\/users\/[^/]+:runQuery$/.test(url)) {
      const uid = url.split('/users/')[1].split(':')[0];
      return Response.json([{document: {name: `${root}/users/${uid}/devices/phone`, fields: {platform: str('android'), token: str(`token-${uid}`), aliasesJson: str(aliasByUser[uid] ?? '{}')}}}]);
    }
    if (url.includes('fcm.googleapis.com')) {
      sent.push(body.message);
      if (failure) return Response.json(failure.body, {status: failure.status});
      return Response.json({name: 'sent'});
    }
    throw new Error('Unexpected request');
  }};
  return {env, options, sqlite, message, sent, queries};
}

test('first poll initializes at current time without sending chat history', async () => {
  const f = fixture({withCursor: false});
  assert.deepEqual(await poll(f.env, f.options), {initialized: true});
  assert.equal(f.sent.length, 0);
  assert.equal(f.queries.length, 0);
  f.sqlite.close();
});
test('only recipients receive the message; exact nanosecond cursor and name are preserved', async () => {
  const f = fixture();
  assert.equal((await poll(f.env, f.options)).sent, 1);
  assert.equal(f.sent[0].token, 'token-bob');
  assert.equal(f.sent[0].data.chatId, 'chat');
  assert.equal(f.sent[0].notification.title, 'Alice');
  assert.equal((await poll(f.env, f.options)).sent, 0);
  assert.deepEqual(f.queries[1].startAt, {before: false, values: [{timestampValue: stamp}, {referenceValue: f.message.name}]});
  f.sqlite.close();
});
test('request budget resumes partial fanout without resending completed deliveries', async () => {
  const f = fixture({people: ['alice', 'bob', 'charlie']});
  assert.equal((await poll(f.env, {...f.options, callLimit: 4})).sent, 1);
  assert.equal((await poll(f.env, f.options)).sent, 1);
  assert.deepEqual(f.sent.map((m) => m.token), ['token-bob', 'token-charlie']);
  f.sqlite.close();
});
test('transient FCM failure retains cursor and releases lock for retry', async () => {
  const f = fixture({failure: {status: 429, body: {error: {status: 'RESOURCE_EXHAUSTED'}}}});
  await assert.rejects(poll(f.env, f.options), /FCM request failed \(429\)/);
  assert.equal(f.sqlite.prepare('SELECT COUNT(*) AS n FROM poll_lock').get().n, 0);
  assert.equal(JSON.parse(f.sqlite.prepare("SELECT value FROM state WHERE key='cursor'").get().value).name, undefined);
  f.sqlite.close();
});
test('D1 query budget pauses before sending without space for a delivery receipt', async () => {
  const f = fixture({people: ['alice', 'bob', 'charlie']});
  assert.equal((await poll(f.env, {...f.options, dbLimit: 6})).sent, 1);
  assert.equal((await poll(f.env, f.options)).sent, 1);
  assert.deepEqual(f.sent.map((m) => m.token), ['token-bob', 'token-charlie']);
  f.sqlite.close();
});
test('expired tokens do not permanently block the message cursor', async () => {
  const f = fixture({failure: {status: 404, body: {error: {details: [{errorCode: 'UNREGISTERED'}]}}}});
  assert.equal((await poll(f.env, f.options)).processed, 1);
  assert.equal((await poll(f.env, f.options)).processed, 0);
  f.sqlite.close();
});
test('group events and messages from former members do not notify', async () => {
  for (const settings of [{system: true}, {source: 'former-member'}]) {
    const f = fixture(settings);
    assert.equal((await poll(f.env, f.options)).processed, 1);
    assert.equal(f.sent.length, 0);
    f.sqlite.close();
  }
});
test('public HTTP requests cannot trigger polling or send notifications', async () => {
  assert.equal((await worker.fetch(new Request('https://example.com/send'))).status, 404);
});
test('each recipient sees their own alias, with public-name fallback', async () => {
  const f = fixture({people: ['alice', 'bob', 'charlie'], aliasByUser: {bob: JSON.stringify({alice: 'Иван'})}});
  await poll(f.env, f.options);
  assert.deepEqual(f.sent.map((m) => m.notification.title), ['Иван', 'Alice']);
  assert.equal(f.sent[0].notification.body, 'hello');
  f.sqlite.close();
});
test('group title includes the per-recipient alias in parentheses', async () => {
  const f = fixture({group: true, groupTitle: 'Наш чат', aliasByUser: {bob: JSON.stringify({alice: 'Иван'})}});
  await poll(f.env, f.options);
  assert.equal(f.sent[0].notification.title, 'Наш чат (Иван)');
  assert.equal(f.sent[0].notification.body, 'hello');
  f.sqlite.close();
});
test('empty, malformed and non-string aliases fall back without breaking delivery', async () => {
  for (const value of ['not json', '{"alice":42}', '{"alice":"  "}', 'null']) {
    const f = fixture({group: true, aliasByUser: {bob: value}});
    await poll(f.env, f.options);
    assert.equal(f.sent[0].notification.title, 'Групповой чат (Alice)');
    f.sqlite.close();
  }
});
