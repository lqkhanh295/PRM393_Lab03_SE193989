// Script to import/sync all 45+ official FPT University HCMC clubs into Cloud Firestore
// Usage:
//   1. Run 'npx firebase-tools login' to authenticate
//   2. Run 'node scripts/import_45_clubs.cjs'
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');

const projectId = 'campus-event-48443';
const databaseUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents`;

function getAccessToken() {
  if (process.env.FIREBASE_TOKEN) {
    return process.env.FIREBASE_TOKEN;
  }
  if (process.env.GCLOUD_ACCESS_TOKEN) {
    return process.env.GCLOUD_ACCESS_TOKEN;
  }

  const possiblePaths = [
    path.join(os.homedir(), '.config', 'configstore', 'firebase-tools.json'),
    path.join(process.env.APPDATA || '', 'configstore', 'firebase-tools.json'),
    path.join(process.env.LOCALAPPDATA || '', 'configstore', 'firebase-tools.json'),
  ];

  for (const configPath of possiblePaths) {
    try {
      if (fs.existsSync(configPath)) {
        const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
        if (config.tokens && config.tokens.access_token) {
          return config.tokens.access_token;
        }
      }
    } catch {
      // Continue to next path
    }
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

async function importClubs() {
  console.log('===============================================================');
  console.log(`🚀 [Cloud Firestore Importer] Project: ${projectId}`);
  console.log('===============================================================');

  const token = getAccessToken();
  if (!token) {
    console.error('\n❌ [Xác thực thất bại] Chưa tìm thấy Firebase access token!');
    console.log('\n👉 Vui lòng chạy lệnh sau trên Terminal để đăng nhập:');
    console.log('   npx firebase-tools login');
    console.log('\nSau khi đăng nhập xong trên trình duyệt, hãy chạy lại:');
    console.log('   node scripts/import_45_clubs.cjs\n');
    process.exit(1);
  }

  const jsonPath = path.join(__dirname, '..', 'data', 'official_fptu_clubs.json');
  if (!fs.existsSync(jsonPath)) {
    console.error(`❌ [File Not Found] Không tìm thấy tệp: ${jsonPath}`);
    process.exit(1);
  }

  const clubs = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));
  console.log(`\n📦 Đang nạp ${clubs.length} câu lạc bộ chính thức FPTU TP.HCM lên Cloud Firestore...`);

  const headers = {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  };

  let successCount = 0;
  let failedCount = 0;
  const results = [];

  for (const club of clubs) {
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
        results.push({ id: docId, name: club.name, status: 'SUCCESS' });
        console.log(`  ✅ [${successCount}/${clubs.length}] Đã nạp: ${docId} - ${club.name}`);
      } else {
        failedCount++;
        const errText = await res.text();
        results.push({ id: docId, name: club.name, status: 'FAILED', error: errText });
        console.warn(`  ⚠️ Lỗi khi nạp ${docId}: HTTP ${res.status} - ${errText.slice(0, 120)}`);
      }
    } catch (e) {
      failedCount++;
      results.push({ id: docId, name: club.name, status: 'ERROR', error: e.message });
      console.warn(`  ❌ Lỗi kết nối mạng ${docId}: ${e.message}`);
    }
  }

  console.log('\n===============================================================');
  console.log(`🎉 [KẾT QUẢ IMPORT]: Thành công ${successCount}/${clubs.length} CLB! (Thất bại: ${failedCount})`);
  console.log('===============================================================');

  // Verify Cóc Sài Gòn
  const csgUploaded = results.find(r => r.id === 'csg' && r.status === 'SUCCESS');
  if (csgUploaded) {
    console.log("⭐ [Xác thực] CLB Truyền thông Cóc Sài Gòn (id: 'csg') đã được lưu trên Cloud Firestore!");
  }

  // Write evidence
  const evidencePath = path.join(__dirname, '..', 'evidence', 'firebase', 'clubs-import-status.json');
  fs.mkdirSync(path.dirname(evidencePath), { recursive: true });
  fs.writeFileSync(evidencePath, JSON.stringify({
    importedAt: new Date().toISOString(),
    total: clubs.length,
    success: successCount,
    failed: failedCount,
    results
  }, null, 2));
  console.log(`📄 Nhật ký chi tiết đã lưu vào: ${evidencePath}\n`);
}

importClubs().catch(err => {
  console.error('[Fatal Error]', err);
  process.exit(1);
});
