#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

CONFIG="firebase/google-services.json"
SETTINGS="android/settings.gradle.kts"
APP_GRADLE="android/app/build.gradle.kts"
DEST="android/app/google-services.json"

if [[ ! -f "$CONFIG" ]]; then
  echo "Firebase config not present at $CONFIG; leaving Firebase Android wiring disabled."
  exit 0
fi

if [[ ! -f "$SETTINGS" || ! -f "$APP_GRADLE" ]]; then
  echo "Android wrapper is missing. Run flutter create --platforms=android first."
  exit 1
fi

cp "$CONFIG" "$DEST"

python3 - <<'PY'
from pathlib import Path

settings = Path("android/settings.gradle.kts")
text = settings.read_text()
plugin = 'id("com.google.gms.google-services") version "4.5.0" apply false'
if plugin not in text:
    marker = 'id("com.android.application")'
    if marker not in text:
        raise SystemExit("Could not find Android application plugin in settings.gradle.kts")
    text = text.replace(marker, plugin + "\n    " + marker, 1)
    settings.write_text(text)

app = Path("android/app/build.gradle.kts")
text = app.read_text()
plugin = 'id("com.google.gms.google-services")'
if plugin not in text:
    marker = 'id("com.android.application")'
    if marker not in text:
        raise SystemExit("Could not find Android application plugin in app/build.gradle.kts")
    text = text.replace(marker, marker + "\n    " + plugin, 1)
    app.write_text(text)
PY

echo "Firebase Android wiring applied."
