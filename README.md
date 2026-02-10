# Old iPad Photo Frame

Turn an old iPad (or any tablet/browser) into a digital photo frame. Zero dependencies — just Node.js and your photos.

Built specifically for legacy devices like the iPad Air 1st gen (iOS 11/12) where modern apps no longer work, but works great on any browser.

## Features

- **Crossfade slideshow** with configurable interval
- **Tap to navigate** — left half goes back, right half goes forward
- **Swipe support** — swipe left/right to change photos
- **Visual feedback** — shows "Previous" / "Next" indicator on tap
- **Clock overlay** — optional clock in the bottom-right corner
- **Fullscreen web app** — Add to Home Screen on iOS for a chrome-free experience
- **Settings panel** — tap top-right corner to configure interval, transition, image fit, shuffle, and clock
- **Auto-discovery** — drop images into `photos/` and the server picks them up
- **No scroll/bounce** — locked down for kiosk-style use
- **No dependencies** — just Node.js, no npm install needed

## Quick Start

```bash
git clone https://github.com/carlosbaraza/old-ipad-photo-frame.git
cd old-ipad-photo-frame

# Add your photos
cp ~/Pictures/*.jpg photos/

# Start the server
node server.js
```

Open `http://<your-ip>:8080` on your iPad/tablet.

## iPad Setup

1. Open Safari and navigate to `http://<server-ip>:8080`
2. Tap **Share > Add to Home Screen** — this removes all browser chrome
3. Open the app from the Home Screen
4. Set **Auto-Lock to Never** (Settings > Display & Brightness)
5. Optionally enable **Guided Access** (Settings > Accessibility) to lock it to the photo frame

## Configuration

The port defaults to `8080` and can be changed via environment variable:

```bash
PORT=3000 node server.js
```

In-app settings (tap the top-right corner of the screen):

| Setting | Options | Default |
|---------|---------|---------|
| Slide interval | 1–300 seconds | 8s |
| Transition | Crossfade / Cut | Crossfade |
| Image fit | Contain / Cover | Contain |
| Clock | Show / Hide | Show |
| Shuffle | On / Off | Off |

Settings are saved to localStorage and persist across sessions.

## Supported Formats

JPEG, PNG, GIF, WebP, BMP, SVG — any format your target browser supports.

**Note:** HEIC files (from iPhones) are not supported by older browsers. Convert them to JPEG first:

```bash
# macOS — convert all HEIC to JPEG
for f in photos/*.heic; do
  sips -s format jpeg "$f" --out "photos/$(basename "$f" .heic).jpg"
  rm "$f"
done
```

## Running as a Service

To run permanently on a Linux server (Debian/Ubuntu):

```bash
# Copy files to server
scp server.js index.html user@server:/opt/photoframe/
scp photos/* user@server:/opt/photoframe/photos/

# On the server, create a systemd service
sudo cat > /etc/systemd/system/photoframe.service << 'EOF'
[Unit]
Description=Photo Frame Web Server
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/photoframe
ExecStart=/usr/bin/node /opt/photoframe/server.js
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable photoframe
sudo systemctl start photoframe
```

## Project Structure

```
.
├── server.js          # Web server (Node.js, zero dependencies)
├── index.html         # Single-page slideshow app
├── photos/            # Drop your images here
│   └── placeholder-*.jpg
├── LICENSE
└── README.md
```

## License

MIT
