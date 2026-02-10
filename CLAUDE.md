# CLAUDE.md

## Project Overview

A zero-dependency Node.js web server that serves a photo slideshow, designed to run on old iPads (iOS 11+) as a digital photo frame. The entire frontend is a single HTML file with inline CSS and vanilla JavaScript — no build step, no frameworks, no npm packages.

## Architecture

**Two files do everything:**

- `server.js` — HTTP server using only Node.js built-in `http`, `fs`, and `path` modules. Serves the HTML page, a JSON API listing available photos, and the photo files themselves. Port configurable via `PORT` env var, defaults to 8080.

- `index.html` — Self-contained single-page app. All CSS is inline in a `<style>` tag, all JavaScript is inline in a `<script>` tag. No external resources loaded.

## Key Design Constraints

**iOS 11 Safari compatibility** is the primary constraint. This means:
- No ES6+ syntax — use `var`, not `let`/`const`. No arrow functions, no template literals, no destructuring.
- No modern APIs — use `XMLHttpRequest`, not `fetch`. No Service Workers, no ES modules.
- CSS requires `-webkit-` prefixes for `transition`, `transform`, `object-fit`, `user-select`, etc.
- `{ passive: false }` on touch event listeners to allow `preventDefault()` for scroll blocking.

## How the Slideshow Works

Two absolutely-positioned `<div class="slide">` elements alternate via opacity transitions (crossfade). When advancing, the hidden slide's `<img>` src is updated, then its opacity is set to 1 while the other fades to 0. This avoids any flash of blank screen between photos.

## Touch Interaction

- **Tap detection**: `touchstart` records position and time. `touchend` checks if movement was < 20px and duration < 300ms. Left half of screen = previous, right half = next.
- **Swipe detection**: Same events, but checks for > 50px horizontal movement. Left swipe = next, right swipe = previous.
- **Scroll prevention**: `touchmove` calls `preventDefault()` on the document (except when settings panel is open). `gesturestart`/`gesturechange` also prevented to block pinch-zoom.

## Server API

- `GET /` — Serves `index.html`
- `GET /api/photos` — Returns JSON array of photo URLs (e.g., `["/photos/IMG_001.jpg", ...]`)
- `GET /photos/<filename>` — Serves individual photo files with directory traversal protection

## Settings

Stored in `localStorage` under key `photoframe_config` as JSON. The settings panel is a hidden overlay triggered by tapping an invisible 40x40px div in the top-right corner.

## Adding Photos

Drop image files into the `photos/` directory. The server reads the directory on each `/api/photos` request, so new photos appear on next page load. Supported extensions: `.jpg`, `.jpeg`, `.png`, `.gif`, `.webp`, `.bmp`, `.svg`.

## Deployment

Designed to run on minimal hardware (tested on a 256MB RAM Debian VM). Can be managed as a systemd service — see README for the unit file. Uses ~30MB RAM at runtime.
