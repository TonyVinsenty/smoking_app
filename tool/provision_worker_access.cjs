// Uses the owner's existing Firebase CLI login; never prints access tokens or key material.
const fs = require('node:fs');
const path = require('node:path');
const project = 'zero-91cc8';
const cli = process.argv[2];
const mode = process.argv[3] || 'check';
const email = `zero-chat-push-worker@${project}.iam.gserviceaccount.com`;
const name = `projects/${project}/serviceAccounts/${email}`;
const keyFile = path.resolve(__dirname, '../.push-secrets/worker-service-account.json');

async function main() {
  const auth = require(path.join(cli, 'auth.js'));
  const {requireAuth} = require(path.join(cli, 'requireAuth.js'));
  const {getAccessToken} = require(path.join(cli, 'apiv2.js'));
  const account = auth.getGlobalDefaultAccount();
  if (!account) throw new Error('Firebase CLI login required');
  await requireAuth({...account, project});
  const token = await getAccessToken();
  const request = async (url, body, method) => {
    const response = await fetch(url, {method: method || (body ? 'POST' : 'GET'), headers: {Authorization: `Bearer ${token}`, 'Content-Type': 'application/json'}, ...(body ? {body: JSON.stringify(body)} : {})});
    const data = await response.json();
    if (!response.ok) throw new Error(`Google API ${response.status}: ${data.error?.message || 'Request failed'}`);
    return data;
  };
  const policyUrl = `https://cloudresourcemanager.googleapis.com/v1/projects/${project}`;
  if (mode === 'billing') {
    const info = await request(`https://cloudbilling.googleapis.com/v1/projects/${project}/billingInfo`);
    console.log('Google Cloud billing enabled for project:', info.billingEnabled === true);
    return;
  }
  const policy = await request(`${policyUrl}:getIamPolicy`, {options: {requestedPolicyVersion: 3}});
  if (mode === 'check') { console.log('Project IAM access confirmed; no changes made.'); return; }
  if (mode !== 'provision') throw new Error('Unknown mode');
  const lookup = await fetch(`https://iam.googleapis.com/v1/${name}`, {headers: {Authorization: `Bearer ${token}`}});
  if (lookup.status === 404) {
    await request(`https://iam.googleapis.com/v1/projects/${project}/serviceAccounts`, {accountId: 'zero-chat-push-worker', serviceAccount: {displayName: 'Zero Cloudflare chat notifications'}});
  } else if (!lookup.ok) { throw new Error(`Service account lookup failed (${lookup.status})`); }
  policy.bindings ??= [];
  for (const role of ['roles/datastore.viewer', 'roles/firebasecloudmessaging.admin']) {
    let binding = policy.bindings.find((b) => b.role === role && !b.condition);
    if (!binding) { binding = {role, members: []}; policy.bindings.push(binding); }
    if (!binding.members.includes(`serviceAccount:${email}`)) binding.members.push(`serviceAccount:${email}`);
  }
  for (let attempt = 0; ; attempt++) {
    try { await request(`${policyUrl}:setIamPolicy`, {policy}); break; }
    catch (error) {
      if (attempt >= 4 || !error.message.includes('does not exist')) throw error;
      await new Promise((resolve) => setTimeout(resolve, 2000 * 2 ** attempt));
    }
  }
  if (!fs.existsSync(keyFile)) {
    const key = await request(`https://iam.googleapis.com/v1/${name}/keys`, {privateKeyType: 'TYPE_GOOGLE_CREDENTIALS_FILE', keyAlgorithm: 'KEY_ALG_RSA_2048'});
    fs.mkdirSync(path.dirname(keyFile), {recursive: true});
    fs.writeFileSync(keyFile, Buffer.from(key.privateKeyData, 'base64'), {mode: 0o600});
  }
  const key = JSON.parse(fs.readFileSync(keyFile));
  if (key.project_id !== project || key.client_email !== email) throw new Error('Unexpected service account key');
  console.log('Dedicated service account ready: Firestore read-only and FCM sending. Key saved in ignored .push-secrets folder.');
}
main().catch((error) => { console.error(error.message); process.exitCode = 1; });
