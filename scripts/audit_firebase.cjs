// Read-only audit. Requires an authenticated Firebase CLI session.
// Never writes documents, rules, billing settings, or Remote Config.
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const projectId = 'campus-event-48443';
const root = path.resolve(__dirname, '..');
const config = JSON.parse(fs.readFileSync(path.join(os.homedir(), '.config/configstore/firebase-tools.json'), 'utf8'));
const headers = { Authorization: `Bearer ${config.tokens.access_token}` };
async function read(url) {
  const response = await fetch(url, { headers, signal: AbortSignal.timeout(30000) });
  if (!response.ok) throw new Error(`Firebase read failed: HTTP ${response.status} (${new URL(url).hostname})`);
  return response.json();
}
async function documents(collection) {
  const result = [];
  let token;
  do {
    const url = new URL(`https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/${collection}`);
    url.searchParams.set('pageSize', '100');
    if (token) url.searchParams.set('pageToken', token);
    const page = await read(url);
    result.push(...(page.documents || []));
    token = page.nextPageToken;
  } while (token);
  return result;
}
async function main() {
  const [remote, events, clubs, buckets, billing, releases] = await Promise.all([
    read(`https://firebaseremoteconfig.googleapis.com/v1/projects/${projectId}/remoteConfig`),
    documents('events'), documents('clubs'),
    read(`https://storage.googleapis.com/storage/v1/b?project=${projectId}`),
    read(`https://cloudbilling.googleapis.com/v1/projects/${projectId}/billingInfo`),
    read(`https://firebaserules.googleapis.com/v1/projects/${projectId}/releases?pageSize=100`),
  ]);
  const release = releases.releases?.find(r => r.name.endsWith('/cloud.firestore'));
  const rules = release ? await read(`https://firebaserules.googleapis.com/v1/${release.rulesetName}`) : null;
  const normalize = value => value.replace(/\r\n/g, '\n').trim();
  const clubIds = clubs.map(c => c.name.split('/').pop());
  const audit = {
    checkedAt: new Date().toISOString(), projectId,
    remoteConfig: { parameters: remote.parameters, versionNumber: remote.version?.versionNumber, updateTime: remote.version?.updateTime },
    firestoreRules: { rulesetName: release?.rulesetName, matchesLocal: rules?.source?.files?.some(f => normalize(f.content) === normalize(fs.readFileSync(path.join(root, 'firestore.rules'), 'utf8'))) ?? false },
    storage: { bucketCount: buckets.items?.length ?? 0, billingEnabled: billing.billingEnabled, rulesReleaseFound: releases.releases?.some(r => r.name.includes('/firebase.storage/')) ?? false },
    firestoreAudit: {
      eventCount: events.length,
      events: events.map(d => ({ id: d.name.split('/').pop(), title: d.fields?.title?.stringValue, sessionCount: d.fields?.sessions?.arrayValue?.values?.length ?? 0 })),
      requiredClubIdsPresent: ['fcode', 'jsclub', 'media_club'].filter(id => clubIds.includes(id)),
      eventProvenance: 'Not established by database existence. Organizer confirmation is required.',
    },
  };
  const output = path.join(root, 'evidence/firebase/trung-cloud-audit.json');
  fs.mkdirSync(path.dirname(output), { recursive: true });
  fs.writeFileSync(output, JSON.stringify(audit, null, 2) + '\n');
  console.log(JSON.stringify(audit, null, 2));
}
main().catch(error => { console.error(error.message); process.exitCode = 1; });
