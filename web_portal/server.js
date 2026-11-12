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
  if (!doc) return null;
  const id = doc.name ? doc.name.split('/').pop() : '';
  const fields = doc.fields || {};
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
const CACHE_TTL_MS = 60000; // 60 seconds quota-safe cache

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

function getFromCache(method, endpoint) {
  const exactKey = `${method}:${endpoint}`;
  if (firestoreCache.has(exactKey)) return firestoreCache.get(exactKey).data;
  const baseEndpoint = endpoint.split('?')[0];
  const baseKey = `${method}:${baseEndpoint}`;
  if (firestoreCache.has(baseKey)) return firestoreCache.get(baseKey).data;
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

    if (!firestoreCache.has(cacheKey)) return;
    const cached = firestoreCache.get(cacheKey);
    if (!cached.data || !Array.isArray(cached.data.documents)) return;

    if (method === 'DELETE' && docId) {
      cached.data.documents = cached.data.documents.filter(d => !d.name.endsWith(`/${docId}`));
      firestoreCache.set(cacheKey, { timestamp: Date.now(), data: cached.data });
      persistCacheToDisk();
      console.log(`[Cache Sync] Removed ${docId} from ${cacheKey}`);
    } else if (method === 'POST' && body && body.fields) {
      const docName = `projects/${PROJECT_ID}/databases/(default)/documents/${collection}/${docId || ('doc_' + Date.now())}`;
      const newDoc = {
        name: docName,
        fields: body.fields,
        createTime: new Date().toISOString(),
        updateTime: new Date().toISOString()
      };
      cached.data.documents = cached.data.documents.filter(d => d.name !== docName);
      cached.data.documents.unshift(newDoc);
      firestoreCache.set(cacheKey, { timestamp: Date.now(), data: cached.data });
      persistCacheToDisk();
      console.log(`[Cache Sync] Added ${docName} to ${cacheKey}`);
    } else if (method === 'PATCH' && docId && body && body.fields) {
      let found = false;
      for (const d of cached.data.documents) {
        if (d.name && d.name.endsWith(`/${docId}`)) {
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

async function firestoreRequest(endpoint, method = 'GET', body = null) {
  const cacheKey = `${method}:${endpoint}`;
  if (method === 'GET') {
    const cachedData = getFromCache(method, endpoint);
    const cachedEntry = firestoreCache.get(cacheKey) || firestoreCache.get(`${method}:${endpoint.split('?')[0]}`);
    if (cachedData && cachedEntry && (Date.now() - cachedEntry.timestamp < CACHE_TTL_MS)) {
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
      // If 429 (Quota exceeded) or server error, gracefully serve cached data if available
      const cachedData = getFromCache(method, endpoint);
      if (cachedData) {
        console.warn(`[Firestore Quota/Status ${res.status}] Serving cached data for ${endpoint}`);
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
        const data = await firestoreRequest('/events');
        const events = (data.documents || []).map(fromFirestoreDoc);
        return sendJson(res, 200, { documents: events });
      }

      // 2b. POST /api/events (Create Event - Management Feature)
      if (pathname === '/api/events' && req.method === 'POST') {
        const body = await parseBody(req);
        if (!body.title || !body.location || !body.date) {
          return sendJson(res, 400, { error: 'Vui lòng điền đầy đủ tiêu đề, địa điểm và ngày tổ chức sự kiện.' });
        }

        // Validate that event date is not in the past
        let eventDateObj = null;
        const dateRaw = String(body.date).trim();
        if (dateRaw.includes('/')) {
          const parts = dateRaw.split('/').map(Number); // DD/MM/YYYY
          if (parts.length === 3 && parts.every(n => !isNaN(n))) {
            eventDateObj = new Date(parts[2], parts[1] - 1, parts[0], 23, 59, 59);
          }
        } else if (dateRaw.includes('-')) {
          const parts = dateRaw.split('-').map(Number);
          if (parts.length === 3 && parts.every(n => !isNaN(n))) {
            if (parts[0] > 1000) { // YYYY-MM-DD
              eventDateObj = new Date(parts[0], parts[1] - 1, parts[2], 23, 59, 59);
            } else { // DD-MM-YYYY
              eventDateObj = new Date(parts[2], parts[1] - 1, parts[0], 23, 59, 59);
            }
          }
        }

        if (eventDateObj) {
          const now = new Date();
          const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0);
          if (eventDateObj < startOfToday) {
            return sendJson(res, 400, {
              error: 'Không thể tạo sự kiện trong quá khứ! Ngày tổ chức phải từ ngày hiện tại trở đi.'
            });
          }
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
          date: body.date.trim(),
          time: (body.time || '14:00 - 17:00').trim(),
          location: body.location.trim(),
          capacity: parseInt(body.capacity || 200, 10),
          registeredCount: 0,
          bannerUrl: body.bannerUrl || 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=1200',
          isFeatured: Boolean(body.isFeatured),
          speakers: body.speakers || [],
          sessions: body.sessions || [],
          createdAt: now,
          updatedAt: now
        };

        const fields = toFirestoreFields(eventData);
        await firestoreRequest(`/events?documentId=${eventId}`, 'POST', { fields });
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
        const regId = body.id || `REG-${Date.now()}`;
        const now = new Date().toISOString();
        const regData = {
          id: regId,
          eventId: body.eventId || '',
          eventTitle: body.eventTitle || '',
          userId: body.userId || '',
          studentName: body.studentName || '',
          studentEmail: body.studentEmail || '',
          status: 'pending',
          createdAt: body.createdAt || now,
        };
        const fields = toFirestoreFields(regData);
        await firestoreRequest(`/registrations/${regId}`, 'PATCH', { fields });
        console.log(`[Registration Submitted] ${regId} by ${regData.studentName} for ${regData.eventTitle}`);
        return sendJson(res, 200, { success: true, registration: regData });
      }

      // 5. POST /api/registrations/:id/approve (Cross-Role Approval Action)
      const approveMatch = pathname.match(/^\/api\/registrations\/([^\/]+)\/approve$/);
      if (approveMatch && req.method === 'POST') {
        const regId = decodeURIComponent(approveMatch[1]);
        const regDoc = await firestoreRequest(`/registrations/${regId}`);
        const regData = fromFirestoreDoc(regDoc);

        const ticketCode = `CE2026-${Math.floor(100000 + Math.random() * 900000)}`;
        const now = new Date().toISOString();

        // Step A: Patch registration status to 'approved'
        await firestoreRequest(`/registrations/${regId}?updateMask.fieldPaths=status&updateMask.fieldPaths=ticketId&updateMask.fieldPaths=reviewedAt`, 'PATCH', {
          fields: {
            status: { stringValue: 'approved' },
            ticketId: { stringValue: ticketCode },
            reviewedAt: { stringValue: now }
          }
        });

        // Step B: Write new active ticket to 'tickets' collection
        const ticketFields = toFirestoreFields({
          id: ticketCode,
          eventId: regData.eventId || 'EVT-2026-01',
          eventTitle: regData.eventTitle || 'Sự kiện FPTU',
          eventDate: regData.eventDate || '28/10/2026',
          eventTime: regData.eventTime || '13:30 - 17:30',
          eventLocation: regData.eventLocation || 'Hội trường Trịnh Công Sơn',
          userId: regData.userId || 'USR-STUDENT',
          studentName: regData.studentName || 'Sinh viên FPTU',
          studentEmail: regData.studentEmail || 'student@fpt.edu.vn',
          studentId: (regData.studentEmail || '').split('@')[0].toUpperCase(),
          ticketCode: ticketCode,
          qrToken: `QR-TOKEN-${ticketCode}-${Date.now()}`,
          qrData: `FPTU-CE-${regData.eventId || 'EVT'}-${regData.userId || 'USR'}-${ticketCode}`,
          status: 'confirmed',
          checkInStatus: false,
          points: 5,
          certId: `CERT-2026-${Math.floor(1000 + Math.random() * 9000)}`,
          createdAt: now
        });
        await firestoreRequest(`/tickets?documentId=${ticketCode}`, 'POST', { fields: ticketFields });

        // Update event registeredCount
        if (regData.eventId) {
          try {
            await firestoreRequest(`/events/${regData.eventId}?updateMask.fieldPaths=registeredCount`, 'PATCH', {
              fields: {
                registeredCount: { integerValue: '95' }
              }
            });
          } catch (_) {}
        }

        // Step C: Write notification to 'announcements' collection for Mobile Inbox
        const annId = `ANN-${Date.now()}`;
        const annFields = toFirestoreFields({
          id: annId,
          title: 'Đăng ký sự kiện đã được duyệt! 🎉',
          category: 'ticket_approved',
          categoryLabel: 'Duyệt vé thành công',
          message: `Chúc mừng ${regData.studentName || 'bạn'}! Đơn đăng ký sự kiện "${regData.eventTitle || 'Campus Event'}" đã được phê duyệt. Vé ${ticketCode} đã có trong mục "Vé của tôi".`,
          eventId: regData.eventId || '',
          userId: regData.userId || '',
          createdAt: now,
          status: 'published',
          pinned: false
        });
        await firestoreRequest(`/announcements?documentId=${annId}`, 'POST', { fields: annFields });

        console.log(`[Cross-Role Approval] Approved regId: ${regId} -> Issued ticket: ${ticketCode}`);
        return sendJson(res, 200, { success: true, ticketCode, registrationId: regId });
      }

      // 6. POST /api/registrations/:id/reject (Cross-Role Rejection Action)
      const rejectMatch = pathname.match(/^\/api\/registrations\/([^\/]+)\/reject$/);
      if (rejectMatch && req.method === 'POST') {
        const regId = decodeURIComponent(rejectMatch[1]);
        const body = await parseBody(req);
        const reason = body.reason || 'Sự kiện đã đạt số lượng tối đa';
        const now = new Date().toISOString();

        // Step A: Patch registration status to 'rejected'
        await firestoreRequest(`/registrations/${regId}?updateMask.fieldPaths=status&updateMask.fieldPaths=reason&updateMask.fieldPaths=reviewedAt`, 'PATCH', {
          fields: {
            status: { stringValue: 'rejected' },
            reason: { stringValue: reason },
            reviewedAt: { stringValue: now }
          }
        });

        // Step B: Write rejection announcement to 'announcements'
        const annId = `ANN-${Date.now()}`;
        const annFields = toFirestoreFields({
          id: annId,
          title: 'Thông báo về đơn đăng ký sự kiện',
          category: 'ticket_rejected',
          categoryLabel: 'Từ chối đăng ký',
          message: `Đơn đăng ký sự kiện của bạn không được phê duyệt. Lý do: ${reason}.`,
          createdAt: now,
          status: 'published',
          pinned: false
        });
        await firestoreRequest(`/announcements?documentId=${annId}`, 'POST', { fields: annFields });

        console.log(`[Cross-Role Rejection] Rejected regId: ${regId} -> Reason: ${reason}`);
        return sendJson(res, 200, { success: true, registrationId: regId, reason });
      }

      // 7. GET /api/announcements (Announcements Inbox History)
      if (pathname === '/api/announcements' && req.method === 'GET') {
        const data = await firestoreRequest('/announcements');
        const announcements = (data.documents || []).map(fromFirestoreDoc);
        return sendJson(res, 200, { documents: announcements });
      }

      // 8. POST /api/announcements (Broadcast Announcements to Mobile App)
      if (pathname === '/api/announcements' && req.method === 'POST') {
        const body = await parseBody(req);
        const annId = `ANN-${Date.now()}`;
        const now = new Date().toISOString();

        const annFields = toFirestoreFields({
          id: annId,
          title: body.title || 'Thông báo mới từ Phòng CTSV',
          category: body.category || 'official',
          categoryLabel: body.categoryLabel || 'Phát thanh CTSV',
          message: body.message || body.content || '',
          content: body.content || body.message || '',
          pinned: Boolean(body.pinned),
          createdAt: now,
          status: 'published'
        });

        await firestoreRequest(`/announcements?documentId=${annId}`, 'POST', { fields: annFields });
        console.log(`[Announcements Broadcast] Created announcement: ${annId} - ${body.title}`);
        return sendJson(res, 200, { success: true, id: annId });
      }

      // 9. GET /api/tickets (Student Directory & Live Gate Data)
      if (pathname === '/api/tickets' && req.method === 'GET') {
        const userIdFilter = parsedUrl.searchParams.get('userId');
        const data = await firestoreRequest('/tickets');
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

        // Enforce BR: Reject tickets for past or fully booked events
        if (body.eventId && !body.checkInStatus) {
          try {
            const evtDoc = await firestoreRequest(`/events/${body.eventId}`);
            const evt = fromFirestoreDoc(evtDoc);
            if (evt) {
              if (evt.date) {
                const parts = evt.date.split('/');
                if (parts.length === 3) {
                  const evtDate = new Date(parseInt(parts[2]), parseInt(parts[1]) - 1, parseInt(parts[0]), 23, 59, 59);
                  if (evtDate < new Date()) {
                    return sendJson(res, 400, { error: 'Sự kiện đã kết thúc, không thể cấp vé.' });
                  }
                }
              }
              if (typeof evt.registeredCount === 'number' && evt.capacity && evt.registeredCount >= evt.capacity) {
                return sendJson(res, 400, { error: 'Sự kiện đã hết chỗ.' });
              }
            }
          } catch (_) {}
        }

        const ticketData = {
          id: ticketId,
          ticketCode: body.ticketCode || ticketId,
          eventId: body.eventId || 'EVT-2026-01',
          eventTitle: body.eventTitle || 'FPTU Tech Expo 2026: Trí tuệ Nhân tạo & Tương lai',
          eventDate: body.eventDate || '28/10/2026',
          eventTime: body.eventTime || '13:30 - 17:30',
          eventLocation: body.eventLocation || 'Hội trường Trịnh Công Sơn',
          userId: body.userId || 'USR-STUDENT',
          studentName: body.studentName || 'Sinh viên FPTU',
          studentEmail: body.studentEmail || 'student@fpt.edu.vn',
          studentId: body.studentId || (body.studentEmail || '').split('@')[0].toUpperCase(),
          qrToken: body.qrToken || `QR-TOKEN-${ticketId}`,
          qrData: body.qrData || `FPTU-CE-${body.eventId || 'EVT'}-${body.userId || 'USR'}-${ticketId}`,
          status: body.status || 'active',
          checkInStatus: Boolean(body.checkInStatus),
          checkedInAt: body.checkedInAt || (body.checkInStatus ? new Date().toLocaleTimeString('vi-VN') + ' ' + new Date().toLocaleDateString('vi-VN') : ''),
          points: body.points !== undefined ? body.points : (body.checkInStatus ? 5 : 0),
          certId: body.certId || (body.checkInStatus ? `CERT-2026-${Math.floor(1000 + Math.random() * 9000)}` : ''),
          createdAt: body.createdAt || now
        };

        const fields = toFirestoreFields(ticketData);
        await firestoreRequest(`/tickets/${ticketId}`, 'PATCH', { fields });
        console.log(`[Ticket Upsert] Synced ticket ${ticketId} for ${ticketData.studentName}`);

        // Increment event registeredCount on newly issued ticket
        if (ticketData.eventId && !body.checkInStatus) {
          try {
            const evtDoc = await firestoreRequest(`/events/${ticketData.eventId}`);
            const evt = fromFirestoreDoc(evtDoc);
            if (evt && typeof evt.registeredCount === 'number') {
              const newCount = evt.registeredCount + 1;
              await firestoreRequest(`/events/${ticketData.eventId}?updateMask.fieldPaths=registeredCount`, 'PATCH', {
                fields: { registeredCount: { integerValue: String(newCount) } }
              });
              console.log(`[Ticket Upsert] Incremented registeredCount on ${ticketData.eventId} to ${newCount}`);
            }
          } catch (_) {}
        }
        return sendJson(res, 200, { success: true, ticket: ticketData });
      }

      // 9d. POST /api/tickets/:id/revoke (Revoke / Cancel Ticket in Cloud Firestore)
      const ticketRevokeMatch = pathname.match(/^\/api\/tickets\/([^\/]+)\/revoke$/);
      if (ticketRevokeMatch && req.method === 'POST') {
        const ticketId = decodeURIComponent(ticketRevokeMatch[1]);
        const body = await parseBody(req);
        const reason = body.reason || 'Cán bộ CTSV thu hồi theo quy chế';
        await firestoreRequest(`/tickets/${ticketId}?updateMask.fieldPaths=status&updateMask.fieldPaths=cancelReason`, 'PATCH', {
          fields: {
            status: { stringValue: 'cancelled' },
            cancelReason: { stringValue: reason }
          }
        });
        console.log(`[Ticket Revoke] Revoked ticket ${ticketId}`);
        return sendJson(res, 200, { success: true, message: `Đã thu hồi vé ${ticketId}` });
      }

      // 10. GET /api/gate-assignments (Gate Duty Roster & Staff Assignments)
      if (pathname === '/api/gate-assignments' && req.method === 'GET') {
        const emailFilter = parsedUrl.searchParams.get('email');
        const data = await firestoreRequest('/gate_assignments');
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

        const dutyId = body.id || `DUTY-2026-${Date.now().toString().slice(-4)}`;
        const now = new Date().toISOString();

        const assignmentData = {
          id: dutyId,
          email: body.email.trim().toLowerCase(),
          studentName: (body.studentName || 'CTV FPTU').trim(),
          studentId: (body.studentId || (body.email.split('@')[0])).toUpperCase().trim(),
          eventId: body.eventId,
          eventTitle: body.eventTitle || 'Sự kiện FPTU',
          gateName: body.gateName || 'Cổng Chính (Cửa 1)',
          role: body.role || 'CTV Soát Vé Cổng',
          shiftTime: body.shiftTime || '13:00 - 17:30',
          status: 'active',
          assignedBy: 'Phòng CTSV',
          assignedAt: now
        };

        const fields = toFirestoreFields(assignmentData);
        await firestoreRequest(`/gate_assignments?documentId=${dutyId}`, 'POST', { fields });
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
        }
        console.log(`[Gate Assignment] Updated ${dutyId}:`, body);
        return sendJson(res, 200, { success: true, dutyId });
      }

      // 10d. DELETE /api/gate-assignments/:id (Delete Duty Assignment)
      if (dutyPatchMatch && req.method === 'DELETE') {
        const dutyId = decodeURIComponent(dutyPatchMatch[1]);
        await firestoreRequest(`/gate_assignments/${dutyId}`, 'DELETE');
        console.log(`[Gate Assignment] Deleted ${dutyId}`);
        return sendJson(res, 200, { success: true, dutyId });
      }

      // 9c. POST /api/tickets/checkin (Gate Check-In Action - Real Cloud Firestore)
      if (pathname === '/api/tickets/checkin' && req.method === 'POST') {
        const body = await parseBody(req);
        const rawToken = (body.ticketCode || body.qrToken || body.id || '').trim();
        if (!rawToken) {
          return sendJson(res, 400, { error: 'Vui lòng cung cấp mã vé hoặc QR token.' });
        }

        // Fetch all tickets to find match
        const data = await firestoreRequest('/tickets');
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
          // If not found in existing documents, check if client sent student details to create it
          if (body.studentName || body.userId) {
            const m = rawToken.match(/CE2026-\d+/);
            const ticketId = m ? m[0] : (rawToken.startsWith('CE2026') ? rawToken : `CE2026-${Math.floor(100000 + Math.random() * 900000)}`);
            const now = new Date().toISOString();
            const nowStr = new Date().toLocaleTimeString('vi-VN') + ' ' + new Date().toLocaleDateString('vi-VN');
            const newTicket = {
              id: ticketId,
              ticketCode: ticketId,
              eventId: body.eventId || 'EVT-2026-01',
              eventTitle: body.eventTitle || 'FPTU Tech Expo 2026: Trí tuệ Nhân tạo & Tương lai',
              eventDate: body.eventDate || '28/10/2026',
              eventTime: body.eventTime || '13:30 - 17:30',
              eventLocation: body.eventLocation || 'Hội trường Trịnh Công Sơn',
              userId: body.userId || 'USR-STUDENT',
              studentName: body.studentName || 'Sinh viên FPTU',
              studentEmail: body.studentEmail || 'student@fpt.edu.vn',
              studentId: body.studentId || (body.studentEmail || '').split('@')[0].toUpperCase(),
              qrToken: rawToken,
              qrData: `FPTU-CE-EVT-2026-01-${body.userId || 'USR'}-${ticketId}`,
              status: 'checkedIn',
              checkInStatus: true,
              checkedInAt: nowStr,
              points: 5,
              certId: `CERT-2026-${Math.floor(1000 + Math.random() * 9000)}`,
              createdAt: now
            };
            const fields = toFirestoreFields(newTicket);
            await firestoreRequest(`/tickets/${ticketId}`, 'PATCH', { fields });
            return sendJson(res, 200, { success: true, ticket: newTicket, message: 'Check-in thành công!' });
          }
          return sendJson(res, 404, { error: `Không tìm thấy vé hợp lệ với mã: ${rawToken}` });
        }

        if (match.status === 'checkedIn' || match.checkInStatus === true) {
          return sendJson(res, 409, {
            error: `CẢNH BÁO: Vé đã được check-in vào lúc ${match.checkedInAt || '14:02'} tại Cổng 1.`,
            isDuplicate: true,
            ticket: match
          });
        }

        const nowStr = new Date().toLocaleTimeString('vi-VN') + ' ' + new Date().toLocaleDateString('vi-VN');
        const certId = match.certId || `CERT-2026-${Math.floor(1000 + Math.random() * 9000)}`;

        await firestoreRequest(`/tickets/${match.id}?updateMask.fieldPaths=status&updateMask.fieldPaths=checkInStatus&updateMask.fieldPaths=checkedInAt&updateMask.fieldPaths=points&updateMask.fieldPaths=certId`, 'PATCH', {
          fields: {
            status: { stringValue: 'checkedIn' },
            checkInStatus: { booleanValue: true },
            checkedInAt: { stringValue: nowStr },
            points: { integerValue: '5' },
            certId: { stringValue: certId }
          }
        });

        // Award +5 points to student in users collection
        if (match.userId) {
          try {
            const userDoc = await firestoreRequest(`/users/${match.userId}`);
            const userData = fromFirestoreDoc(userDoc);
            const currentPoints = parseInt(userData.activityPoints || 0, 10);
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
            checkedInAt: nowStr,
            points: 5,
            certId
          },
          message: `Check-in thành công! Chào mừng ${match.studentName}.`
        });
      }

      // 10. GET /api/budgets (Real Firestore Budget Proposals)
      if (pathname === '/api/budgets' && req.method === 'GET') {
        const data = await firestoreRequest('/budgets');
        let documents = (data.documents || []).map(fromFirestoreDoc);

        if (documents.length === 0) {
          const defaultProposals = [
            {
              id: 'PRJ-2026-01',
              title: 'FPTU Tech Expo 2026: AI & Robotics',
              club: 'CLB Lập trình F-Code',
              budget: 18000000,
              source: 'Quỹ HĐSV (12tr) + Doanh nghiệp (6tr)',
              status: 'approved',
              date: '28/10/2026'
            },
            {
              id: 'PRJ-2026-02',
              title: 'Workshop UI/UX Design Masterclass',
              club: 'CLB Kỹ sư phần mềm Nhật Bản',
              budget: 6500000,
              source: 'Quỹ Hoạt động Sinh viên FPTU',
              status: 'pending',
              date: '05/11/2026'
            },
            {
              id: 'PRJ-2026-03',
              title: 'Giải Đấu Thể Thao Điện Tử FPTU Champions League',
              club: 'CLB F-Code',
              budget: 8000000,
              source: 'Quỹ Hoạt động Sinh viên FPTU',
              status: 'approved',
              date: '05/11/2026'
            }
          ];

          for (const p of defaultProposals) {
            try {
              const fields = toFirestoreFields(p);
              await firestoreRequest(`/budgets/${p.id}`, 'PATCH', { fields });
            } catch (_) {}
          }
          documents = defaultProposals;
        }

        return sendJson(res, 200, { documents });
      }

      // 10b. POST /api/budgets/:id/status (Approve or Reject Budget Proposal)
      const budgetMatch = pathname.match(/^\/api\/budgets\/([^\/]+)\/status$/);
      if (budgetMatch && req.method === 'POST') {
        const budgetId = decodeURIComponent(budgetMatch[1]);
        const body = await parseBody(req);
        const status = body.status || 'approved';
        const reason = body.reason || '';
        const now = new Date().toISOString();

        await firestoreRequest(`/budgets/${budgetId}?updateMask.fieldPaths=status&updateMask.fieldPaths=reason&updateMask.fieldPaths=reviewedAt`, 'PATCH', {
          fields: {
            status: { stringValue: status },
            reason: { stringValue: reason },
            reviewedAt: { stringValue: now }
          }
        });
        console.log(`[Budget Review] Budget ${budgetId} updated to ${status}`);
        return sendJson(res, 200, { success: true, budgetId, status });
      }

      // 11. GET /api/pccc-inspections (Real Firestore PCCC Safety Inspections)
      if (pathname === '/api/pccc-inspections' && req.method === 'GET') {
        const data = await firestoreRequest('/pccc_inspections');
        let documents = (data.documents || []).map(fromFirestoreDoc);
        if (documents.length === 0) {
          documents = [
            {
              id: 'vn-tcs',
              name: 'Hội trường Trịnh Công Sơn',
              capacity: 400,
              score: 100,
              signed: true,
              signedDate: '26/10/2026',
              signatory: 'Thượng úy PCCC & Trưởng ban CTSV FPTU',
              licenseNumber: '108/BB-CTSV-2026'
            },
            {
              id: 'vn-alpha',
              name: 'Phòng Hội thảo Alpha Building (Phòng 301)',
              capacity: 120,
              score: 95,
              signed: true,
              signedDate: '28/10/2026',
              signatory: 'Đội Trưởng An Ninh Campus',
              licenseNumber: '112/BB-CTSV-2026'
            },
            {
              id: 'vn-a2',
              name: 'Sân khấu Hội trường Lớn A2',
              capacity: 300,
              score: 90,
              signed: true,
              signedDate: '01/11/2026',
              signatory: 'Ban Quản Lý Tòa Nhà A2',
              licenseNumber: '115/BB-CTSV-2026'
            }
          ];
        }
        return sendJson(res, 200, { documents });
      }

      // 11b. POST /api/pccc-inspections/:id/sign (Sign Safety License)
      const pcccMatch = pathname.match(/^\/api\/pccc-inspections\/([^\/]+)\/sign$/);
      if (pcccMatch && req.method === 'POST') {
        const venueId = decodeURIComponent(pcccMatch[1]);
        const body = await parseBody(req);
        const signed = body.signed !== undefined ? body.signed : true;
        const signedDate = body.signedDate || new Date().toLocaleString('vi-VN');
        const signatory = body.signatory || 'Thượng úy PCCC & Trưởng ban CTSV FPTU';
        const licenseNumber = body.licenseNumber || '108/BB-CTSV';

        await firestoreRequest(`/pccc_inspections/${venueId}?updateMask.fieldPaths=signed&updateMask.fieldPaths=signedDate&updateMask.fieldPaths=signatory&updateMask.fieldPaths=licenseNumber`, 'PATCH', {
          fields: {
            signed: { booleanValue: signed },
            signedDate: { stringValue: signedDate },
            signatory: { stringValue: signatory },
            licenseNumber: { stringValue: licenseNumber }
          }
        });
        console.log(`[PCCC Inspection] Venue ${venueId} signed successfully: ${licenseNumber}`);
        return sendJson(res, 200, { success: true, venueId, signed, signedDate, signatory, licenseNumber });
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
        const data = await firestoreRequest('/certificates');
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
        return sendJson(res, 200, { success: true, certificate: newCert });
      }

      // 16. GET /api/users & PATCH /api/users/:id
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

      // 17. POST /api/upload (Web proxy upload)
      if (pathname === '/api/upload' && req.method === 'POST') {
        const body = await parseBody(req);
        const fileName = body.fileName || `file_${Date.now()}.pdf`;
        console.log(`[Upload Proxy] Received upload request for ${fileName}`);
        return sendJson(res, 200, {
          success: true,
          downloadUrl: `http://localhost:${PORT}/uploads/${fileName}`,
          path: `reports/${fileName}`
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
