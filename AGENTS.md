# Base44 Dev Environment

## What this is
A static Progressive Web App (PWA) — `index.html` + `service-worker.js` + `manifest.webmanifest` + `icons/`. No backend, no build step, no package manager, no external service credentials.

## Running it
`docker compose -f docker-compose.base44.yml up -d` serves the repo root via nginx on host port 3000.

- nginx config: `nginx.base44.conf` (no-cache headers for dev, correct PWA MIME types).
- The repo is bind-mounted read-only into the container, so edits to `index.html` / assets appear on the next page refresh — no rebuild needed.
- There is no live-reload dev server (pure static site). After editing, call `reload_preview` so the user sees the change.

## Verifying it works
`curl -sf -H "Host: external-preview.example.com" http://localhost:3000/` returns the `index.html` document.

## Notes
- The service worker (`service-worker.js`) caches the app shell; during dev a hard refresh may be needed to see changes. Do not change `CACHE_NAME` unless releasing.
- No secrets are required.
