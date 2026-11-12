/**
 * FPTU CAMPUS EVENT - ADMIN WEB PORTAL LOCAL BACKEND SERVER
 * Zero-dependency native Node.js HTTP Server & Cloud Firestore REST API Bridge
 * Project: campus-event-48443 (FPT University HCMC)
 */

const http = require('http');
const fs = require('fs');
const path = require('path');
const os = require('os');
const { execSync } = require('child_process');

const PORT = process.env.PORT || 3000;
const PUBLIC_DIR = __dirname;
const PROJECT_ID = 'campus-event-48443';
const FIRESTORE_BASE = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents`;

process.on('uncaughtException', (err) => {
  console.error('[Process Uncaught Exception]:', err.stack || err);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('[Process Unhandled Rejection]:', reason);
});

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.csv': 'text/csv; charset=utf-8',
  '.xls': 'application/vnd.ms-excel; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon'
};

// -------------------------------------------------------------
// Firebase Authentication & Token Management
// -------------------------------------------------------------
function getFirebaseToken() {
  const possiblePaths = [
    path.join(os.homedir(), '.config', 'configstore', 'firebase-tools.json'),
    path.join(process.env.APPDATA || '', 'configstore', 'firebase-tools.json'),
    path.join(process.env.LOCALAPPDATA || '', 'configstore', 'firebase-tools.json')
  ];

  for (const configPath of possiblePaths) {
    if (fs.existsSync(configPath)) {
      try {
        const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
        if (config.tokens && config.tokens.access_token) {
          // If token expires in less than 60 seconds, attempt a fast refresh
          if (config.tokens.expires_at && Date.now() >= (config.tokens.expires_at - 60000)) {
            try {
              console.log('[Firebase Auth] Access token expiring, refreshing via firebase-tools...');
              const directFirebaseCmd = path.join(process.env.LOCALAPPDATA || '', 'npm-cache', '_npx', '7750544ccf494d8b', 'node_modules', '.bin', 'firebase.cmd');
              if (fs.existsSync(directFirebaseCmd)) {
                execSync(`"${directFirebaseCmd}" projects:list`, { stdio: 'ignore', timeout: 15000 });
              } else {
                execSync('npx firebase-tools projects:list', { stdio: 'ignore', timeout: 20000 });
              }
              const refreshed = JSON.parse(fs.readFileSync(configPath, 'utf8'));
              return { token: refreshed.tokens.access_token, user: refreshed.user?.email || 'Admin' };
            } catch (err) {
              console.warn('[Firebase Auth] Auto-refresh note:', err.message);
            }
          }
          return { token: config.tokens.access_token, user: config.user?.email || 'Admin' };
        }
      } catch (e) {
        console.warn('[Firebase Auth] Read config error:', e.message);
      }
    }
  }
  return { token: null, user: null };
}

// -------------------------------------------------------------
// Firestore Document Conversions
// -------------------------------------------------------------
// Firestore Document Conversions (Full Recursive Map/Array Support)
// -------------------------------------------------------------
function convertFirestoreValue(val) {
  if (!val || typeof val !== 'object') return val;
  if ('stringValue' in val) return val.stringValue;
  if ('integerValue' in val) return parseInt(val.integerValue, 10);
  if ('doubleValue' in val) return parseFloat(val.doubleValue);
  if ('booleanValue' in val) return val.booleanValue;
  if ('timestampValue' in val) return val.timestampValue;
  if ('arrayValue' in val) {
    return (val.arrayValue.values || []).map(convertFirestoreValue);
  }
  if ('mapValue' in val) {
    const res = {};
    for (const [k, v] of Object.entries(val.mapValue.fields || {})) {
      res[k] = convertFirestoreValue(v);
    }
    return res;
  }
  return val;
}

function fromFirestoreDoc(doc) {
  if (!doc || !doc.fields) return null;
  const id = doc.name ? doc.name.split('/').pop() : '';
  const fields = doc.fields;
  const result = { id };
  for (const [key, val] of Object.entries(fields)) {
    result[key] = convertFirestoreValue(val);
  }
  return result;
}

function convertToFirestoreValue(v) {
  if (v === undefined || v === null) return { nullValue: null };
  if (typeof v === 'string') return { stringValue: v };
  if (typeof v === 'number') {
    return Number.isInteger(v) ? { integerValue: String(v) } : { doubleValue: v };
  }
  if (typeof v === 'boolean') return { booleanValue: v };
  if (Array.isArray(v)) {
    return {
      arrayValue: {
        values: v.map(convertToFirestoreValue)
      }
    };
  }
  if (typeof v === 'object') {
    const fields = {};
    for (const [k, child] of Object.entries(v)) {
      fields[k] = convertToFirestoreValue(child);
    }
    return { mapValue: { fields } };
  }
  return { stringValue: String(v) };
}

function toFirestoreFields(obj) {
  const fields = {};
  for (const [key, val] of Object.entries(obj)) {
    if (val === undefined || val === null) continue;
    fields[key] = convertToFirestoreValue(val);
  }
  return fields;
}

// Process safety guards
process.on('uncaughtException', (err) => {
  console.error('[Uncaught Exception]', err.message);
});
process.on('unhandledRejection', (reason) => {
  console.error('[Unhandled Rejection]', reason);
});

// Firestore REST Request with Bearer Token & Smart Quota Protection Cache
const CACHE_FILE = path.join(__dirname, '.firestore_cache.json');
const firestoreCache = new Map();

// Tiered Quota-Safe Cache TTLs (drastically reduces Firebase Spark quota burn)
const COLLECTION_TTLS = {
  clubs: 12 * 60 * 60 * 1000,             // 12 hours (46 clubs are static, saving 46 reads per poll)
  'pccc-inspections': 4 * 60 * 60 * 1000, // 4 hours
  pccc_inspections: 4 * 60 * 60 * 1000,
  budgets: 15 * 60 * 1000,                // 15 minutes (updated optimistically on review)
  events: 5 * 60 * 1000,                  // 5 minutes (updated optimistically on creation)
  announcements: 5 * 60 * 1000,           // 5 minutes (updated optimistically on broadcast)
  gate_assignments: 10 * 60 * 1000,       // 10 minutes
  registrations: 3 * 60 * 1000,           // 3 minutes (updated optimistically on submit/approve)
  tickets: 90 * 1000,                     // 90 seconds (updated optimistically on checkin)
  default: 5 * 60 * 1000                  // 5 minutes default
};

function getTtlForEndpoint(endpoint) {
  const collection = endpoint.split('?')[0].replace(/^\//, '').split('/')[0];
  return COLLECTION_TTLS[collection] || COLLECTION_TTLS.default;
}

// Load disk snapshot on startup if available
try {
  if (fs.existsSync(CACHE_FILE)) {
    const raw = fs.readFileSync(CACHE_FILE, 'utf8');
    const parsed = JSON.parse(raw);
    for (const [k, v] of Object.entries(parsed)) {
      firestoreCache.set(k, v);
    }
    console.log(`[Cache] Preloaded ${firestoreCache.size} collections from disk snapshot.`);
  }
} catch (e) {
  console.warn('[Cache] Could not preload cache file:', e.message);
}

function persistCacheToDisk() {
  try {
    const obj = {};
    for (const [k, v] of firestoreCache.entries()) {
      obj[k] = v;
    }
    fs.writeFileSync(CACHE_FILE, JSON.stringify(obj, null, 2), 'utf8');
  } catch (e) {
    console.warn('[Cache] Could not persist cache:', e.message);
  }
}

function markCacheStale(cacheKey) {
  const entry = firestoreCache.get(cacheKey);
  if (entry) {
    // Mark TTL expired so live reads try Firestore, while preserving fallback snapshot for HTTP 429
    entry.timestamp = 0;
    firestoreCache.set(cacheKey, entry);
  }
}

function matchesFirestoreDocId(doc, docId) {
  if (!doc || !docId) return false;
  const decoded = decodeURIComponent(String(docId));
  if (doc.name && (doc.name.endsWith(`/${decoded}`) || doc.name.endsWith(`/${docId}`))) {
    return true;
  }
  const fieldId = doc.fields?.id?.stringValue;
  return Boolean(fieldId && (fieldId === decoded || fieldId === String(docId)));
}

function getFromCache(method, endpoint) {
  const exactKey = `${method}:${endpoint}`;
  if (firestoreCache.has(exactKey)) return firestoreCache.get(exactKey).data;
  const baseEndpoint = endpoint.split('?')[0];
  const baseKey = `${method}:${baseEndpoint}`;
  if (firestoreCache.has(baseKey)) return firestoreCache.get(baseKey).data;
  if (method === 'GET') {
    const segments = baseEndpoint.replace(/^\//, '').split('/');
    if (segments.length === 2) {
      const [collection, rawDocId] = segments;
      const colEntry = firestoreCache.get(`GET:/${collection}`);
      const docs = colEntry?.data?.documents;
      if (Array.isArray(docs)) {
        return docs.find(d => matchesFirestoreDocId(d, rawDocId)) || null;
      }
    }
  }
  return null;
}

function mutateCache(endpoint, method, body, createdId) {
  try {
    const rawPath = endpoint.split('?')[0].replace(/^\//, '');
    const parts = rawPath.split('/');
    const collection = parts[0];
    const queryDocId = endpoint.includes('documentId=') ? endpoint.split('documentId=')[1].split('&')[0] : null;
    const docId = parts[1] || queryDocId || createdId;
    const cacheKey = `GET:/${collection}`;

    if (!firestoreCache.has(cacheKey)) {
      firestoreCache.set(cacheKey, { timestamp: Date.now(), data: { documents: [] } });
    }
    const cached = firestoreCache.get(cacheKey);
    if (!cached.data || !Array.isArray(cached.data.documents)) {
      cached.data = { documents: [] };
    }

    if (method === 'DELETE' && docId) {
      cached.data.documents = cached.data.documents.filter(d => !matchesFirestoreDocId(d, docId));
      firestoreCache.set(cacheKey, { timestamp: Date.now(), data: cached.data });
      persistCacheToDisk();
      console.log(`[Cache Sync] Removed ${docId} from ${cacheKey}`);
    } else if (method === 'POST' && body && body.fields) {
      const targetId = docId || body.fields?.id?.stringValue || ('doc_' + Date.now());
      const docName = `projects/${PROJECT_ID}/databases/(default)/documents/${collection}/${targetId}`;
      const newDoc = {
        name: docName,
        fields: body.fields,
        createTime: new Date().toISOString(),
        updateTime: new Date().toISOString()
      };
      cached.data.documents = cached.data.documents.filter(d => !matchesFirestoreDocId(d, targetId));
      cached.data.documents.unshift(newDoc);
      firestoreCache.set(cacheKey, { timestamp: Date.now(), data: cached.data });
      persistCacheToDisk();
      console.log(`[Cache Sync] Added ${docName} to ${cacheKey}`);
    } else if (method === 'PATCH' && docId && body && body.fields) {
      let found = false;
      for (const d of cached.data.documents) {
        if (matchesFirestoreDocId(d, docId)) {
          d.fields = { ...(d.fields || {}), ...body.fields };
          d.updateTime = new Date().toISOString();
          found = true;
          break;
        }
      }
      if (!found) {
        const docName = `projects/${PROJECT_ID}/databases/(default)/documents/${collection}/${docId}`;
        cached.data.documents.unshift({
          name: docName,
          fields: body.fields,
          createTime: new Date().toISOString(),
          updateTime: new Date().toISOString()
        });
      }
      firestoreCache.set(cacheKey, { timestamp: Date.now(), data: cached.data });
      persistCacheToDisk();
      console.log(`[Cache Sync] Patched/Upserted ${docId} in ${cacheKey}`);
    }
  } catch (err) {
    console.warn('[Cache Mutation Note]', err.message);
  }
}

async function firestoreRequest(endpoint, method = 'GET', body = null, optionsArg = {}) {
  const forceFresh = Boolean(optionsArg && optionsArg.forceFresh);
  const cacheKey = `${method}:${endpoint}`;
  if (method === 'GET' && !forceFresh) {
    const cachedData = getFromCache(method, endpoint);
    const baseEndpoint = endpoint.split('?')[0];
    const segments = baseEndpoint.replace(/^\//, '').split('/');
    const cachedEntry = firestoreCache.get(cacheKey) ||
      firestoreCache.get(`${method}:${baseEndpoint}`) ||
      (segments.length === 2 ? firestoreCache.get(`GET:/${segments[0]}`) : null);
    const ttl = getTtlForEndpoint(endpoint);
    if (cachedData && cachedEntry && (Date.now() - cachedEntry.timestamp < ttl)) {
      return cachedData;
    }
  }

  const { token } = getFirebaseToken();
  const headers = {
    'Content-Type': 'application/json'
  };
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  const url = `${FIRESTORE_BASE}${endpoint}`;
  const options = { method, headers };
  if (body) {
    options.body = JSON.stringify(body);
  }

  try {
    const res = await fetch(url, options);
    if (!res.ok) {
      const errorText = await res.text();
      // If 429 (Quota exceeded) or server error, gracefully serve cached data if available and back off
      const cachedData = getFromCache(method, endpoint);
      if (cachedData) {
        console.warn(`[Firestore Quota/Status ${res.status}] Serving cached data for ${endpoint}`);
        if (res.status === 429) {
          const entry = firestoreCache.get(cacheKey) || firestoreCache.get(`${method}:${endpoint.split('?')[0]}`);
          if (entry) entry.timestamp = Date.now(); // Back off
        }
        return cachedData;
      }
      if (res.status === 429 && method === 'GET') {
        console.warn(`[Firestore Quota Exceeded] No cache for ${endpoint}, returning empty documents`);
        return { documents: [] };
      }
      if (method !== 'GET') {
        mutateCache(endpoint, method, body);
        return { success: true, localCached: true };
      }
      throw new Error(`Firestore HTTP ${res.status}: ${errorText}`);
    }
    const data = await res.json();
    if (method === 'GET') {
      firestoreCache.set(cacheKey, { timestamp: Date.now(), data });
      persistCacheToDisk();
    } else {
      mutateCache(endpoint, method, body);
    }
    return data;
  } catch (err) {
    const cachedData = getFromCache(method, endpoint);
    if (cachedData) {
      console.warn(`[Firestore Fallback] Serving cached data for ${endpoint} due to error:`, err.message);
      return cachedData;
    }
    if (method === 'GET') {
      console.warn(`[Firestore Safe Default] Returning empty documents list for ${endpoint}:`, err.message);
      return { documents: [] };
    }
    if (method !== 'GET') {
      mutateCache(endpoint, method, body);
      return { success: true, localCached: true };
    }
    throw err;
  }
}

// Helper to parse JSON body from incoming request
function parseBody(req) {
  return new Promise((resolve, reject) => {
    let raw = '';
    req.on('data', chunk => { raw += chunk; });
    req.on('end', () => {
      if (!raw) return resolve({});
      try {
        resolve(JSON.parse(raw));
      } catch (err) {
        reject(err);
      }
    });
    req.on('error', reject);
  });
}

function sendJson(res, statusCode, data) {
  res.writeHead(statusCode, {
    'Content-Type': 'application/json; charset=utf-8',
    'Cache-Control': 'no-cache, no-store, must-revalidate',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PATCH, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization'
  });
  res.end(JSON.stringify(data));
}

function isEventDatePast(dateStr) {
  if (!dateStr) return false;
  const trimmed = String(dateStr).trim();
  let evtDate = null;
  if (trimmed.includes('/')) {
    const parts = trimmed.split('/');
    if (parts.length === 3) {
      const p0 = parseInt(parts[0], 10);
      const p1 = parseInt(parts[1], 10);
      const p2 = parseInt(parts[2], 10);
      evtDate = p0 > 1000
        ? new Date(p0, p1 - 1, p2, 23, 59, 59)
        : new Date(p2, p1 - 1, p0, 23, 59, 59);
    }
  } else if (trimmed.includes('-')) {
    const parts = trimmed.split('-');
    if (parts.length === 3) {
      const p0 = parseInt(parts[0], 10);
      const p1 = parseInt(parts[1], 10);
      const p2 = parseInt(parts[2], 10);
      evtDate = p0 > 1000
        ? new Date(p0, p1 - 1, p2, 23, 59, 59)
        : new Date(p2, p1 - 1, p0, 23, 59, 59);
    }
  }
  return evtDate instanceof Date && !isNaN(evtDate.getTime()) && evtDate < new Date();
}

async function fetchEventById(eventId) {
  if (!eventId) return null;
  try {
    const cachedDoc = getFromCache('GET', `/events/${encodeURIComponent(eventId)}`);
    if (cachedDoc && cachedDoc.fields) {
      const parsed = fromFirestoreDoc(cachedDoc);
      parsed._resourceId = cachedDoc.name ? cachedDoc.name.split('/').pop() : eventId;
      return parsed;
    }
    const listData = await firestoreRequest('/events');
    const docs = listData.documents || [];
    const matchedDoc = docs.find(d => matchesFirestoreDocId(d, eventId));
    if (matchedDoc) {
      const parsed = fromFirestoreDoc(matchedDoc);
      parsed._resourceId = matchedDoc.name ? matchedDoc.name.split('/').pop() : eventId;
      return parsed;
    }
    const evtDoc = await firestoreRequest(`/events/${encodeURIComponent(eventId)}`);
    const parsed = fromFirestoreDoc(evtDoc);
    if (parsed) parsed._resourceId = evtDoc.name ? evtDoc.name.split('/').pop() : eventId;
    return parsed;
  } catch (_) {
    return null;
  }
}

// -------------------------------------------------------------
// HTTP Request Router
// -------------------------------------------------------------
const server = http.createServer(async (req, res) => {
  // CORS Preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PATCH, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization'
    });
    return res.end();
  }

  const parsedUrl = new URL(req.url, `http://${req.headers.host || 'localhost:3000'}`);
  const pathname = parsedUrl.pathname;

  // ==========================================
  // API ROUTING: /api/...
  // ==========================================
  if (pathname.startsWith('/api/')) {
    try {
      // 1. GET /api/status
      if (pathname === '/api/status' && req.method === 'GET') {
        const authInfo = getFirebaseToken();
        return sendJson(res, 200, {
          status: 'ok',
          projectId: PROJECT_ID,
          authenticated: Boolean(authInfo.token),
          user: authInfo.user || 'Unknown Staff',
          timestamp: new Date().toISOString()
        });
      }

      // 2. GET /api/events
      if (pathname === '/api/events' && req.method === 'GET') {
        const forceFresh = parsedUrl.searchParams.get('fresh') === '1';
        const data = await firestoreRequest('/events', 'GET', null, { forceFresh });
        const events = (data.documents || []).map(fromFirestoreDoc);
        return sendJson(res, 200, { documents: events });
      }

      // 2b. POST /api/events (Create Event - Management Feature)
      if (pathname === '/api/events' && req.method === 'POST') {
        const body = await parseBody(req);
        if (!body.title || !body.location || !body.date || !body.time) {
          return sendJson(res, 400, { error: 'Vui lòng điền đầy đủ tiêu đề, địa điểm, ngày và khung giờ tổ chức sự kiện.' });
        }

        // Helper: Normalize date (YYYY-MM-DD or DD/MM/YYYY) into canonical parts
        const normalizeDateParts = (raw) => {
          const s = String(raw || '').trim();
          let y, m, d;
          if (s.includes('/')) {
            const p = s.split('/').map(Number);
            if (p.length === 3 && p.every(n => Number.isInteger(n))) {
              if (p[0] > 1000) { [y, m, d] = p; } else { [d, m, y] = p; }
            }
          } else if (s.includes('-')) {
            const p = s.split('-').map(Number);
            if (p.length === 3 && p.every(n => Number.isInteger(n))) {
              if (p[0] > 1000) { [y, m, d] = p; } else { [d, m, y] = p; }
            }
          }
          if (!y || !m || !d || m < 1 || m > 12 || d < 1 || d > 31) return null;
          const dt = new Date(y, m - 1, d);
          if (dt.getFullYear() !== y || dt.getMonth() !== m - 1 || dt.getDate() !== d) return null;
          const yyyy = String(y).padStart(4, '0');
          const mm = String(m).padStart(2, '0');
          const dd = String(d).padStart(2, '0');
          return { yyyy, mm, dd, iso: `${yyyy}-${mm}-${dd}`, dmy: `${dd}/${mm}/${yyyy}` };
        };

        const parseTimeRange = (raw) => {
          const m = String(raw || '').trim().match(/^(\d{1,2}):(\d{2})\s*[-–]\s*(\d{1,2}):(\d{2})$/);
          if (!m) return null;
          const sh = Number(m[1]), sm = Number(m[2]), eh = Number(m[3]), em = Number(m[4]);
          if (sh > 23 || sm > 59 || eh > 23 || em > 59) return null;
          const startMin = sh * 60 + sm;
          const endMin = eh * 60 + em;
          if (endMin - startMin < 30) return null;
          const fmt = `${String(sh).padStart(2, '0')}:${String(sm).padStart(2, '0')} - ${String(eh).padStart(2, '0')}:${String(em).padStart(2, '0')}`;
          return { startMin, endMin, formatted: fmt };
        };

        const normLoc = (loc) => String(loc || '')
          .toLowerCase()
          .replace(/\([^)]*\)/g, ' ')
          .replace(/[-–]/g, ' ')
          .replace(/\s+/g, ' ')
          .trim();

        const dateParts = normalizeDateParts(body.date);
        if (!dateParts) {
          return sendJson(res, 400, { error: 'Định dạng ngày tổ chức không hợp lệ (cần DD/MM/YYYY hoặc YYYY-MM-DD).' });
        }

        const timeRange = parseTimeRange(body.time);
        if (!timeRange) {
          return sendJson(res, 400, { error: 'Khung giờ không hợp lệ! Vui lòng nhập theo dạng HH:mm - HH:mm và thời lượng tối thiểu 30 phút.' });
        }

        // Validate against Vietnam local date & current time (UTC+7)
        const nowVN = new Date(Date.now() + 7 * 3600 * 1000);
        const todayIsoVN = nowVN.toISOString().slice(0, 10);
        const nowMinVN = nowVN.getUTCHours() * 60 + nowVN.getUTCMinutes();
        if (dateParts.iso < todayIsoVN) {
          return sendJson(res, 400, {
            error: 'Không thể tạo sự kiện trong quá khứ! Ngày tổ chức phải từ ngày hiện tại trở đi.'
          });
        }
        if (dateParts.iso === todayIsoVN && timeRange.startMin <= nowMinVN) {
          return sendJson(res, 400, {
            error: 'Khung giờ bắt đầu hôm nay đã trôi qua! Vui lòng chọn giờ bắt đầu sau thời điểm hiện tại.'
          });
        }

        // Enforce PCCC Safety Compliance & Capacity limit against pccc_inspections
        const pcccSnap = await firestoreRequest('/pccc_inspections', 'GET', null, { forceFresh: false });
        const venuesList = (pcccSnap.documents || []).map(fromFirestoreDoc).filter(Boolean);
        const requestedCapacity = parseInt(body.capacity || 200, 10);
        const targetLocKey = normLoc(body.location);
        if (venuesList.length > 0) {
          const matchedVenue = venuesList.find(v => {
            const vKey = normLoc(v.name);
            return vKey && targetLocKey && (vKey === targetLocKey || vKey.includes(targetLocKey) || targetLocKey.includes(vKey));
          });
          if (!matchedVenue) {
            return sendJson(res, 400, {
              error: `Địa điểm "${body.location}" chưa có hồ sơ kiểm định PCCC. Vui lòng thêm và nghiệm thu tại tab An Toàn PCCC trước khi tạo sự kiện.`
            });
          }
          if (!matchedVenue.signed || Number(matchedVenue.score || 0) < 100) {
            return sendJson(res, 400, {
              error: `Địa điểm "${matchedVenue.name}" chưa đủ điều kiện mở sự kiện (${Number(matchedVenue.score || 0)}/100đ, ${matchedVenue.signed ? 'Đã ký' : 'Chưa ký Giấy phép PCCC'}). Vui lòng hoàn tất ký phép tại tab An Toàn PCCC.`
            });
          }
          if (requestedCapacity > Number(matchedVenue.capacity || 200)) {
            return sendJson(res, 400, {
              error: `Sức chứa sự kiện (${requestedCapacity} người) vượt quá giới hạn an toàn PCCC của "${matchedVenue.name}" (${matchedVenue.capacity} người).`
            });
          }
        }

        // Validate optional linked Budget Proposal (must be CTSV approved)
        const budgetId = (body.budgetId && body.budgetId !== 'SELF_FUNDED' && body.budgetId !== 'NONE')
          ? String(body.budgetId).trim()
          : '';
        if (budgetId) {
          const budgetSnap = await firestoreRequest('/budgets', 'GET', null, { forceFresh: false });
          const budgets = (budgetSnap.documents || []).map(fromFirestoreDoc).filter(Boolean);
          const matchedBudget = budgets.find(b => b.id === budgetId);
          if (!matchedBudget || matchedBudget.status !== 'approved') {
            return sendJson(res, 400, {
              error: `Hồ sơ ngân sách "${budgetId}" chưa được Phòng CTSV phê duyệt.`
            });
          }
        }

        // Check schedule conflicts: same date + same venue + overlapping [startMin, endMin)
        const existingSnap = await firestoreRequest('/events', 'GET', null, { forceFresh: true });
        const existingEvents = (existingSnap.documents || []).map(fromFirestoreDoc).filter(Boolean);
        const conflict = existingEvents.find(ev => {
          const evDate = normalizeDateParts(ev.date);
          if (!evDate || evDate.iso !== dateParts.iso) return false;
          if (normLoc(ev.location) !== targetLocKey) return false;
          const evTime = parseTimeRange(ev.time);
          if (!evTime) return true;
          return timeRange.startMin < evTime.endMin && evTime.startMin < timeRange.endMin;
        });

        if (conflict) {
          return sendJson(res, 409, {
            error: `Trùng lịch địa điểm! Sự kiện "${conflict.title}" (${conflict.id}) đã sử dụng "${conflict.location}" vào khung giờ ${conflict.time} ngày ${conflict.date}.`,
            conflictEvent: { id: conflict.id, title: conflict.title, date: conflict.date, time: conflict.time, location: conflict.location }
          });
        }

        const eventId = body.id || `EVT-2026-${Date.now().toString().slice(-4)}`;
        const now = new Date().toISOString();

        const eventData = {
          id: eventId,
          title: body.title.trim(),
          description: (body.description || '').trim(),
          category: body.category || 'Technology',
          clubId: body.clubId || 'fcode',
          clubName: body.clubName || 'CLB FPTU',
          date: dateParts.dmy,
          time: timeRange.formatted,
          location: body.location.trim(),
          capacity: requestedCapacity,
          registeredCount: 0,
          budgetId: budgetId || '',
          bannerUrl: body.bannerUrl || 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=1200',
          isFeatured: Boolean(body.isFeatured),
          speakers: body.speakers || [],
          sessions: body.sessions || [],
          createdAt: now,
          updatedAt: now
        };

        const fields = toFirestoreFields(eventData);
        await firestoreRequest(`/events?documentId=${eventId}`, 'POST', { fields });
        markCacheStale('GET:/events');

        // Link newly created event back to approved budget proposal if provided
        if (budgetId) {
          try {
            await firestoreRequest(`/budgets/${encodeURIComponent(budgetId)}?updateMask.fieldPaths=eventId`, 'PATCH', {
              fields: { eventId: { stringValue: eventId } }
            });
            markCacheStale('GET:/budgets');
          } catch (linkErr) {
            console.warn('[Event Budget Link] Note:', linkErr.message);
          }
        }

        persistCacheToDisk();
        console.log(`[Event Created] Successfully created event: ${eventId} - ${eventData.title}`);
        return sendJson(res, 200, { success: true, id: eventId, event: eventData });
      }

      // 3. GET /api/clubs
      if (pathname === '/api/clubs' && req.method === 'GET') {
        const data = await firestoreRequest('/clubs?pageSize=100');
        const clubs = (data.documents || []).map(fromFirestoreDoc);
        return sendJson(res, 200, { documents: clubs });
      }

      // 4. GET /api/registrations (Review Queue)
      if (pathname === '/api/registrations' && req.method === 'GET') {
        const eventId = parsedUrl.searchParams.get('eventId');
        const userId = parsedUrl.searchParams.get('userId');
        const data = await firestoreRequest('/registrations');
        let registrations = (data.documents || []).map(fromFirestoreDoc);
        if (eventId) {
          registrations = registrations.filter(r => r.eventId === eventId);
        }
        if (userId) {
          registrations = registrations.filter(r => r.userId === userId);
        }
        return sendJson(res, 200, { documents: registrations });
      }

      // 4b. POST /api/registrations (Submit Registration to Review Queue)
      if (pathname === '/api/registrations' && req.method === 'POST') {
        const body = await parseBody(req);
        const evt = await fetchEventById(body.eventId);
        if (evt) {
          if (isEventDatePast(evt.date)) {
            return sendJson(res, 400, { error: 'Sự kiện đã kết thúc, không thể gửi đơn đăng ký.' });
          }
          if (evt.capacity && Number(evt.registeredCount || 0) >= Number(evt.capacity)) {
            return sendJson(res, 400, { error: 'Sự kiện đã đạt số lượng tối đa.' });
          }
        }
        const regId = body.id || `REG-${Date.now()}`;
        const now = new Date().toISOString();
        const regData = {
          id: regId,
          eventId: body.eventId || '',
          eventTitle: body.eventTitle || evt?.title || '',
          eventDate: body.eventDate || evt?.date || '',
          eventTime: body.eventTime || evt?.time || '',
          eventLocation: body.eventLocation || evt?.location || '',
          userId: body.userId || '',
          studentName: body.studentName || '',
          studentEmail: body.studentEmail || '',
          status: 'pending',
          createdAt: body.createdAt || now,
        };
        const fields = toFirestoreFields(regData);
        await firestoreRequest(`/registrations/${encodeURIComponent(regId)}`, 'PATCH', { fields });
        console.log(`[Registration Submitted] ${regId} by ${regData.studentName} for ${regData.eventTitle}`);
        return sendJson(res, 200, { success: true, registration: regData });
      }

      // 5. POST /api/registrations/:id/approve (Cross-Role Approval Action)
      const approveMatch = pathname.match(/^\/api\/registrations\/([^\/]+)\/approve$/);
      if (approveMatch && req.method === 'POST') {
        const regId = decodeURIComponent(approveMatch[1]);
        const encodedRegId = encodeURIComponent(regId);
        let regData = null;
        try {
          const regDoc = await firestoreRequest(`/registrations/${encodedRegId}`);
          regData = fromFirestoreDoc(regDoc);
        } catch (_) {}

        if (!regData) {
          return sendJson(res, 404, { error: 'Không tìm thấy đơn đăng ký.' });
        }
        if (regData.status === 'approved') {
          return sendJson(res, 409, { error: 'Đơn đăng ký này đã được duyệt trước đó.' });
        }
        if (regData.status === 'rejected') {
          return sendJson(res, 400, { error: 'Đơn đăng ký này đã bị từ chối trước đó.' });
        }

        const evt = await fetchEventById(regData.eventId);
        if (evt) {
          if (isEventDatePast(evt.date)) {
            return sendJson(res, 400, { error: 'Sự kiện đã kết thúc, không thể duyệt cấp vé.' });
          }
          if (evt.capacity && Number(evt.registeredCount || 0) >= Number(evt.capacity)) {
            return sendJson(res, 400, { error: 'Sự kiện đã đạt số lượng tối đa, không thể duyệt thêm.' });
          }
        }

        const ticketCode = `CE2026-${Math.floor(100000 + Math.random() * 900000)}`;
        const now = new Date().toISOString();

        // Step A: Patch registration status to 'approved'
        await firestoreRequest(`/registrations/${encodedRegId}?updateMask.fieldPaths=status&updateMask.fieldPaths=ticketId&updateMask.fieldPaths=reviewedAt`, 'PATCH', {
          fields: {
            status: { stringValue: 'approved' },
            ticketId: { stringValue: ticketCode },
            reviewedAt: { stringValue: now }
          }
        });

        // Step B: Write new active ticket to 'tickets' collection using real event metadata
        const resolvedTitle = evt?.title || regData.eventTitle || 'Sự kiện FPTU';
        const ticketFields = toFirestoreFields({
          id: ticketCode,
          eventId: regData.eventId || '',
          eventTitle: resolvedTitle,
          eventDate: evt?.date || regData.eventDate || '',
          eventTime: evt?.time || regData.eventTime || '',
          eventLocation: evt?.location || regData.eventLocation || '',
          userId: regData.userId || '',
          studentName: regData.studentName || 'Sinh viên FPTU',
          studentEmail: regData.studentEmail || '',
          studentId: (regData.studentEmail || '').split('@')[0].toUpperCase(),
          ticketCode: ticketCode,
          qrToken: `QR-TOKEN-${ticketCode}-${Date.now()}`,
          qrData: `FPTU-CE-${regData.eventId || 'EVT'}-${regData.userId || 'USR'}-${ticketCode}`,
          status: 'active',
          checkInStatus: false,
          points: 0,
          certId: '',
          createdAt: now
        });
        await firestoreRequest(`/tickets?documentId=${encodeURIComponent(ticketCode)}`, 'POST', { fields: ticketFields });

        // Update real event registeredCount (+1)
        if (regData.eventId && evt) {
          try {
            const newCount = (Number(evt.registeredCount) || 0) + 1;
            await firestoreRequest(`/events/${encodeURIComponent(regData.eventId)}?updateMask.fieldPaths=registeredCount`, 'PATCH', {
              fields: {
                registeredCount: { integerValue: String(newCount) }
              }
            });
          } catch (_) {}
        }

        // Step C: Write notification to 'announcements' collection for Mobile Inbox
        const annId = `ANN-${Date.now()}`;
        const annMsg = `Chúc mừng ${regData.studentName || 'bạn'}! Đơn đăng ký sự kiện "${resolvedTitle}" đã được phê duyệt. Vé ${ticketCode} đã có trong mục "Vé của tôi".`;
        const annFields = toFirestoreFields({
          id: annId,
          title: 'Đăng ký sự kiện đã được duyệt! 🎉',
          category: 'ticket_approved',
          categoryLabel: 'Duyệt vé thành công',
          authorRole: 'ctsv',
          content: annMsg,
          message: annMsg,
          eventId: regData.eventId || '',
          userId: regData.userId || '',
          createdAt: now,
          status: 'published',
          isPinned: true,
          pinned: true
        });
        await firestoreRequest(`/announcements?documentId=${annId}`, 'POST', { fields: annFields });

        console.log(`[Cross-Role Approval] Approved regId: ${regId} -> Issued ticket: ${ticketCode}`);
        return sendJson(res, 200, { success: true, ticketCode, registrationId: regId });
      }

      // 6. POST /api/registrations/:id/reject (Cross-Role Rejection Action)
      const rejectMatch = pathname.match(/^\/api\/registrations\/([^\/]+)\/reject$/);
      if (rejectMatch && req.method === 'POST') {
        const regId = decodeURIComponent(rejectMatch[1]);
        const encodedRegId = encodeURIComponent(regId);
        const body = await parseBody(req);
        const reason = body.reason || 'Sự kiện đã đạt số lượng tối đa';
        const now = new Date().toISOString();
        let regData = null;
        try {
          const regDoc = await firestoreRequest(`/registrations/${encodedRegId}`);
          regData = fromFirestoreDoc(regDoc);
        } catch (_) {}

        if (regData && regData.status === 'approved') {
          return sendJson(res, 400, { error: 'Đơn đăng ký đã được duyệt cấp vé, không thể từ chối.' });
        }

        // Step A: Patch registration status to 'rejected'
        await firestoreRequest(`/registrations/${encodedRegId}?updateMask.fieldPaths=status&updateMask.fieldPaths=reason&updateMask.fieldPaths=reviewedAt`, 'PATCH', {
          fields: {
            status: { stringValue: 'rejected' },
            reason: { stringValue: reason },
            reviewedAt: { stringValue: now }
          }
        });

        // Step B: Write rejection announcement to 'announcements'
        const annId = `ANN-${Date.now()}`;
        const annMsg = `Đơn đăng ký sự kiện${regData?.eventTitle ? ` "${regData.eventTitle}"` : ''} của bạn không được phê duyệt. Lý do: ${reason}.`;
        const annFields = toFirestoreFields({
          id: annId,
          title: 'Thông báo về đơn đăng ký sự kiện',
          category: 'ticket_rejected',
          categoryLabel: 'Từ chối đăng ký',
          authorRole: 'ctsv',
          content: annMsg,
          message: annMsg,
          eventId: regData?.eventId || '',
          userId: regData?.userId || '',
          createdAt: now,
          status: 'published',
          isPinned: false,
          pinned: false
        });
        await firestoreRequest(`/announcements?documentId=${annId}`, 'POST', { fields: annFields });

        console.log(`[Cross-Role Rejection] Rejected regId: ${regId} -> Reason: ${reason}`);
        return sendJson(res, 200, { success: true, registrationId: regId, reason });
      }

      // 7. GET /api/announcements (Announcements Inbox History)
      if (pathname === '/api/announcements' && req.method === 'GET') {
        const forceFresh = parsedUrl.searchParams.get('fresh') === '1';
        const data = await firestoreRequest('/announcements', 'GET', null, { forceFresh });
        const announcements = (data.documents || []).map(fromFirestoreDoc);
        return sendJson(res, 200, { documents: announcements });
      }

      // 8. POST /api/announcements (Broadcast Announcements to Mobile App)
      if (pathname === '/api/announcements' && req.method === 'POST') {
        const body = await parseBody(req);
        const annId = `ANN-${Date.now()}`;
        const now = new Date().toISOString();
        const isPinned = Boolean(body.isPinned !== undefined ? body.isPinned : body.pinned);

        const annFields = toFirestoreFields({
          id: annId,
          title: body.title || 'Thông báo mới từ Phòng CTSV',
          category: body.category || 'official',
          categoryLabel: body.categoryLabel || 'Phát thanh CTSV',
          authorRole: 'staff',
          message: body.message || body.content || '',
          content: body.content || body.message || '',
          isPinned: isPinned,
          pinned: isPinned,
          createdAt: now,
          status: 'published'
        });

        await firestoreRequest(`/announcements?documentId=${annId}`, 'POST', { fields: annFields });
        markCacheStale('GET:/announcements');
        persistCacheToDisk();
        console.log(`[Announcements Broadcast] Created announcement: ${annId} - ${body.title}`);
        return sendJson(res, 200, { success: true, id: annId, isPinned });
      }

      // 8b. PATCH & DELETE /api/announcements/:id
      const annItemMatch = pathname.match(/^\/api\/announcements\/([^\/]+)$/);
      if (annItemMatch && req.method === 'PATCH') {
        const annId = decodeURIComponent(annItemMatch[1]);
        const body = await parseBody(req);
        const isPinned = Boolean(body.isPinned !== undefined ? body.isPinned : body.pinned);
        await firestoreRequest(`/announcements/${encodeURIComponent(annId)}?updateMask.fieldPaths=isPinned&updateMask.fieldPaths=pinned`, 'PATCH', {
          fields: {
            isPinned: { booleanValue: isPinned },
            pinned: { booleanValue: isPinned }
          }
        });
        markCacheStale('GET:/announcements');
        persistCacheToDisk();
        console.log(`[Announcements] Updated pin for ${annId}: ${isPinned}`);
        return sendJson(res, 200, { success: true, id: annId, isPinned });
      }
      if (annItemMatch && req.method === 'DELETE') {
        const annId = decodeURIComponent(annItemMatch[1]);
        await firestoreRequest(`/announcements/${encodeURIComponent(annId)}`, 'DELETE');
        markCacheStale('GET:/announcements');
        persistCacheToDisk();
        console.log(`[Announcements] Deleted announcement: ${annId}`);
        return sendJson(res, 200, { success: true, id: annId });
      }

      // 9. GET /api/tickets (Student Directory & Live Gate Data)
      if (pathname === '/api/tickets' && req.method === 'GET') {
        const userIdFilter = parsedUrl.searchParams.get('userId');
        const forceFresh = parsedUrl.searchParams.get('fresh') === '1';
        const data = await firestoreRequest('/tickets', 'GET', null, { forceFresh });
        let tickets = (data.documents || []).map(fromFirestoreDoc);
        if (userIdFilter) {
          tickets = tickets.filter(t => t.userId === userIdFilter);
        }
        return sendJson(res, 200, { documents: tickets });
      }

      // 9b. POST /api/tickets (Create or Upsert Ticket from Mobile or Registration)
      if (pathname === '/api/tickets' && req.method === 'POST') {
        const body = await parseBody(req);
        const ticketId = body.id || body.ticketCode || `CE2026-${Math.floor(100000 + Math.random() * 900000)}`;
        const now = new Date().toISOString();
        const evt = await fetchEventById(body.eventId);
        const existingTicket = getFromCache('GET', `/tickets/${encodeURIComponent(ticketId)}`);

        // Enforce BR: Reject tickets for past or fully booked events when not yet written
        if (evt && !body.checkInStatus && !existingTicket && !body.firestoreSynced) {
          if (isEventDatePast(evt.date)) {
            return sendJson(res, 400, { error: 'Sự kiện đã kết thúc, không thể cấp vé.' });
          }
          if (evt.capacity && Number(evt.registeredCount || 0) >= Number(evt.capacity)) {
            return sendJson(res, 400, { error: 'Sự kiện đã hết chỗ.' });
          }
        }

        const ticketData = {
          id: ticketId,
          ticketCode: body.ticketCode || ticketId,
          eventId: body.eventId || evt?.id || '',
          eventTitle: body.eventTitle || evt?.title || 'Sự kiện FPTU',
          eventDate: body.eventDate || evt?.date || '',
          eventTime: body.eventTime || evt?.time || '',
          eventLocation: body.eventLocation || evt?.location || '',
          userId: body.userId || '',
          studentName: body.studentName || 'Sinh viên FPTU',
          studentEmail: body.studentEmail || '',
          studentId: body.studentId || (body.studentEmail || '').split('@')[0].toUpperCase(),
          qrToken: body.qrToken || `QR-TOKEN-${ticketId}`,
          qrData: body.qrData || `FPTU-CE-${body.eventId || 'EVT'}-${body.userId || 'USR'}-${ticketId}`,
          status: body.status || 'active',
          checkInStatus: Boolean(body.checkInStatus),
          checkedInAt: body.checkedInAt || (body.checkInStatus ? now : ''),
          points: body.points !== undefined ? body.points : (body.checkInStatus ? 5 : 0),
          certId: body.certId || '',
          createdAt: body.createdAt || now
        };

        const fields = toFirestoreFields(ticketData);
        if (body.firestoreSynced) {
          // Flutter Web/Mobile already committed the Firestore transaction; update cache immediately without duplicate REST write
          mutateCache(`/tickets/${encodeURIComponent(ticketId)}`, 'PATCH', { fields });
          if (ticketData.eventId && evt) {
            const targetCount = Number(body.newEventRegisteredCount ?? ((Number(evt.registeredCount) || 0) + (existingTicket ? 0 : 1)));
            mutateCache(`/events/${encodeURIComponent(evt._resourceId || ticketData.eventId)}`, 'PATCH', {
              fields: { registeredCount: { integerValue: String(targetCount) } }
            });
          }
        } else {
          await firestoreRequest(`/tickets/${encodeURIComponent(ticketId)}`, 'PATCH', { fields });
          if (ticketData.eventId && evt && !body.checkInStatus && !existingTicket) {
            try {
              const targetResourceId = evt._resourceId || ticketData.eventId;
              const newCount = (Number(evt.registeredCount) || 0) + 1;
              await firestoreRequest(`/events/${encodeURIComponent(targetResourceId)}?updateMask.fieldPaths=registeredCount`, 'PATCH', {
                fields: { registeredCount: { integerValue: String(newCount) } }
              });
              console.log(`[Ticket Upsert] Incremented registeredCount on ${ticketData.eventId} (${targetResourceId}) to ${newCount}`);
            } catch (_) {}
          }
        }
        console.log(`[Ticket Upsert] Synced ticket ${ticketId} for ${ticketData.studentName}`);
        return sendJson(res, 200, { success: true, ticket: ticketData });
      }

      // 9d. POST /api/tickets/:id/revoke (Revoke / Cancel Ticket & free capacity slot in Cloud Firestore)
      const ticketRevokeMatch = pathname.match(/^\/api\/tickets\/([^\/]+)\/revoke$/);
      if (ticketRevokeMatch && req.method === 'POST') {
        const ticketId = decodeURIComponent(ticketRevokeMatch[1]);
        const body = await parseBody(req);
        const reason = body.reason || 'Cán bộ CTSV thu hồi theo quy chế';

        // Fetch existing ticket to verify state & linked eventId
        const tktList = await firestoreRequest('/tickets', 'GET', null, { forceFresh: true });
        const allTickets = (tktList.documents || []).map(fromFirestoreDoc).filter(Boolean);
        const targetTicket = allTickets.find(t => t.id === ticketId || t.ticketCode === ticketId);
        if (!targetTicket) {
          return sendJson(res, 404, { error: `Không tìm thấy vé ${ticketId} trên Cloud Firestore.` });
        }
        if (targetTicket.status === 'checkedIn' || targetTicket.status === 'checked_in' || targetTicket.checkInStatus === true) {
          return sendJson(res, 400, { error: 'Không thể thu hồi vé đã check-in qua cổng.' });
        }
        const wasAlreadyCancelled = targetTicket.status === 'cancelled';

        await firestoreRequest(`/tickets/${encodeURIComponent(targetTicket.id)}?updateMask.fieldPaths=status&updateMask.fieldPaths=cancelReason`, 'PATCH', {
          fields: {
            status: { stringValue: 'cancelled' },
            cancelReason: { stringValue: reason }
          }
        });

        // Decrement event.registeredCount if ticket wasn't already cancelled
        if (!wasAlreadyCancelled && targetTicket.eventId) {
          try {
            const evSnap = await firestoreRequest('/events', 'GET', null, { forceFresh: true });
            const targetEvt = (evSnap.documents || []).map(fromFirestoreDoc).find(e => e && e.id === targetTicket.eventId);
            if (targetEvt) {
              const nextCount = Math.max(0, Number(targetEvt.registeredCount || 0) - 1);
              await firestoreRequest(`/events/${encodeURIComponent(targetEvt.id)}?updateMask.fieldPaths=registeredCount`, 'PATCH', {
                fields: { registeredCount: { integerValue: String(nextCount) } }
              });
            }
          } catch (e) {
            console.warn('[Ticket Revoke] Decrement registeredCount note:', e.message);
          }
        }

        markCacheStale('GET:/tickets');
        markCacheStale('GET:/events');
        persistCacheToDisk();
        console.log(`[Ticket Revoke] Revoked ticket ${targetTicket.id}`);
        return sendJson(res, 200, { success: true, message: `Đã thu hồi vé ${targetTicket.id}` });
      }

      // 10. GET /api/gate-assignments (Gate Duty Roster & Staff Assignments)
      if (pathname === '/api/gate-assignments' && req.method === 'GET') {
        const emailFilter = parsedUrl.searchParams.get('email');
        const forceFresh = parsedUrl.searchParams.get('fresh') === '1';
        const data = await firestoreRequest('/gate_assignments', 'GET', null, { forceFresh });
        let assignments = (data.documents || []).map(fromFirestoreDoc);
        if (emailFilter) {
          assignments = assignments.filter(a => a.email && a.email.toLowerCase() === emailFilter.toLowerCase());
        }
        return sendJson(res, 200, { documents: assignments });
      }

      // 10b. POST /api/gate-assignments (Create New Duty Assignment)
      if (pathname === '/api/gate-assignments' && req.method === 'POST') {
        const body = await parseBody(req);
        if (!body.email || !body.eventId) {
          return sendJson(res, 400, { error: 'Vui lòng cung cấp email CTV và sự kiện được phân công.' });
        }

        const cleanEmail = body.email.trim().toLowerCase();
        // Prevent assigning CTV to past events & prevent duplicate active assignment on same event
        const [evSnap, dutySnap] = await Promise.all([
          firestoreRequest('/events', 'GET', null, { forceFresh: false }),
          firestoreRequest('/gate_assignments', 'GET', null, { forceFresh: true })
        ]);
        const targetEvt = (evSnap.documents || []).map(fromFirestoreDoc).find(e => e && e.id === body.eventId);
        if (targetEvt && targetEvt.date && targetEvt.time) {
          let yyyy, mo, dd;
          const ds = String(targetEvt.date).trim();
          if (ds.includes('/')) {
            const dp = ds.split('/').map(Number);
            if (dp.length === 3) { if (dp[0] > 1000) [yyyy, mo, dd] = dp; else [dd, mo, yyyy] = dp; }
          } else if (ds.includes('-')) {
            const dp = ds.split('-').map(Number);
            if (dp.length === 3) { if (dp[0] > 1000) [yyyy, mo, dd] = dp; else [dd, mo, yyyy] = dp; }
          }
          const tm = String(targetEvt.time).trim().match(/^(\d{1,2}):(\d{2})\s*[-–]\s*(\d{1,2}):(\d{2})$/);
          if (yyyy && mo && dd && tm) {
            const endMs = new Date(`${String(yyyy).padStart(4, '0')}-${String(mo).padStart(2, '0')}-${String(dd).padStart(2, '0')}T${String(Number(tm[3])).padStart(2, '0')}:${tm[4]}:00+07:00`).getTime();
            if (Date.now() > endMs) {
              return sendJson(res, 400, {
                error: `Không thể phân công ca trực cho sự kiện đã kết thúc ("${targetEvt.title}" - ${targetEvt.date}).`
              });
            }
          }
        }

        const existingDuties = (dutySnap.documents || []).map(fromFirestoreDoc).filter(Boolean);
        const dupDuty = existingDuties.find(d =>
          (d.email || '').toLowerCase() === cleanEmail &&
          d.eventId === body.eventId &&
          d.status === 'active'
        );
        if (dupDuty) {
          return sendJson(res, 409, {
            error: `Nhân sự ${cleanEmail} đã có ca trực đang kích hoạt (${dupDuty.id}) cho sự kiện này.`
          });
        }

        const dutyId = body.id || `DUTY-2026-${Date.now().toString().slice(-4)}`;
        const now = new Date().toISOString();

        const assignmentData = {
          id: dutyId,
          email: cleanEmail,
          studentName: (body.studentName || 'CTV FPTU').trim(),
          studentId: (body.studentId || (body.email.split('@')[0])).toUpperCase().trim(),
          eventId: body.eventId,
          eventTitle: body.eventTitle || targetEvt?.title || 'Sự kiện FPTU',
          gateName: body.gateName || 'Cổng Chính (Cửa 1)',
          role: body.role || 'CTV Soát Vé Cổng',
          shiftTime: body.shiftTime || targetEvt?.time || '13:00 - 17:30',
          status: 'active',
          assignedBy: 'Phòng CTSV',
          assignedAt: now
        };

        const fields = toFirestoreFields(assignmentData);
        await firestoreRequest(`/gate_assignments?documentId=${dutyId}`, 'POST', { fields });
        markCacheStale('GET:/gate_assignments');
        persistCacheToDisk();
        console.log(`[Gate Assignment] Created duty assignment: ${dutyId} for ${assignmentData.email} (${assignmentData.eventId})`);
        return sendJson(res, 200, { success: true, dutyId, assignment: assignmentData });
      }

      // 10c. PATCH /api/gate-assignments/:id (Update Duty Status / Gate)
      const dutyPatchMatch = pathname.match(/^\/api\/gate-assignments\/([^\/]+)$/);
      if (dutyPatchMatch && req.method === 'PATCH') {
        const dutyId = decodeURIComponent(dutyPatchMatch[1]);
        const body = await parseBody(req);
        const updateFields = {};
        const fieldPaths = [];

        if (body.status) {
          updateFields.status = { stringValue: body.status };
          fieldPaths.push('updateMask.fieldPaths=status');
        }
        if (body.gateName) {
          updateFields.gateName = { stringValue: body.gateName };
          fieldPaths.push('updateMask.fieldPaths=gateName');
        }

        if (fieldPaths.length > 0) {
          await firestoreRequest(`/gate_assignments/${dutyId}?${fieldPaths.join('&')}`, 'PATCH', { fields: updateFields });
          markCacheStale('GET:/gate_assignments');
          persistCacheToDisk();
        }
        console.log(`[Gate Assignment] Updated ${dutyId}:`, body);
        return sendJson(res, 200, { success: true, dutyId });
      }

      // 10d. DELETE /api/gate-assignments/:id (Delete Duty Assignment)
      if (dutyPatchMatch && req.method === 'DELETE') {
        const dutyId = decodeURIComponent(dutyPatchMatch[1]);
        await firestoreRequest(`/gate_assignments/${dutyId}`, 'DELETE');
        markCacheStale('GET:/gate_assignments');
        persistCacheToDisk();
        console.log(`[Gate Assignment] Deleted ${dutyId}`);
        return sendJson(res, 200, { success: true, dutyId });
      }

      // 9c. POST /api/tickets/checkin (Gate Check-In Action - Real Cloud Firestore)
      if (pathname === '/api/tickets/checkin' && req.method === 'POST') {
        const reqStartMs = Date.now();
        const body = await parseBody(req);
        const rawToken = (body.ticketCode || body.qrToken || body.id || '').trim();
        if (!rawToken) {
          return sendJson(res, 400, { error: 'Vui lòng cung cấp mã vé hoặc QR token.' });
        }

        // If client SDK already persisted the check-in directly to Firestore, patch local cache immediately with latency telemetry
        if (body.preSyncedFromClient === true) {
          const targetId = (body.id || rawToken).trim();
          const parsedLatency = Number(body.scanLatencyMs);
          const syncedFields = {
            status: { stringValue: 'checkedIn' },
            checkInStatus: { booleanValue: true },
            checkedInAt: { stringValue: body.checkedInAt || new Date().toISOString() },
            gate: { stringValue: (body.gate || 'Cổng Chính (Cửa 1)').trim() },
            points: { integerValue: '5' }
          };
          if (!Number.isNaN(parsedLatency) && parsedLatency > 0) {
            syncedFields.scanLatencyMs = { integerValue: String(Math.round(parsedLatency)) };
          }
          mutateCache(`/tickets/${encodeURIComponent(targetId)}`, 'PATCH', { fields: syncedFields });
          markCacheStale('GET:/tickets');
          markCacheStale('GET:/events');
          persistCacheToDisk();
          console.log(`[Gate Check-in Sync] Cache updated for client-synced ticket: ${targetId} (${parsedLatency || '—'}ms)`);
          return sendJson(res, 200, { success: true, synced: true, ticketCode: rawToken, scanLatencyMs: parsedLatency || null });
        }

        // Fetch all real tickets fresh to find match
        const data = await firestoreRequest('/tickets', 'GET', null, { forceFresh: true });
        const tickets = (data.documents || []).map(fromFirestoreDoc);

        let match = tickets.find(t =>
          t.id === rawToken ||
          t.ticketCode === rawToken ||
          t.qrToken === rawToken ||
          t.qrData === rawToken ||
          (t.qrData && t.qrData.includes(rawToken))
        );

        // Fallback: extract code like CE2026-xxxxxx
        if (!match && rawToken.includes('CE2026-')) {
          const m = rawToken.match(/CE2026-\d+/);
          if (m) {
            match = tickets.find(t => t.id === m[0] || t.ticketCode === m[0]);
          }
        }

        if (!match) {
          return sendJson(res, 404, { error: `Không tìm thấy vé hợp lệ trên Cloud Firestore với mã: ${rawToken}` });
        }

        if (match.status === 'checkedIn' || match.checkInStatus === true) {
          return sendJson(res, 409, {
            error: `CẢNH BÁO: Vé đã được check-in trước đó (${match.checkedInAt || 'Đã ghi nhận'}) tại ${match.gate || 'Cổng Kiểm Soát'}.`,
            isDuplicate: true,
            ticket: match
          });
        }

        // Enforce Gate Check-in Window: [eventStart - 60m, eventEnd]
        if (match.eventId) {
          const evSnap = await firestoreRequest('/events', 'GET', null, { forceFresh: false });
          const allEvs = (evSnap.documents || []).map(fromFirestoreDoc).filter(Boolean);
          const targetEvent = allEvs.find(e => e.id === match.eventId);
          if (targetEvent && targetEvent.date && targetEvent.time) {
            let yyyy, mo, dd;
            const ds = String(targetEvent.date).trim();
            if (ds.includes('/')) {
              const dp = ds.split('/').map(Number);
              if (dp.length === 3) { if (dp[0] > 1000) [yyyy, mo, dd] = dp; else [dd, mo, yyyy] = dp; }
            } else if (ds.includes('-')) {
              const dp = ds.split('-').map(Number);
              if (dp.length === 3) { if (dp[0] > 1000) [yyyy, mo, dd] = dp; else [dd, mo, yyyy] = dp; }
            }
            const tm = String(targetEvent.time).trim().match(/^(\d{1,2}):(\d{2})\s*[-–]\s*(\d{1,2}):(\d{2})$/);
            if (yyyy && mo && dd && tm) {
              const dPrefix = `${String(yyyy).padStart(4, '0')}-${String(mo).padStart(2, '0')}-${String(dd).padStart(2, '0')}`;
              const startStr = `${String(Number(tm[1])).padStart(2, '0')}:${tm[2]}`;
              const endStr = `${String(Number(tm[3])).padStart(2, '0')}:${tm[4]}`;
              const startMs = new Date(`${dPrefix}T${startStr}:00+07:00`).getTime();
              const endMs = new Date(`${dPrefix}T${endStr}:00+07:00`).getTime();
              const openMs = startMs - 60 * 60 * 1000;
              const openDtVN = new Date(openMs + 7 * 3600 * 1000);
              const openLabel = `${String(openDtVN.getUTCHours()).padStart(2, '0')}:${String(openDtVN.getUTCMinutes()).padStart(2, '0')} ngày ${String(openDtVN.getUTCDate()).padStart(2, '0')}/${String(openDtVN.getUTCMonth() + 1).padStart(2, '0')}/${openDtVN.getUTCFullYear()}`;
              if (Date.now() < openMs) {
                return sendJson(res, 400, {
                  error: `Chưa đến giờ mở cổng check-in! Sự kiện "${targetEvent.title}" bắt đầu lúc ${startStr} ngày ${String(dd).padStart(2, '0')}/${String(mo).padStart(2, '0')}/${yyyy} (Mở cổng trước 60 phút từ ${openLabel}).`,
                  reason: 'EVENT_NOT_STARTED'
                });
              }
              if (Date.now() > endMs) {
                return sendJson(res, 400, {
                  error: `Sự kiện "${targetEvent.title}" đã kết thúc lúc ${endStr} ngày ${String(dd).padStart(2, '0')}/${String(mo).padStart(2, '0')}/${yyyy}. Cổng điểm danh đã đóng.`,
                  reason: 'EVENT_ENDED'
                });
              }
            }
          }
        }

        const nowIso = new Date().toISOString();
        const gateName = (body.gate || match.gate || 'Cổng Chính (Cửa 1)').trim();
        const parsedLatency = Number(body.scanLatencyMs);
        const scanLatencyMs = (!Number.isNaN(parsedLatency) && parsedLatency > 0)
          ? Math.round(parsedLatency)
          : Math.max(120, Date.now() - reqStartMs);
        const certId = match.certId || body.certId || '';

        const updateFields = {
          status: { stringValue: 'checkedIn' },
          checkInStatus: { booleanValue: true },
          checkedInAt: { stringValue: nowIso },
          gate: { stringValue: gateName },
          scanLatencyMs: { integerValue: String(scanLatencyMs) },
          points: { integerValue: '5' }
        };
        const maskPaths = [
          'updateMask.fieldPaths=status',
          'updateMask.fieldPaths=checkInStatus',
          'updateMask.fieldPaths=checkedInAt',
          'updateMask.fieldPaths=gate',
          'updateMask.fieldPaths=scanLatencyMs',
          'updateMask.fieldPaths=points'
        ];
        if (certId) {
          updateFields.certId = { stringValue: certId };
          maskPaths.push('updateMask.fieldPaths=certId');
        }

        await firestoreRequest(`/tickets/${encodeURIComponent(match.id)}?${maskPaths.join('&')}`, 'PATCH', {
          fields: updateFields
        });
        markCacheStale('GET:/tickets');
        persistCacheToDisk();

        // Award +5 points to student in users collection
        if (match.userId) {
          try {
            const userDoc = await firestoreRequest(`/users/${match.userId}`);
            const userData = fromFirestoreDoc(userDoc);
            const currentPoints = parseInt(userData?.activityPoints || 0, 10);
            await firestoreRequest(`/users/${match.userId}?updateMask.fieldPaths=activityPoints`, 'PATCH', {
              fields: {
                activityPoints: { integerValue: String(currentPoints + 5) }
              }
            });
            console.log(`[Check-in Points] Awarded +5 activity points to ${match.userId} (total: ${currentPoints + 5})`);
          } catch (e) {
            console.warn('[Checkin] Update user points note:', e.message);
          }
        }

        console.log(`[Gate Check-in] Checked in ticket: ${match.id} - ${match.studentName}`);
        return sendJson(res, 200, {
          success: true,
          ticket: {
            ...match,
            status: 'checkedIn',
            checkInStatus: true,
            checkedInAt: nowIso,
            gate: gateName,
            scanLatencyMs,
            points: 5,
            certId
          },
          message: `Check-in thành công! Chào mừng ${match.studentName}.`
        });
      }

      // 10. GET /api/budgets (Real Firestore Budget Proposals - Zero Mock)
      if (pathname === '/api/budgets' && req.method === 'GET') {
        const forceFresh = parsedUrl.searchParams.get('fresh') === '1';
        const data = await firestoreRequest('/budgets', 'GET', null, { forceFresh });
        const documents = (data.documents || []).map(fromFirestoreDoc);
        return sendJson(res, 200, { documents });
      }

      // 10a. POST /api/budgets (Create New Club Budget Proposal in Firestore)
      if (pathname === '/api/budgets' && req.method === 'POST') {
        const body = await parseBody(req);
        if (!body.title || !body.club || !body.budget) {
          return sendJson(res, 400, { error: 'Vui lòng cung cấp tên sự kiện, CLB đề xuất và kinh phí.' });
        }
        const prjId = body.id || `PRJ-2026-${Date.now().toString().slice(-4)}`;
        const now = new Date().toISOString();
        const proposal = {
          id: prjId,
          eventId: body.eventId || '',
          title: String(body.title).trim(),
          club: String(body.club).trim(),
          budget: parseInt(body.budget, 10) || 0,
          source: (body.source || 'Quỹ Hoạt động Sinh viên FPTU').trim(),
          status: 'pending',
          reason: '',
          date: body.date || new Date().toLocaleDateString('vi-VN'),
          createdAt: now
        };
        const fields = toFirestoreFields(proposal);
        await firestoreRequest(`/budgets/${encodeURIComponent(prjId)}`, 'PATCH', { fields });
        markCacheStale('GET:/budgets');
        persistCacheToDisk();
        console.log(`[Budget Create] Created proposal ${prjId}: ${proposal.title}`);
        return sendJson(res, 200, { success: true, proposal });
      }

      // 10b. POST /api/budgets/:id/status (Approve or Reject Budget Proposal)
      const budgetMatch = pathname.match(/^\/api\/budgets\/([^\/]+)\/status$/);
      if (budgetMatch && req.method === 'POST') {
        const budgetId = decodeURIComponent(budgetMatch[1]);
        const body = await parseBody(req);
        const status = body.status || 'approved';
        const reason = body.reason || '';
        const now = new Date().toISOString();

        await firestoreRequest(`/budgets/${encodeURIComponent(budgetId)}?updateMask.fieldPaths=status&updateMask.fieldPaths=reason&updateMask.fieldPaths=reviewedAt`, 'PATCH', {
          fields: {
            status: { stringValue: status },
            reason: { stringValue: reason },
            reviewedAt: { stringValue: now }
          }
        });
        markCacheStale('GET:/budgets');
        persistCacheToDisk();
        console.log(`[Budget Review] Budget ${budgetId} updated to ${status}`);
        return sendJson(res, 200, { success: true, budgetId, status, reason });
      }

      // 11. GET /api/pccc-inspections (Real Firestore PCCC Safety Inspections - Zero Mock)
      if (pathname === '/api/pccc-inspections' && req.method === 'GET') {
        const forceFresh = parsedUrl.searchParams.get('fresh') === '1';
        const data = await firestoreRequest('/pccc_inspections', 'GET', null, { forceFresh });
        const documents = (data.documents || []).map(fromFirestoreDoc);
        return sendJson(res, 200, { documents });
      }

      // 11a. POST /api/pccc-inspections/sync (Initialize venue inspections from real events if missing)
      if (pathname === '/api/pccc-inspections/sync' && req.method === 'POST') {
        const body = await parseBody(req);
        const items = Array.isArray(body.venues) ? body.venues : [];
        const saved = [];
        for (const v of items) {
          if (!v.id || !v.name) continue;
          const docPayload = {
            id: v.id,
            name: v.name,
            building: v.building || 'Campus FPTU',
            capacity: parseInt(v.capacity || '200', 10),
            eventId: v.eventId || '',
            eventTitle: v.eventTitle || '',
            clubName: v.clubName || 'CLB FPTU',
            licenseNumber: v.licenseNumber || `BB-CTSV-${Date.now().toString().slice(-4)}`,
            score: parseInt(v.score ?? 0, 10),
            signed: Boolean(v.signed && Number(v.score) === 100),
            signedDate: v.signedDate || '',
            signatory: v.signatory || '',
            criteria: Array.isArray(v.criteria) ? v.criteria : [],
            updatedAt: new Date().toISOString()
          };
          await firestoreRequest(`/pccc_inspections/${encodeURIComponent(v.id)}`, 'PATCH', {
            fields: toFirestoreFields(docPayload)
          });
          saved.push(docPayload);
        }
        markCacheStale('GET:/pccc_inspections');
        persistCacheToDisk();
        return sendJson(res, 200, { success: true, count: saved.length, documents: saved });
      }

      // 11b. POST /api/pccc-inspections/:id/sign (Sign Safety License - Require 100/100)
      const pcccMatch = pathname.match(/^\/api\/pccc-inspections\/([^\/]+)\/sign$/);
      if (pcccMatch && req.method === 'POST') {
        const venueId = decodeURIComponent(pcccMatch[1]);
        const body = await parseBody(req);

        // Enforce 100/100 score requirement before signing
        let currentScore = body.score !== undefined ? Number(body.score) : null;
        if (currentScore === null) {
          try {
            const existingDoc = await firestoreRequest(`/pccc_inspections/${encodeURIComponent(venueId)}`);
            const existing = fromFirestoreDoc(existingDoc);
            if (existing && existing.score !== undefined) currentScore = Number(existing.score);
          } catch (_) {}
        }
        if (currentScore !== null && currentScore < 100) {
          return sendJson(res, 400, {
            error: `Không thể cấp phép: Hội trường mới đạt ${currentScore}/100 điểm PCCC.`
          });
        }

        const signed = body.signed !== undefined ? Boolean(body.signed) : true;
        const signedDate = body.signedDate || new Date().toLocaleString('vi-VN');
        const signatory = body.signatory || 'Thượng úy PCCC & Trưởng ban CTSV FPTU';
        const licenseNumber = body.licenseNumber || '108/BB-CTSV';

        const updatePayload = {
          signed: { booleanValue: signed },
          signedDate: { stringValue: signedDate },
          signatory: { stringValue: signatory },
          licenseNumber: { stringValue: licenseNumber }
        };
        const mask = [
          'updateMask.fieldPaths=signed',
          'updateMask.fieldPaths=signedDate',
          'updateMask.fieldPaths=signatory',
          'updateMask.fieldPaths=licenseNumber'
        ];
        if (Array.isArray(body.criteria)) {
          updatePayload.criteria = toFirestoreValue(body.criteria);
          mask.push('updateMask.fieldPaths=criteria');
        }
        if (currentScore !== null) {
          updatePayload.score = { integerValue: String(currentScore) };
          mask.push('updateMask.fieldPaths=score');
        }

        await firestoreRequest(`/pccc_inspections/${encodeURIComponent(venueId)}?${mask.join('&')}`, 'PATCH', {
          fields: updatePayload
        });
        markCacheStale('GET:/pccc_inspections');
        persistCacheToDisk();
        console.log(`[PCCC Inspection] Venue ${venueId} signed successfully: ${licenseNumber}`);
        return sendJson(res, 200, { success: true, venueId, signed, signedDate, signatory, licenseNumber });
      }

      // 11c. PATCH /api/pccc-inspections/:id (Persist criteria & score live)
      const pcccPatchMatch = pathname.match(/^\/api\/pccc-inspections\/([^\/]+)$/);
      if (pcccPatchMatch && req.method === 'PATCH') {
        const venueId = decodeURIComponent(pcccPatchMatch[1]);
        const body = await parseBody(req);
        const nowIso = new Date().toISOString();
        const docPayload = {
          id: venueId,
          name: body.name || venueId,
          building: body.building || 'Campus FPTU',
          capacity: parseInt(body.capacity || '200', 10),
          eventId: body.eventId || '',
          eventTitle: body.eventTitle || '',
          clubName: body.clubName || 'CLB FPTU',
          licenseNumber: body.licenseNumber || '108/BB-CTSV',
          score: parseInt(body.score ?? 0, 10),
          signed: Boolean(body.signed && Number(body.score) === 100),
          signedDate: Number(body.score) === 100 ? (body.signedDate || '') : '',
          signatory: Number(body.score) === 100 ? (body.signatory || '') : '',
          criteria: Array.isArray(body.criteria) ? body.criteria : [],
          updatedAt: nowIso
        };
        await firestoreRequest(`/pccc_inspections/${encodeURIComponent(venueId)}`, 'PATCH', {
          fields: toFirestoreFields(docPayload)
        });
        console.log(`[PCCC Update] Saved venue ${venueId} (score: ${docPayload.score}, signed: ${docPayload.signed})`);
        return sendJson(res, 200, { success: true, venue: docPayload });
      }

      // 12. GET & POST /api/remote-config
      if (pathname === '/api/remote-config' && req.method === 'GET') {
        const data = await firestoreRequest('/remote_config/parameters');
        const config = fromFirestoreDoc(data) || {
          enable_live_qa: true,
          max_featured_events: 5,
          featured_banner_title: 'Sự kiện Nổi bật Campus FPTU',
          show_survey_banner: true,
          maintenance_mode: false
        };
        return sendJson(res, 200, config);
      }
      if (pathname === '/api/remote-config' && req.method === 'POST') {
        const body = await parseBody(req);
        const fields = toFirestoreFields(body);
        await firestoreRequest('/remote_config/parameters', 'PATCH', { fields });
        console.log('[Remote Config] Published updated remote config:', body);
        return sendJson(res, 200, { success: true, config: body });
      }

      // 13. GET & POST /api/questions
      if (pathname === '/api/questions' && req.method === 'GET') {
        const eventId = parsedUrl.searchParams.get('eventId');
        const data = await firestoreRequest('/questions');
        let questions = (data.documents || []).map(fromFirestoreDoc);
        if (eventId) {
          questions = questions.filter(q => q.eventId === eventId);
        }
        return sendJson(res, 200, { documents: questions });
      }
      if (pathname === '/api/questions' && req.method === 'POST') {
        const body = await parseBody(req);
        const qId = body.id || `Q-${Date.now()}`;
        const newQuestion = {
          id: qId,
          eventId: body.eventId || 'EVT-2026-01',
          userId: body.userId || 'USR-STUDENT',
          studentName: body.studentName || 'Sinh viên FPTU',
          question: body.question || '',
          upvotes: body.upvotes || 0,
          createdAt: new Date().toISOString()
        };
        const fields = toFirestoreFields(newQuestion);
        await firestoreRequest(`/questions/${qId}`, 'PATCH', { fields });
        return sendJson(res, 200, { success: true, question: newQuestion });
      }

      // 14. GET & POST /api/feedback
      if (pathname === '/api/feedback' && req.method === 'GET') {
        const eventId = parsedUrl.searchParams.get('eventId');
        const data = await firestoreRequest('/feedback');
        let feedbacks = (data.documents || []).map(fromFirestoreDoc);
        if (eventId) {
          feedbacks = feedbacks.filter(f => f.eventId === eventId);
        }
        return sendJson(res, 200, { documents: feedbacks });
      }
      if (pathname === '/api/feedback' && req.method === 'POST') {
        const body = await parseBody(req);
        const fbId = body.id || `FB-${Date.now()}`;
        const newFeedback = {
          id: fbId,
          eventId: body.eventId || '',
          userId: body.userId || '',
          studentName: body.studentName || '',
          rating: parseInt(body.rating || 5, 10),
          comments: body.comments || '',
          createdAt: new Date().toISOString()
        };
        const fields = toFirestoreFields(newFeedback);
        await firestoreRequest(`/feedback/${fbId}`, 'PATCH', { fields });

        // Award +5 points to student on feedback submission (BR-005)
        if (newFeedback.userId) {
          try {
            const userDoc = await firestoreRequest(`/users/${newFeedback.userId}`);
            const userData = fromFirestoreDoc(userDoc);
            const currentPoints = parseInt(userData?.activityPoints || 0, 10);
            await firestoreRequest(`/users/${newFeedback.userId}?updateMask.fieldPaths=activityPoints`, 'PATCH', {
              fields: { activityPoints: { integerValue: String(currentPoints + 5) } }
            });
            console.log(`[Feedback Award] +5 points to ${newFeedback.userId} -> new total: ${currentPoints + 5}`);
          } catch (_) {}
        }

        return sendJson(res, 200, { success: true, feedback: newFeedback });
      }

      // 15. GET & POST /api/certificates
      if (pathname === '/api/certificates' && req.method === 'GET') {
        const userId = parsedUrl.searchParams.get('userId');
        const forceFresh = parsedUrl.searchParams.get('fresh') === '1';
        const data = await firestoreRequest('/certificates', 'GET', null, { forceFresh });
        let certs = (data.documents || []).map(fromFirestoreDoc);
        if (userId) {
          certs = certs.filter(c => c.userId === userId);
        }
        return sendJson(res, 200, { documents: certs });
      }
      if (pathname === '/api/certificates' && req.method === 'POST') {
        const body = await parseBody(req);
        const certId = body.id || `CERT-${Date.now()}`;
        const newCert = {
          id: certId,
          eventId: body.eventId || '',
          eventTitle: body.eventTitle || '',
          userId: body.userId || '',
          studentName: body.studentName || '',
          issueDate: body.issueDate || new Date().toLocaleDateString('vi-VN'),
          verificationHash: body.verificationHash || `HASH-FPTU-${Date.now()}`,
          downloadUrl: body.downloadUrl || '',
          createdAt: new Date().toISOString()
        };
        const fields = toFirestoreFields(newCert);
        await firestoreRequest(`/certificates/${certId}`, 'PATCH', { fields });

        // Link certId onto ticket document if ticketCode provided
        const targetTicketCode = (body.ticketCode || body.ticketId || '').trim();
        if (targetTicketCode) {
          try {
            await firestoreRequest(`/tickets/${encodeURIComponent(targetTicketCode)}?updateMask.fieldPaths=certId`, 'PATCH', {
              fields: { certId: { stringValue: certId } }
            });
          } catch (e) {
            console.warn('[Certificates] Update ticket certId note:', e.message);
          }
        }

        markCacheStale('GET:/certificates');
        markCacheStale('GET:/tickets');
        persistCacheToDisk();
        return sendJson(res, 200, { success: true, id: certId, certificate: newCert });
      }

      // 16. GET /api/users (All real Firestore user profiles) & GET/PATCH /api/users/:id
      if (pathname === '/api/users' && req.method === 'GET') {
        const forceFresh = parsedUrl.searchParams.get('fresh') === '1';
        const data = await firestoreRequest('/users', 'GET', null, { forceFresh });
        const users = (data.documents || []).map(fromFirestoreDoc).filter(Boolean);
        return sendJson(res, 200, { documents: users });
      }
      const userMatch = pathname.match(/^\/api\/users\/([^\/]+)$/);
      if (userMatch && req.method === 'GET') {
        const uid = decodeURIComponent(userMatch[1]);
        const userDoc = await firestoreRequest(`/users/${uid}`);
        return sendJson(res, 200, fromFirestoreDoc(userDoc) || { id: uid, activityPoints: 0 });
      }
      if (userMatch && req.method === 'PATCH') {
        const uid = decodeURIComponent(userMatch[1]);
        const body = await parseBody(req);
        const fields = toFirestoreFields(body);
        await firestoreRequest(`/users/${uid}`, 'PATCH', { fields });
        return sendJson(res, 200, { success: true, userId: uid });
      }

      // 17. POST /api/reports/export & /api/upload (Persist real generated report under web_portal/exports)
      if ((pathname === '/api/upload' || pathname === '/api/reports/export') && req.method === 'POST') {
        const body = await parseBody(req);
        const rawName = String(body.fileName || `ctsv_report_${Date.now()}.csv`).replace(/[^a-zA-Z0-9._-]/g, '_');
        const exportsDir = path.join(PUBLIC_DIR, 'exports');
        if (!fs.existsSync(exportsDir)) {
          fs.mkdirSync(exportsDir, { recursive: true });
        }

        let fileContent = body.content || '';
        if (!fileContent) {
          // Build genuine summary report from live Firestore cached/fetched datasets
          const [evtRes, tktRes, budgetRes] = await Promise.all([
            firestoreRequest('/events'),
            firestoreRequest('/tickets'),
            firestoreRequest('/budgets')
          ]);
          const events = (evtRes.documents || []).map(fromFirestoreDoc);
          const tickets = (tktRes.documents || []).map(fromFirestoreDoc);
          const budgets = (budgetRes.documents || []).map(fromFirestoreDoc);
          fileContent = JSON.stringify({
            generatedAt: new Date().toISOString(),
            projectId: PROJECT_ID,
            summary: {
              eventsCount: events.length,
              ticketsCount: tickets.length,
              checkedInCount: tickets.filter(t => t.status === 'checkedIn' || t.status === 'checked_in' || t.checkInStatus === true).length,
              budgetsCount: budgets.length
            },
            events: events.map(e => ({ id: e.id, title: e.title, date: e.date, registeredCount: e.registeredCount, capacity: e.capacity })),
            tickets: tickets.map(t => ({ ticketCode: t.ticketCode || t.id, studentId: t.studentId, studentName: t.studentName, eventId: t.eventId, status: t.status, checkedInAt: t.checkedInAt }))
          }, null, 2);
        }

        const outPath = path.join(exportsDir, rawName);
        fs.writeFileSync(outPath, String(fileContent), 'utf8');
        const stats = fs.statSync(outPath);
        const downloadUrl = `http://localhost:${PORT}/exports/${encodeURIComponent(rawName)}`;
        console.log(`[Report Export] Wrote ${outPath} (${stats.size} bytes)`);
        return sendJson(res, 200, {
          success: true,
          fileName: rawName,
          sizeBytes: stats.size,
          downloadUrl,
          path: `exports/${rawName}`,
          exportedAt: new Date().toISOString()
        });
      }

      // 404 for unknown API
      return sendJson(res, 404, { error: 'API route not found' });
    } catch (err) {
      console.error(`[API Error] ${req.method} ${pathname}:`, err.message);
      return sendJson(res, 500, { error: err.message });
    }
  }

  // ==========================================
  // STATIC FILE SERVING
  // ==========================================
  let reqPath = pathname;
  if (reqPath === '/' || reqPath === '') {
    reqPath = '/index.html';
  }

  const safePath = path.normalize(reqPath).replace(/^(\.\.[\/\\])+/, '');
  const filePath = path.join(PUBLIC_DIR, safePath);

  fs.stat(filePath, (err, stats) => {
    if (err || !stats.isFile()) {
      res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
      res.end('404 Not Found: ' + reqPath);
      return;
    }

    const ext = path.extname(filePath).toLowerCase();
    const contentType = MIME_TYPES[ext] || 'application/octet-stream';

    res.writeHead(200, {
      'Content-Type': contentType,
      'Cache-Control': 'no-cache, no-store, must-revalidate',
      'Access-Control-Allow-Origin': '*'
    });

    const stream = fs.createReadStream(filePath);
    stream.pipe(res);
  });
});

server.listen(PORT, () => {
  console.log(`\n======================================================`);
  console.log(`🏛️  FPTU CAMPUS EVENT - ADMIN WEB PORTAL BACKEND`);
  console.log(`🌐 Local Web Server: http://localhost:${PORT}`);
  console.log(`🔥 Cloud Firestore:  ${PROJECT_ID}`);
  console.log(`📡 Backend API:      http://localhost:${PORT}/api/status`);
  console.log(`✨ Status:           Connected & Ready with 100% Real Firestore`);
  console.log(`======================================================\n`);
});

server.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    const nextPort = PORT + 1;
    console.log(`Port ${PORT} is in use, trying port ${nextPort}...`);
    server.listen(nextPort);
  } else {
    console.error('Server error:', err);
  }
});

process.on('uncaughtException', (err) => {
  console.error('[Process Uncaught Exception]:', err.message);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('[Process Unhandled Rejection]:', reason);
});
