// Read-only Firestore check. All FCM calls use validate_only; no notification is delivered.
import {readFileSync} from 'node:fs';
import {DatabaseSync} from 'node:sqlite';
import {poll} from '../worker/src/index.mjs';
const key = JSON.parse(readFileSync(new URL('../.push-secrets/worker-service-account.json', import.meta.url), 'utf8'));
const sqlite = new DatabaseSync(':memory:');
sqlite.exec(readFileSync(new URL('../worker/schema.sql', import.meta.url), 'utf8'));
sqlite.prepare('INSERT INTO state VALUES(?, ?)').run('cursor', JSON.stringify({at: new Date(Date.now() - 300000).toISOString()}));
function statement(sql, values = []) { return {bind: (...args) => statement(sql, args), first: async () => sqlite.prepare(sql).get(...values) ?? null, run: async () => sqlite.prepare(sql).run(...values)}; }
let authorization;
const safeFetch = async (url, init) => {
  if (url.includes('firestore.googleapis.com')) authorization = init.headers.Authorization;
  if (url.includes('fcm.googleapis.com')) init = {...init, body: JSON.stringify({...JSON.parse(init.body), validate_only: true})};
  const response = await fetch(url, init);
  if (!response.ok) {
    const error = await response.clone().json();
    const detail = Array.isArray(error) ? error.find((part) => part.error)?.error : error.error;
    console.log('API check:', response.status, detail?.status, detail?.message);
  }
  return response;
};
try {
  let pollError;
  try {
    const result = await poll({PUSH_ENABLED: 'true', FIREBASE_PROJECT_ID: key.project_id, DB: {prepare: statement}}, {credentials: key, fetch: safeFetch});
    console.log('Read-only poll check passed:', result);
  } catch (error) { pollError = error; }
  const response = await fetch(`https://fcm.googleapis.com/v1/projects/${key.project_id}/messages:send`, {method: 'POST', headers: {Authorization: authorization, 'Content-Type': 'application/json'}, body: JSON.stringify({validate_only: true, message: {token: 'invalid-test-token', data: {test: 'validation-only'}}})});
  const validation = await response.json();
  if (response.status === 400 && validation.error?.status === 'INVALID_ARGUMENT') console.log('FCM authorization confirmed: validation rejected the intentionally invalid test token.');
  else throw new Error(`FCM validation check: ${response.status} ${validation.error?.message ?? 'Unexpected response'}`);
  if (pollError) throw pollError;
} finally { sqlite.close(); }
