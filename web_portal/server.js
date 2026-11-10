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
              execSync('npx firebase-tools --version', { stdio: 'ignore', timeout: 8000 });
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
function fromFirestoreDoc(doc) {
  if (!doc) return null;
  const id = doc.name ? doc.name.split('/').pop() : '';
  const fields = doc.fields || {};
  const result = { id };

  for (const [key, val] of Object.entries(fields)) {
    if ('stringValue' in val) result[key] = val.stringValue;
    else if ('integerValue' in val) result[key] = parseInt(val.integerValue, 10);
    else if ('doubleValue' in val) result[key] = parseFloat(val.doubleValue);
    else if ('booleanValue' in val) result[key] = val.booleanValue;
    else if ('timestampValue' in val) result[key] = val.timestampValue;
    else if ('arrayValue' in val) {
      result[key] = (val.arrayValue.values || []).map(item => {
        if ('stringValue' in item) return item.stringValue;
        if ('integerValue' in item) return parseInt(item.integerValue, 10);
        return item;
      });
    } else {
      result[key] = val;
    }
  }
  return result;
}

function toFirestoreFields(obj) {
  const fields = {};
  for (const [key, val] of Object.entries(obj)) {
    if (val === undefined || val === null) continue;
    if (typeof val === 'string') {
      fields[key] = { stringValue: val };
    } else if (typeof val === 'number') {
      if (Number.isInteger(val)) {
        fields[key] = { integerValue: val.toString() };
      } else {
        fields[key] = { doubleValue: val };
      }
    } else if (typeof val === 'boolean') {
      fields[key] = { booleanValue: val };
    } else if (Array.isArray(val)) {
      fields[key] = {
        arrayValue: {
          values: val.map(v => (typeof v === 'string' ? { stringValue: v } : { stringValue: String(v) }))
        }
      };
    }
  }
  return fields;
}

// Firestore REST Request with Bearer Token
async function firestoreRequest(endpoint, method = 'GET', body = null) {
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

  const res = await fetch(url, options);
  if (!res.ok) {
    const errorText = await res.text();
    throw new Error(`Firestore HTTP ${res.status}: ${errorText}`);
  }
  return res.json();
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

      // 3. GET /api/clubs
      if (pathname === '/api/clubs' && req.method === 'GET') {
        const data = await firestoreRequest('/clubs?pageSize=100');
        const clubs = (data.documents || []).map(fromFirestoreDoc);
        return sendJson(res, 200, { documents: clubs });
      }

      // 4. GET /api/registrations (Review Queue)
      if (pathname === '/api/registrations' && req.method === 'GET') {
        const data = await firestoreRequest('/registrations');
        const registrations = (data.documents || []).map(fromFirestoreDoc);
        return sendJson(res, 200, { documents: registrations });
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
          userId: regData.userId || 'USR-STUDENT',
          studentName: regData.studentName || 'Sinh viên FPTU',
          studentEmail: regData.studentEmail || 'student@fpt.edu.vn',
          studentId: (regData.studentEmail || '').split('@')[0].toUpperCase(),
          ticketCode: ticketCode,
          qrData: `FPTU-CE-${regData.eventId || 'EVT'}-${regData.userId || 'USR'}-${ticketCode}`,
          status: 'confirmed',
          checkInStatus: false,
          points: 5,
          certId: `CERT-2026-${Math.floor(1000 + Math.random() * 9000)}`,
          createdAt: now
        });
        await firestoreRequest(`/tickets?documentId=${ticketCode}`, 'POST', { fields: ticketFields });

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
        const data = await firestoreRequest('/tickets');
        const tickets = (data.documents || []).map(fromFirestoreDoc);
        return sendJson(res, 200, { documents: tickets });
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
