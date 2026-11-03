const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 8080;
const DIR = path.join(__dirname, '..', 'figma_screens');

const server = http.createServer((req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', '*');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  const cleanUrl = decodeURIComponent(req.url.replace(/^\/+/, ''));

  if (cleanUrl === 'status') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok', dir: DIR }));
    return;
  }

  const filePath = path.join(DIR, cleanUrl);
  if (fs.existsSync(filePath) && fs.statSync(filePath).isFile()) {
    res.writeHead(200, { 'Content-Type': 'image/png' });
    fs.createReadStream(filePath).pipe(res);
  } else {
    res.writeHead(404, { 'Content-Type': 'text/plain' });
    res.end('Not found');
  }
});

server.listen(PORT, '127.0.0.1', () => {
  console.log(`Screen server running on http://127.0.0.1:${PORT}`);
});
