#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_SOURCE="$ROOT_DIR/dist/QuotaHalo.app"
APP_TARGET="$HOME/Applications/QuotaHalo.app"
PLIST="$HOME/Library/LaunchAgents/io.github.beyonderxx.QuotaHalo.plist"

if [[ ! -d "$APP_SOURCE" ]]; then
  "$ROOT_DIR/scripts/build-app.sh" >/dev/null
fi

mkdir -p "$HOME/Applications" "$HOME/Library/LaunchAgents"
rm -rf "$APP_TARGET"
cp -R "$APP_SOURCE" "$APP_TARGET"

cat > "$PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>io.github.beyonderxx.QuotaHalo</string>
  <key>ProgramArguments</key>
  <array>
    <string>$APP_TARGET/Contents/MacOS/QuotaHalo</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <false/>
</dict>
</plist>
PLIST

launchctl unload "$PLIST" >/dev/null 2>&1 || true
launchctl load "$PLIST"
echo "$APP_TARGET"
