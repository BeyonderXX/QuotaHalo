#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$ROOT_DIR/dist/QuotaHalo.app"
ZIP_PATH="$ROOT_DIR/dist/QuotaHalo.app.zip"

if [[ ! -d "$APP_DIR" ]]; then
  "$ROOT_DIR/scripts/build-app.sh" >/dev/null
fi

cd "$ROOT_DIR/dist"
rm -f "$ZIP_PATH"
/usr/bin/ditto -c -k --keepParent "QuotaHalo.app" "$ZIP_PATH"
echo "$ZIP_PATH"
