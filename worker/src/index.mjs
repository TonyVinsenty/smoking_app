import strings from './strings.ru.json' with {type: 'json'};

class PollLimit extends Error {}
let cachedToken;
const text = (v) => v?.stringValue ?? '';
const members = (chat) => (chat.fields?.members?.arrayValue?.values ?? []).map(text);
const b64 = (data) => btoa(typeof data === 'string' ? data : String.fromCharCode(...new Uint8Array(data))).replaceAll('+', '-').replaceAll('/', '_').replaceAll('=', '');

async function accessToken(credentials, request) {
  const keyId = credentials.private_key_id;
  if (cachedToken?.keyId === keyId && cachedToken.expires > Date.now() + 60000) return cachedToken.value;
  const now = Math.floor(Date.now() / 1000);
  const header = b64(JSON.stringify({alg: 'RS256', typ: 'JWT', kid: keyId}));
  const claims = b64(JSON.stringify({iss: credentials.client_email, scope: 'https://www.googleapis.com/auth/datastore https://www.googleapis.com/auth/firebase.messaging', aud: 'https://oauth2.googleapis.com/token', iat: now, exp: now + 3600}));
  const pem = credentials.private_key.replace(/-----[^-]+-----|\s/g, '');
  const key = await crypto.subtle.importKey('pkcs8', Uint8Array.from(atob(pem), (c) => c.charCodeAt(0)), {name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256'}, false, ['sign']);
  const signed = `${header}.${claims}`;
  const signature = await crypto.subtle.sign('RSASSA-PKCS1-v1_5', key, new TextEncoder().encode(signed));
  const response = await request('https://oauth2.googleapis.com/token', {method: 'POST', body: new URLSearchParams({grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer', assertion: `${signed}.${b64(signature)}`})});
  if (!response.ok) throw new Error(`Google authorization failed (${response.status})`);
  const result = await response.json();
  cachedToken = {keyId, value: result.access_token, expires: Date.now() + result.expires_in * 1000};
  return cachedToken.value;
}

async function hash(value) {
  return Array.from(new Uint8Array(await crypto.subtle.digest('SHA-256', new TextEncoder().encode(value))), (b) => b.toString(16).padStart(2, '0')).join('');
}

// A cron-only sender. There is no public HTTP endpoint capable of sending notifications.
export default {
  fetch() { return new Response('Not found', {status: 404}); },
  async scheduled(_event, env, ctx) {
    ctx.waitUntil(poll(env).catch((error) => { console.error('Chat poll failed:', error.message); throw error; }));
  },
};

export async function poll(env, options = {}) {
  if (env.PUSH_ENABLED !== 'true') return {disabled: true};
  const now = options.now ?? Date.now();
  const owner = crypto.randomUUID();
  const lock = await env.DB.prepare('INSERT INTO poll_lock(id, owner, expires) VALUES(1, ?, ?) ON CONFLICT(id) DO UPDATE SET owner=excluded.owner, expires=excluded.expires WHERE poll_lock.expires < ? RETURNING id').bind(owner, now + 120000, now).first();
  if (!lock) return {locked: true};
  try { return await runPoll(env, options, now); }
  finally { await env.DB.prepare('DELETE FROM poll_lock WHERE owner = ?').bind(owner).run(); }
}

async function runPoll(env, options, now) {
  const cursorRow = await env.DB.prepare("SELECT value FROM state WHERE key = 'cursor'").first();
  if (!cursorRow) {
    await env.DB.prepare("INSERT INTO state(key, value) VALUES('cursor', ?)").bind(JSON.stringify({at: new Date(now).toISOString()})).run();
    return {initialized: true}; // Never notify the entire chat history on first deployment.
  }
  let cursor = JSON.parse(cursorRow.value);
  let calls = 0;
  let dbCalls = 2; // Lease acquisition and cursor read; reserve capacity for cleanup and release.
  const dbLimit = options.dbLimit ?? 45;
  const store = async (sql, values, method) => {
    if (dbCalls >= dbLimit) throw new PollLimit();
    dbCalls++;
    return env.DB.prepare(sql).bind(...values)[method]();
  };
  const deadline = Date.now() + 80000;
  const request = async (url, init = {}) => {
    if (calls >= (options.callLimit ?? 40) || Date.now() >= deadline) throw new PollLimit();
    calls++;
    return (options.fetch ?? fetch)(url, {...init, signal: AbortSignal.timeout(Math.min(8000, deadline - Date.now()))});
  };
  const project = env.FIREBASE_PROJECT_ID;
  const credentials = options.credentials ?? JSON.parse(env.GOOGLE_SERVICE_ACCOUNT);
  if (credentials.project_id !== project) throw new Error('Wrong Firebase project');
  const token = options.accessToken ?? await accessToken(credentials, request);
  const headers = {Authorization: `Bearer ${token}`, 'Content-Type': 'application/json'};
  const root = `https://firestore.googleapis.com/v1/projects/${project}/databases/(default)/documents`;
  const api = async (path, body) => {
    const response = await request(root + path, {method: body ? 'POST' : 'GET', headers, ...(body ? {body: JSON.stringify(body)} : {})});
    if (response.status === 404) return null;
    if (!response.ok) throw new Error(`Firestore request failed (${response.status})`);
    return response.json();
  };
  const query = {
    select: {fields: ['from', 'text', 'at', 'sys'].map((fieldPath) => ({fieldPath}))},
    from: [{collectionId: 'messages', allDescendants: true}],
    where: {fieldFilter: {field: {fieldPath: 'at'}, op: 'GREATER_THAN_OR_EQUAL', value: {timestampValue: cursor.at}}},
    orderBy: [{field: {fieldPath: 'at'}, direction: 'ASCENDING'}, {field: {fieldPath: '__name__'}, direction: 'ASCENDING'}], limit: 20,
    ...(cursor.name ? {startAt: {values: [{timestampValue: cursor.at}, {referenceValue: cursor.name}], before: false}} : {}),
  };
  const rows = await api(':runQuery', {structuredQuery: query});
  const chats = new Map();
  const devices = new Map();
  let sent = 0;
  let processed = 0;
  try {
    for (const row of rows ?? []) {
      const message = row.document;
      if (!message) continue;
      const at = message.fields?.at?.timestampValue;
      if (!at) throw new Error('Message timestamp missing');
      const parts = message.name.split('/');
      const validPath = parts.length === 9 && parts[5] === 'chats' && parts[7] === 'messages';
      if (validPath && !message.fields.sys && Date.parse(at) >= now - 86400000) {
        const chatId = parts[6];
        if (!chats.has(chatId)) chats.set(chatId, await api(`/chats/${encodeURIComponent(chatId)}`));
        const chat = chats.get(chatId);
        const from = text(message.fields.from);
        const group = chat?.fields?.group?.booleanValue;
        const chatMembers = chat ? members(chat) : [];
        if (chatMembers.includes(from)) {
          const sender = text(chat.fields.names?.mapValue?.fields?.[from]) || strings.appTitle;
          const title = group && text(chat.fields.title) ? `${sender} · ${text(chat.fields.title)}` : sender;
          for (const uid of chatMembers.filter((id) => id !== from)) {
            if (!devices.has(uid)) {
              const list = await api(`/users/${encodeURIComponent(uid)}:runQuery`, {structuredQuery: {from: [{collectionId: 'devices'}], orderBy: [{field: {fieldPath: 'updatedAt'}, direction: 'DESCENDING'}], limit: 10}});
              devices.set(uid, (list ?? []).map((r) => r.document).filter((d) => d && text(d.fields?.platform) === 'android' && text(d.fields?.token)));
            }
            for (const device of devices.get(uid)) {
              const deviceHash = await hash(device.name);
              const delivered = await store('SELECT at FROM deliveries WHERE message = ? AND device = ?', [message.name, deviceHash], 'first');
              if (delivered) continue;
              if (dbCalls >= dbLimit - 2) throw new PollLimit(); // Always keep room to record a successful send.
              const response = await request(`https://fcm.googleapis.com/v1/projects/${project}/messages:send`, {method: 'POST', headers, body: JSON.stringify({message: {
                token: text(device.fields.token), notification: {title, body: (text(message.fields.text) || strings.chatPhoto).slice(0, 180)},
                data: {chatId, messageId: parts[8]}, android: {priority: 'high', ttl: '86400s', notification: {channel_id: 'chat_messages', icon: 'ic_notification', tag: chatId, sound: 'default'}},
              }})});
              const result = await response.json();
              const permanent = (result.error?.details ?? []).some((detail) => ['UNREGISTERED', 'SENDER_ID_MISMATCH', 'INVALID_ARGUMENT'].includes(detail.errorCode));
              if (!response.ok && !permanent) throw new Error(`FCM request failed (${response.status})`);
              await store('INSERT OR IGNORE INTO deliveries(message, device, at) VALUES(?, ?, ?)', [message.name, deviceHash, now], 'run');
              if (response.ok) sent++;
            }
          }
        }
      }
      cursor = {at, name: message.name};
      await store("UPDATE state SET value = ? WHERE key = 'cursor'", [JSON.stringify(cursor)], 'run');
      processed++;
    }
  } catch (error) { if (!(error instanceof PollLimit)) throw error; }
  await env.DB.prepare('DELETE FROM deliveries WHERE at < ?').bind(now - 172800000).run();
  console.log(JSON.stringify({processed, sent, externalRequests: calls}));
  return {processed, sent, calls};
}
