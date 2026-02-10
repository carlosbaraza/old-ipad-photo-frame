var http = require('http');
var fs = require('fs');
var path = require('path');

var PORT = process.env.PORT || 8080;
var PHOTOS_DIR = path.join(__dirname, 'photos');

var IMAGE_EXTS = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp', '.svg'];

var MIME_TYPES = {
  '.html': 'text/html',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.png': 'image/png',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml'
};

if (!fs.existsSync(PHOTOS_DIR)) {
  fs.mkdirSync(PHOTOS_DIR);
}

function getPhotos() {
  try {
    var files = fs.readdirSync(PHOTOS_DIR);
    return files
      .filter(function(f) {
        var ext = path.extname(f).toLowerCase();
        return IMAGE_EXTS.indexOf(ext) !== -1;
      })
      .sort()
      .map(function(f) {
        return '/photos/' + encodeURIComponent(f);
      });
  } catch (e) {
    return [];
  }
}

var server = http.createServer(function(req, res) {
  var url = req.url.split('?')[0];

  if (url === '/api/photos') {
    var photos = getPhotos();
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(photos));
    return;
  }

  if (url.indexOf('/photos/') === 0) {
    var photoName = decodeURIComponent(url.slice(8));
    if (photoName.indexOf('..') !== -1 || photoName.indexOf('/') !== -1) {
      res.writeHead(403);
      res.end('Forbidden');
      return;
    }
    var photoPath = path.join(PHOTOS_DIR, photoName);
    var ext = path.extname(photoPath).toLowerCase();
    var contentType = MIME_TYPES[ext] || 'application/octet-stream';
    fs.readFile(photoPath, function(err, data) {
      if (err) { res.writeHead(404); res.end('Not found'); return; }
      res.writeHead(200, {
        'Content-Type': contentType,
        'Cache-Control': 'public, max-age=86400'
      });
      res.end(data);
    });
    return;
  }

  if (url === '/' || url === '/index.html') {
    fs.readFile(path.join(__dirname, 'index.html'), function(err, data) {
      if (err) { res.writeHead(500); res.end('Error'); return; }
      res.writeHead(200, { 'Content-Type': 'text/html' });
      res.end(data);
    });
    return;
  }

  res.writeHead(404);
  res.end('Not found');
});

server.listen(PORT, '0.0.0.0', function() {
  console.log('Photo Frame Server running on port ' + PORT);
  console.log('Photos: ' + getPhotos().length);
});
