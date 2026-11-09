// Seed script to sync all 45 FPT University HCMC Clubs & Student Communities into Cloud Firestore
// Usage: node scripts/seed_clubs_firestore.cjs
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');

const projectId = 'campus-event-48443';
const databaseUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents`;

async function getAccessToken() {
  try {
    const configPath = path.join(os.homedir(), '.config/configstore/firebase-tools.json');
    if (fs.existsSync(configPath)) {
      const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
      if (config.tokens && config.tokens.access_token) {
        return config.tokens.access_token;
      }
    }
  } catch (e) {
    console.warn('[Seed] Could not read firebase-tools token:', e.message);
  }
  return null;
}

function toFirestoreFields(data) {
  const fields = {};
  for (const [key, value] of Object.entries(data)) {
    if (key === 'id') continue;
    if (typeof value === 'string') {
      fields[key] = { stringValue: value };
    } else if (typeof value === 'number') {
      fields[key] = { integerValue: value.toString() };
    } else if (typeof value === 'boolean') {
      fields[key] = { booleanValue: value };
    } else if (Array.isArray(value)) {
      fields[key] = {
        arrayValue: {
          values: value.map(v => ({ stringValue: v.toString() }))
        }
      };
    }
  }
  return fields;
}

async function seedClubs() {
  console.log(`[Seed] Connecting to Cloud Firestore project: ${projectId}...`);
  const token = await getAccessToken();
  const headers = { 'Content-Type': 'application/json' };
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  // Parse seed data from Dart file or fallback JSON
  const dartSeedPath = path.join(__dirname, '../lib/services/seed_firestore_data.dart');
  const dartContent = fs.readFileSync(dartSeedPath, 'utf8');
  
  // Extract clubs array roughly or define static list
  console.log('[Seed] Ready to upload 45 official clubs...');
  let successCount = 0;

  // Read clubs from seed_firestore_data
  const match = dartContent.match(/static const List<Map<String, dynamic>> officialClubs = \[([\s\S]*?)\];\s*static Future<int> seedAll/);
  if (!match) {
    console.error('[Seed] Could not parse officialClubs list from seed_firestore_data.dart');
    return;
  }

  // Evaluate the clubs array
  const rawListText = match[1];
  const items = [];
  const itemRegex = /\{([\s\S]*?)\}/g;
  let itemMatch;
  while ((itemMatch = itemRegex.exec(rawListText)) !== null) {
    const block = itemMatch[1];
    const lines = block.split('\n');
    const obj = {};
    for (const line of lines) {
      const kv = line.match(/'(\w+)':\s*(?:'([^']*)'|(\d+)),?/);
      if (kv) {
        const key = kv[1];
        const val = kv[3] !== undefined ? parseInt(kv[3], 10) : kv[2];
        obj[key] = val;
      }
    }
    if (obj.id && obj.name) {
      items.push(obj);
    }
  }

  console.log(`[Seed] Parsed ${items.length} clubs from seed data.`);

  for (const club of items) {
    const docId = club.id;
    const url = `${databaseUrl}/clubs/${docId}`;
    const fields = toFirestoreFields(club);

    try {
      const res = await fetch(url, {
        method: 'PATCH',
        headers,
        body: JSON.stringify({ fields })
      });
      if (res.ok) {
        successCount++;
        process.stdout.write('.');
      } else {
        const errText = await res.text();
        console.warn(`\n[Seed] Failed to upsert ${docId}: HTTP ${res.status} - ${errText.slice(0, 100)}`);
      }
    } catch (e) {
      console.warn(`\n[Seed] Network error for ${docId}: ${e.message}`);
    }
  }

  console.log(`\n[Seed] Complete! Successfully synced ${successCount}/${items.length} clubs.`);
}

seedClubs().catch(err => console.error('[Seed Error]', err));
