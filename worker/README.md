# Zero chat push: Cloudflare Workers Free

Cron runs every minute and queries new Firestore messages by their original server timestamp. It uses FCM HTTP v1 to notify the current recipients. Existing iOS senders are supported; recipients need Android build 27 or later, Google Play Services and notification permission. Build 27 fixes the native Firebase startup mismatch found in build 26; install it over the existing app to retain local data.

## Access and secrets

`GOOGLE_SERVICE_ACCOUNT` is a Cloudflare Worker secret, never an app asset or Git file. The dedicated account `zero-chat-push-worker@zero-91cc8.iam.gserviceaccount.com` has only `roles/datastore.viewer` and `roles/firebasecloudmessaging.admin`. It can read server-side Firestore data and send push, but cannot change chats, profiles or device registrations. Personal quit-attempt data remains local to the app.

The owner must explicitly authorize uploading this key to Cloudflare. `tool/provision_worker_access.cjs` creates the account using an existing Firebase CLI login. Temporary key material is written only to ignored `.push-secrets/`; remove the local copy after upload and validation. For rotation, create a new key, replace the Worker secret, verify delivery, and revoke the old Google key.

## Deployment

1. Authorize Wrangler in the owner's Cloudflare account, on Workers Free.
2. Create D1 `zero-push-state`; set its id and account id in `wrangler.jsonc`.
3. Apply `schema.sql` to the remote D1 database.
4. Publish `firestore.indexes.json` and wait for the `messages.at` collection-group index to become ready.
5. Run `node tool/sync_push_strings.cjs`, `node --test worker/test/poll.test.mjs` and Wrangler's deploy dry run.
6. Deploy with `PUSH_ENABLED=false`, upload `GOOGLE_SERVICE_ACCOUNT` via `wrangler secret put` using stdin, then set `PUSH_ENABLED=true` and deploy again.
7. Observe at least two scheduled invocations before declaring the sender operational. Test actual reception on an Android phone separately.

Commands run from the repository root; pass `--config worker/wrangler.jsonc` to Wrangler. The exact CLI version is pinned in `worker/package.json`. `tool/check_worker_live.mjs` checks actual Firestore queries and FCM authorization with `validate_only`; it never delivers a notification.

## Delivery and free-plan limits

- The initial cursor starts when the Worker is enabled, so old conversations do not produce a notification flood. Messages older than 24 hours are skipped after prolonged downtime.
- Each poll fetches up to 20 messages, uses at most 40 external requests and reserves headroom under D1's 50-query free-plan invocation limit. Unfinished work resumes on the next tick; heavy traffic and outages can increase the delay beyond one minute.
- The 10 most recently refreshed device registrations per recipient are considered. Registration tokens and message text are not persisted in D1. D1 stores the cursor, message ids and SHA-256 hashes of device document names. Receipts are pruned after 48 hours.
- A 120-second lease prevents overlapping polls. Network requests time out after at most eight seconds; the poll stops starting requests after 80 seconds.
- Per-device receipts avoid normal retries duplicating notifications. A crash between FCM accepting a send and saving its receipt can still result in a duplicate. FCM itself does not guarantee immediate delivery.
- Original timestamps and document-name tie breaking prevent edits or messages sharing a timestamp from corrupting the cursor. Events and messages from users no longer in the chat do not notify anyone.
- There is no public send endpoint; `workers_dev` is disabled. Source logs contain counters and sanitized API errors, not message bodies or tokens.
- Cloud Functions is not deployed. `functions/` remains as the previous implementation and rule-test harness. Firebase stays on Spark; exceeding its free quota can interrupt service rather than charge Blaze usage.

Set `PUSH_ENABLED=false` and redeploy to stop sending. No Android/iOS bundle id or app data migration is required.
