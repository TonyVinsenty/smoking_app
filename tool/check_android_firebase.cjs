// Checks the packaged APK, not only source config: native auto-init must match FlutterFire options.
const fs = require('node:fs');
const path = require('node:path');
const {execFileSync} = require('node:child_process');
const root = path.resolve(__dirname, '..');
const [apk, aapt] = process.argv.slice(2);
if (!apk || !aapt) throw new Error('Usage: node tool/check_android_firebase.cjs <apk> <aapt executable>');
const config = JSON.parse(fs.readFileSync(path.join(root, 'firebase/google-services.json'), 'utf8'));
const client = config.client.find((c) => c.client_info.android_client_info.package_name === 'com.tonyvinsenty.smoking_app');
const dart = fs.readFileSync(path.join(root, 'lib/firebase_options.dart'), 'utf8').match(/static const android = FirebaseOptions\(([\s\S]*?)\);/)[1];
const values = execFileSync(aapt, ['dump', '--values', 'resources', apk], {encoding: 'utf8', maxBuffer: 64 * 1024 * 1024});
const options = [
  ['google_app_id', 'appId', client.client_info.mobilesdk_app_id],
  ['google_api_key', 'apiKey', client.api_key[0].current_key],
  ['gcm_defaultSenderId', 'messagingSenderId', config.project_info.project_number],
  ['project_id', 'projectId', config.project_info.project_id],
  ['google_storage_bucket', 'storageBucket', config.project_info.storage_bucket],
  ['firebase_database_url', 'databaseURL', config.project_info.firebase_url],
];
for (const [resource, option, expected] of options) {
  if (expected == null) continue;
  const match = values.match(new RegExp(`^\\s+resource [^\\n]*:string/${resource}:[^\\n]*\\r?\\n\\s+\\(string(?:8|16)\\) ("[^"\\n]*")`, 'm'));
  if (!match) throw new Error(`Packaged native Firebase resource is missing: ${resource}`);
  if (JSON.parse(match[1]) !== String(expected)) throw new Error(`Packaged native Firebase resource differs from JSON: ${resource}`);
  const configured = dart.match(new RegExp(`${option}: '([^']*)'`));
  if (!configured || configured[1] !== String(expected)) throw new Error(`FlutterFire option differs from native Firebase config: ${option}`);
}
console.log('Packaged native Firebase options match both google-services.json and FlutterFire options.');
